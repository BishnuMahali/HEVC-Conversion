# MIT License
# Copyright (c) 2026 Bishnu Mahali
# See LICENSE file in the repository root for full license text.

# --- Auto Detect Encoders ---
$availableEncoders = @(
    @{ ID = "1"; Name = "NVIDIA AV1 (NVENC)"; Codec = "av1_nvenc"; Mode = "cq"; Supported = $false; Rank = 1 }
    @{ ID = "2"; Name = "NVIDIA HEVC (NVENC)"; Codec = "hevc_nvenc"; Mode = "cq"; Supported = $false; Rank = 2 }
    @{ ID = "3"; Name = "AMD AV1 (AMF)"; Codec = "av1_amf"; Mode = "qp"; Supported = $false; Rank = 3 }
    @{ ID = "4"; Name = "AMD HEVC (AMF)"; Codec = "hevc_amf"; Mode = "qp"; Supported = $false; Rank = 4 }
    @{ ID = "5"; Name = "Intel AV1 (QSV)"; Codec = "av1_qsv"; Mode = "global_quality"; Supported = $false; Rank = 5 }
    @{ ID = "6"; Name = "Intel HEVC (QSV)"; Codec = "hevc_qsv"; Mode = "global_quality"; Supported = $false; Rank = 6 }
    @{ ID = "7"; Name = "AV1 SVT (CPU)"; Codec = "libsvtav1"; Mode = "crf"; Supported = $true; Rank = 7 }
    @{ ID = "8"; Name = "HEVC (CPU - libx265)"; Codec = "libx265"; Mode = "crf"; Supported = $true; Rank = 8 }
)

Write-Host "Detecting hardware encoders..."
$ffmpegEncoders = (ffmpeg -encoders 2>&1 | Out-String)

foreach ($enc in $availableEncoders) {
    if ($ffmpegEncoders -match "\b$($enc.Codec)\b") {
        $enc.Supported = $true
    }
}

# --- State Variables ---
$targetFolder = $PWD.Path
$recursive = $false

# Pick best supported encoder by rank
$defaultEnc = $availableEncoders | Where-Object Supported | Sort-Object Rank | Select-Object -First 1
$selectedEncoderId = $defaultEnc.ID

$quality = "23,26,29"
$preset = if ($defaultEnc.Codec -match "nvenc") { "p5" } elseif ($defaultEnc.Codec -match "libsvtav1") { "6" } else { "slow" }

$audioAction = "AAC 128k"
$container = "MP4"

# --- File Filtering Variables ---
$knownVideoExtensions = @('.mp4', '.mkv', '.avi', '.mov', '.wmv', '.flv', '.webm', '.m4v', '.ts', '.vob', '.m2ts', '.mpeg', '.mpg', '.rm', '.rmvb', '.3gp', '.3g2', '.ogv', '.mp4v', '.f4v', '.asf', '.divx', '.xvid', '.yuv', '.viv', '.mxf')
$knownIgnoredExtensions = @('.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp', '.tiff', '.tif', '.heic', '.ico', '.svg', '.psd', '.ai', '.txt', '.log', '.pdf', '.zip', '.rar', '.7z', '.iso', '.ps1', '.md', '.json', '.csv', '.xml', '.ini', '.cfg', '.yaml', '.yml', '.html', '.css', '.js', '.db', '.sqlite', '.bak')


# --- Helper Functions ---
function Show-Menu {
    Clear-Host
    $activeEnc = ($availableEncoders | Where-Object ID -eq $selectedEncoderId)
    
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host "          SMART HEVC/AV1 OPTIMIZER           " -ForegroundColor Cyan
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host " [1] Target Folder : $targetFolder"
    Write-Host " [2] Recursive (Include Subfolders)    : $($recursive ? 'Yes' : 'No')"
    Write-Host " [3] Encoder       : $($activeEnc.Name) ($($activeEnc.Codec))"
    
    # Contextual Quality Hint
    $qHint = switch -regex ($activeEnc.Codec) {
        "nvenc" { "Recommended: 23,26,29 (CQ)" }
        "qsv"   { "Recommended: 23,26,29 (Global Quality)" }
        "amf"   { "Recommended: 23,26,29 (QP)" }
        "libsvtav1" { "Recommended: 24,28,32 (CRF)" }
        "libx265"   { "Recommended: 24,28,32 (CRF)" }
        Default { "Recommended: 23-30" }
    }
    Write-Host " [4] Quality ($($activeEnc.Mode)) : $quality"
    Write-Host "     ($qHint)" -ForegroundColor Gray
    
    # Contextual Preset Hint
    $pHint = switch -regex ($activeEnc.Codec) {
        "nvenc" { "Options: p1 to p7 (p5=default, p7=slowest)" }
        "libsvtav1" { "Options: 0 to 13 (6=balanced, 4=higher quality)" }
        "libx265"   { "Options: ultrafast to placebo (slow=recommended)" }
        Default { "Enter encoder-specific preset" }
    }
    Write-Host " [5] Preset        : $(if($preset){$preset}else{'None'})"
    Write-Host "     ($pHint)" -ForegroundColor Gray
    
    Write-Host " [6] Audio Action  : $audioAction"
    Write-Host " [7] Container     : $container"
    Write-Host ""
    Write-Host " [S] Start Optimization"
    Write-Host " [Q] Quit"
    Write-Host "=============================================" -ForegroundColor Cyan
}

# --- Main Menu Loop ---
$runningMenu = $true
$audioOptions = @("Copy", "AAC 128k", "AAC 192k", "AAC 256k", "Opus 128k", "Opus 192k", "AC3 384k", "AC3 640k")
$containerOptions = @("MP4", "MKV", "MOV", "Original")

while ($runningMenu) {
    Show-Menu
    $choice = Read-Host "Select an option"

    switch ($choice.ToUpper()) {
        "1" {
            $newFolder = Read-Host "Enter new target folder path"
            if (Test-Path $newFolder) { $targetFolder = (Resolve-Path $newFolder).Path }
            else { Write-Host "Invalid path!" -ForegroundColor Red; Start-Sleep -Seconds 1 }
        }
        "2" {
            $recursive = -not $recursive
        }
        "3" {
            Write-Host "`nAvailable Encoders (Ordered by modern/hardware preference):"
            foreach ($enc in ($availableEncoders | Sort-Object Rank)) {
                $status = if ($enc.Supported) { "[Supported]" } else { "[Not Found]" }
                Write-Host " $($enc.ID). $($enc.Name) $status"
            }
            $newEncId = Read-Host "Enter encoder ID"
            $selectedEnc = $availableEncoders | Where-Object ID -eq $newEncId
            if ($selectedEnc -and $selectedEnc.Supported) {
                $selectedEncoderId = $newEncId
                # Reset defaults for this encoder
                if ($selectedEnc.Codec -match "nvenc") { $preset = "p5" }
                elseif ($selectedEnc.Codec -match "libsvtav1") { $preset = "6" }
                elseif ($selectedEnc.Codec -match "qsv|amf") { $preset = "" }
                else { $preset = "slow" }
            } else {
                Write-Host "Invalid or unsupported encoder!" -ForegroundColor Red; Start-Sleep -Seconds 1
            }
        }
        "4" {
            Write-Host "Smart recommendation: '23,26,29' (Attempts 23 first, falls back to 26, then 29 if output is larger.)" -ForegroundColor Yellow
            $newQuality = Read-Host "Enter quality value or up to 3 comma-separated values"
            if ($newQuality -match '^\d+(\s*,\s*\d+){0,2}$') { $quality = $newQuality -replace '\s+', '' }
            else { Write-Host "Invalid input!" -ForegroundColor Red; Start-Sleep -Seconds 1 }
        }
        "5" {
            $preset = Read-Host "Enter preset"
        }
        "6" {
            $idx = [array]::IndexOf($audioOptions, $audioAction)
            $audioAction = $audioOptions[($idx + 1) % $audioOptions.Count]
        }
        "7" {
            $idx = [array]::IndexOf($containerOptions, $container)
            $container = $containerOptions[($idx + 1) % $containerOptions.Count]
        }
        "S" {
            $runningMenu = $false
        }
        "Q" {
            Write-Host "Exiting..."
            return
        }
    }
}

# --- Processing ---
$activeEnc = ($availableEncoders | Where-Object ID -eq $selectedEncoderId)
$videoCodec = $activeEnc.Codec
$mode = $activeEnc.Mode

Clear-Host
Write-Host "Starting Optimization..." -ForegroundColor Green
Write-Host "Target: $targetFolder (Recursive: $recursive)"
Write-Host "Encoder: $videoCodec | Quality ($mode): $quality"

$totalInBytes = 0
$totalOutBytes = 0
$processedCount = 0
$skippedCount = 0
$failedCount = 0

$files = if ($recursive) { Get-ChildItem -Path $targetFolder -File -Recurse } else { Get-ChildItem -Path $targetFolder -File }
$qualityList = $quality -split ','

foreach ($file in $files) {
    if ($file.Name -match "_backup") { continue }

    # Ignore Unoptimizable folder and its contents
    if ($file.DirectoryName -match "Unoptimizable") { continue }

    $input = $file.FullName
    $dir = $file.DirectoryName
    $name = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)

    Write-Host "`nChecking: $($file.Name)"

    # --- Fast Extension-based filtering ---
    $fileExt = $file.Extension.ToLower()
    if ($knownIgnoredExtensions -contains $fileExt) {
        Write-Host "⏭️ Skipped (known non-video extension: $fileExt)"
        $skippedCount++
        continue
    }

    if ($knownVideoExtensions -notcontains $fileExt) {
        Write-Host "🔍 Unknown extension '$fileExt', verifying with ffprobe..."
        $hasVideo = (ffprobe -v error -select_streams v -show_entries stream=index -of csv=p=0 "$input" | Out-String).Trim()
        $formatName = (ffprobe -v error -show_entries format=format_name -of default=nokey=1:noprint_wrappers=1 "$input" | Out-String).Trim()

        if ([string]::IsNullOrWhiteSpace($hasVideo) -or $formatName -match 'image|pipe|gif') {
            Write-Host "⏭️ Skipped (verified non-video file)"
            $knownIgnoredExtensions += $fileExt
            $skippedCount++
            continue
        } else {
            Write-Host "✅ Verified as video file. Added '$fileExt' to known video formats."
            $knownVideoExtensions += $fileExt
        }
    }

    # --- Detect codec ---
    $vCodec = (ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of csv=p=0 "$input" | Out-String).Trim()
    $aCodec = (ffprobe -v error -select_streams a:0 -show_entries stream=codec_name -of csv=p=0 "$input" | Out-String).Trim()

    if ($vCodec -match "hevc|av1") {
        Write-Host "⏭️ Skipped (already efficient codec: $vCodec)"
        $skippedCount++
        continue
    }

    Write-Host "🎬 Processing video: $($file.Name) [V:$vCodec, A:$aCodec]"

    # --- Smart Audio & Container Selection ---
    $finalExt = if ($container -eq "Original") { $file.Extension } else { ".$($container.ToLower())" }
    
    $targetAudioCodec = "copy"
    $targetAudioBitrate = ""
    $audioWarning = ""

    if ($audioAction -match "AAC") {
        $targetAudioCodec = "aac"
        $targetAudioBitrate = ($audioAction -replace '[^\d]', '') + "k"
    } elseif ($audioAction -match "Opus") {
        $targetAudioCodec = "libopus"
        $targetAudioBitrate = ($audioAction -replace '[^\d]', '') + "k"
    } elseif ($audioAction -match "AC3") {
        $targetAudioCodec = "ac3"
        $targetAudioBitrate = ($audioAction -replace '[^\d]', '') + "k"
    }

    if ($targetAudioCodec -eq "copy") {
        $incompatible = $false
        if ($finalExt -eq ".mp4") {
            if ($aCodec -notmatch "aac|mp3|opus|ac3|eac3|mp2|mp1") { $incompatible = $true }
        } elseif ($finalExt -eq ".mov") {
            if ($aCodec -notmatch "aac|mp3|ac3|eac3|alac|pcm") { $incompatible = $true }
        }

        if ($incompatible) {
            $targetAudioCodec = "aac"
            $targetAudioBitrate = "128k"
            $audioWarning = "⚠️ Source audio ($aCodec) is incompatible with $($finalExt.ToUpper()) container. Switched to AAC 128k for compatibility."
        }
    }

    if ($audioWarning) { Write-Host $audioWarning -ForegroundColor Yellow }

    $tempOutput = Join-Path $dir ($name + "_temp" + $finalExt)
    $finalOutput = Join-Path $dir ($name + $finalExt)
    $backup = Join-Path $dir ($name + "_backup" + $file.Extension)

    $success = $false
    $unoptimizable = $false
    $unoptReason = ""

    for ($i = 0; $i -lt $qualityList.Length; $i++) {
        $q = $qualityList[$i]
        if ($qualityList.Length -gt 1) { Write-Host "▶️ Pass $($i + 1)/$($qualityList.Length) with Quality: $q" -ForegroundColor Cyan }

        $ffArgs = @("-y")
        if ($videoCodec -match "nvenc") { $ffArgs += @("-hwaccel","cuda") }
        elseif ($videoCodec -match "qsv") { $ffArgs += @("-hwaccel","qsv") }

        $ffArgs += @("-i", $input, "-c:v", $videoCodec)

        switch ($mode) {
            "crf" { $ffArgs += @("-crf", $q) }
            "cq"  { $ffArgs += @("-cq", $q, "-b:v", "0") }
            "qp"  { $ffArgs += @("-qp", $q) }
            "global_quality" { $ffArgs += @("-global_quality", $q) }
        }

        if (-not [string]::IsNullOrWhiteSpace($preset)) { $ffArgs += @("-preset", $preset) }
        if ($videoCodec -match "nvenc") { $ffArgs += @("-spatial_aq","1","-aq-strength","8") }

        $ffArgs += @("-c:a", $targetAudioCodec)
        if ($targetAudioBitrate) { $ffArgs += @("-b:a", $targetAudioBitrate) }
        $ffArgs += @($tempOutput)

        $global:LASTEXITCODE = 0
        & ffmpeg @ffArgs
        $ffmpegExit = $global:LASTEXITCODE

        if ($ffmpegExit -ne 0) {
            Write-Host "❌ FFmpeg error (exit $ffmpegExit)"
            if (Test-Path -LiteralPath $tempOutput) { Remove-Item -LiteralPath $tempOutput -Force }
            $unoptimizable = $true
            $unoptReason = "FFmpeg error ($ffmpegExit)"
            break
        }

        # Stability check
        $fileReady = $false
        $elapsed = 0
        while ($elapsed -lt 5000) {
            if (Test-Path -LiteralPath $tempOutput) {
                $size1 = (Get-Item -LiteralPath $tempOutput).Length
                Start-Sleep -Milliseconds 200
                $size2 = (Get-Item -LiteralPath $tempOutput).Length
                if ($size1 -eq $size2 -and $size1 -gt 0) { $fileReady = $true; break }
            }
            Start-Sleep -Milliseconds 200; $elapsed += 200
        }

        if ($fileReady) {
            $outSize = (Get-Item -LiteralPath $tempOutput).Length
            $inSize  = (Get-Item -LiteralPath $input).Length
            Write-Host "📊 Original: $([math]::Round($inSize/1MB,2))MB | Output: $([math]::Round($outSize/1MB,2))MB"

            if ($outSize -gt 1MB) {
                try {
                    $inDur = [double]::Parse((ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$input"), [System.Globalization.CultureInfo]::InvariantCulture)
                    $outDur = [double]::Parse((ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$tempOutput"), [System.Globalization.CultureInfo]::InvariantCulture)
                    if ([math]::Abs($inDur - $outDur) -le 2) {
                        if ($outSize -lt $inSize) {
                            $success = $true; $totalInBytes += $inSize; $totalOutBytes += $outSize; break
                        } else {
                            Write-Host "⚠️ Output larger than source"
                            $unoptimizable = $true; $unoptReason = "Output larger than source"
                            if (Test-Path -LiteralPath $tempOutput) { Remove-Item -LiteralPath $tempOutput -Force }
                        }
                    } else {
                        Write-Host "⚠️ Duration mismatch"; $unoptimizable = $true; $unoptReason = "Duration mismatch"; break
                    }
                } catch {
                    Write-Host "⚠️ Validation failed"; $unoptimizable = $true; $unoptReason = "Validation exception"; break
                }
            } else {
                Write-Host "⚠️ Output too small"; $unoptimizable = $true; $unoptReason = "Output <1MB"; break
            }
        } else {
            Write-Host "❌ Timeout"; $unoptimizable = $true; $unoptReason = "File ready timeout"; break
        }
    }

    # Finalize
    if ($success) {
        Write-Host "🔁 Replacing safely..."
        try {
            Rename-Item -LiteralPath $input -NewName ([System.IO.Path]::GetFileName($backup)) -Force
            Move-Item -LiteralPath $tempOutput -Destination $finalOutput -Force
            Remove-Item -LiteralPath $backup -Force
            Write-Host "✅ Done"
            $processedCount++
        } catch {
            Write-Host "❌ Replacement failed"
            if (Test-Path -LiteralPath $backup) { Rename-Item -LiteralPath $backup -NewName $file.Name -Force }
            $failedCount++
        }
    } elseif ($unoptimizable) {
        if (Test-Path -LiteralPath $tempOutput) { Remove-Item -LiteralPath $tempOutput -Force }
        $unoptDir = Join-Path $dir "Unoptimizable"
        if (-not (Test-Path $unoptDir)) { New-Item -ItemType Directory -Path $unoptDir | Out-Null }
        Move-Item -LiteralPath $input -Destination (Join-Path $unoptDir $file.Name) -Force
        Write-Host "📁 Moved to Unoptimizable ($unoptReason)"
        $failedCount++
    } else {
        Write-Host "❌ Kept original"; $skippedCount++
    }
}

Write-Host "`nOPTIMIZATION COMPLETE. Saved: $([math]::Round(($totalInBytes - $totalOutBytes)/1MB,2)) MB"
