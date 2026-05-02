# MIT License
# Copyright (c) 2026 Bishnu Mahali
# See LICENSE file in the repository root for full license text.

# --- Force Encoder Selection ---
do {
    Write-Host "`nSelect Encoding Type:"
    Write-Host "1. HEVC (CPU - libx265)"
    Write-Host "2. NVENC HEVC (NVIDIA)"
    Write-Host "3. AMD HEVC (AMF)"
    Write-Host "4. AV1 SVT (CPU)"
    Write-Host "5. NVIDIA AV1 (NVENC)"
    Write-Host "6. AMD AV1 (AMF)"

    $encChoice = Read-Host "Enter choice (1-6)"

    if ($encChoice -notmatch '^[1-6]$') {
        Write-Host "❌ Invalid selection."
        $validEnc = $false
    } else {
        $validEnc = $true
    }
} while (-not $validEnc)

# --- Map encoder ---
switch ($encChoice) {
    "1" { $videoCodec = "libx265";   $mode = "crf" }
    "2" { $videoCodec = "hevc_nvenc"; $mode = "cq" }
    "3" { $videoCodec = "hevc_amf";   $mode = "qp" }
    "4" { $videoCodec = "libsvtav1";  $mode = "crf" }
    "5" { $videoCodec = "av1_nvenc";  $mode = "cq" }
    "6" { $videoCodec = "av1_amf";    $mode = "qp" }
}

Write-Host "`nUsing encoder: $videoCodec"

# --- Check encoder availability ---
$encoders = ffmpeg -encoders 2>&1 | Out-String
if ($encoders -notmatch $videoCodec) {
    Write-Host "❌ Encoder '$videoCodec' not found in your FFmpeg build."
    exit
}

# --- Force quality input ---
do {
    $quality = Read-Host "Enter quality value (recommended 18–30)"

    if ([string]::IsNullOrWhiteSpace($quality) -or -not ($quality -match '^\d+$')) {
        Write-Host "❌ Invalid number."
        $validQ = $false
    } else {
        $validQ = $true
    }
} while (-not $validQ)

# --- Optional preset ---
$preset = ""
if ($videoCodec -in @("libx265","hevc_nvenc","libsvtav1","av1_nvenc")) {
    $preset = Read-Host "Enter preset (e.g. slow, medium, fast, p5) or press Enter to skip"
}

Get-ChildItem -File | ForEach-Object {

    $input = $_.FullName
    $dir = $_.DirectoryName
    $name = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)

    $tempOutput = Join-Path $dir ($name + "_temp.mkv")
    $finalOutput = Join-Path $dir ($name + ".mkv")
    $backup = Join-Path $dir ($name + "_backup" + $_.Extension)

    Write-Host "`nChecking: $($_.Name)"

    # --- Detect video ---
    $hasVideo = (ffprobe -v error -select_streams v `
        -show_entries stream=index -of csv=p=0 "$input" | Out-String).Trim()

    if ([string]::IsNullOrWhiteSpace($hasVideo)) {
        Write-Host "⏭️ Skipped (not a video file)"
        return
    }

    Write-Host "🎬 Processing video: $($_.Name)"

    # --- Detect codec ---
    $codec = (ffprobe -v error -select_streams v:0 `
        -show_entries stream=codec_name -of csv=p=0 "$input" | Out-String).Trim()

    if ($codec -in @("hevc","av1")) {
        Write-Host "⏭️ Skipped (already efficient codec)"
        return
    }

    # --- Build FFmpeg args dynamically ---
    $ffArgs = @("-y")

    if ($videoCodec -match "nvenc") {
        $ffArgs += @("-hwaccel","cuda")
    }

    $ffArgs += @("-i", $input, "-c:v", $videoCodec)

    switch ($mode) {
        "crf" { $ffArgs += @("-crf", $quality) }
        "cq"  { $ffArgs += @("-cq", $quality, "-b:v", "0") }
        "qp"  { $ffArgs += @("-qp", $quality) }
    }

    if ($preset -ne "") {
        $ffArgs += @("-preset", $preset)
    }

    # NVENC extras
    if ($videoCodec -match "nvenc") {
        $ffArgs += @("-spatial_aq","1","-aq-strength","8")
    }

    # Audio
    $ffArgs += @("-c:a","aac","-b:a","128k",$tempOutput)

    # --- Run ---
    & ffmpeg @ffArgs

    $ffmpegExit = $LASTEXITCODE
    Start-Sleep -Milliseconds 500

    $success = $false
    $unoptimizable = $false
    $unoptReason = ""

    if ($ffmpegExit -ne 0) {
        Write-Host "❌ FFmpeg error"
        if (Test-Path $tempOutput) { Remove-Item $tempOutput -Force }
        $unoptimizable = $true
        $unoptReason = "FFmpeg failed"
    }

    elseif (Test-Path $tempOutput) {

        $outSize = (Get-Item $tempOutput).Length
        $inSize  = (Get-Item $input).Length

        if ($outSize -lt $inSize) {
            $success = $true
        } else {
            $unoptimizable = $true
            $unoptReason = "Output larger"
        }
    }

    # --- Finalize ---
    if ($success) {
        Write-Host "🔁 Replacing safely..."
        try {
            Rename-Item -LiteralPath $input -NewName ([System.IO.Path]::GetFileName($backup))
            Move-Item $tempOutput $finalOutput -Force
            Remove-Item $backup -Force
            Write-Host "✅ Done"
        } catch {
            Write-Host "❌ Failed restore"
        }
    }
    elseif ($unoptimizable) {
        if (Test-Path $tempOutput) { Remove-Item $tempOutput -Force }

        $unoptDir = Join-Path $dir "Unoptimizable"
        if (-not (Test-Path $unoptDir)) { New-Item -ItemType Directory -Path $unoptDir | Out-Null }

        Move-Item $input (Join-Path $unoptDir $_.Name) -Force
        Write-Host "📁 Moved to Unoptimizable"
    }
    else {
        Write-Host "❌ Kept original"
    }
}


def is_prime(n):
