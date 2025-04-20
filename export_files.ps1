<#
.SYNOPSIS
  Creates output.txt containing an initial list of relative filenames
  (excluding script/output.txt), a delimiter, and then detailed blocks
  (path, newline, content, delimiter) for each file listed.

.DESCRIPTION
  1. Gets the name of the script file itself.
  2. Finds all files (-File) in the current directory *only* (-Depth 0).
  3. Filters this list to exclude the script file and 'output.txt'.
  4. Creates/overwrites 'output.txt'.
  5. Writes the header "Files:" to output.txt.
  6. Writes the relative path (e.g., ./filename.ext) for each *filtered* file to output.txt.
  7. Writes the first separator line "===" to output.txt.
  8. Iterates through the *same filtered list* of files again.
  9. For each file in the filtered list, appends the following to output.txt:
     - Its relative path (e.g., ./filename.ext)
     - A blank newline.
     - The full content of the file (read using Get-Content -Raw).
     - The separator line "===".
  10. Includes basic error handling for reading file content.

.NOTES
  Author: Your Name/AI Assistant
  Date:   2023-10-27
  - Overwrites 'output.txt' on each run.
  - Only lists/processes files, not directories.
  - Only searches the immediate current directory (-Depth 0).
  - Skips processing the script file itself and 'output.txt' in both the list and content sections.
  - Adds a blank line between the file path and its content in the detailed blocks.
  - Uses UTF8 encoding for the output file.
  - Uses Get-Content -Raw to preserve file content formatting.
  - Large files might consume memory with Get-Content -Raw.
#>

# Define the output file name and delimiter
$OutputFileName = "output.txt"
$Delimiter = "==="
$Header = "Files:"

# Get the name of the currently running script
$ScriptName = $MyInvocation.MyCommand.Name

# Get the current directory for clarity in messages
$CurrentDirectory = $PWD.Path

Write-Host "Starting file export process in directory: $CurrentDirectory"
Write-Host "Output file: $OutputFileName"
Write-Host "Script file (will be skipped): $ScriptName"
Write-Host "Searching current directory only (Depth 0)."

# --- Step 1: Get ALL file objects from the current directory ONLY ---
$AllFiles = Get-ChildItem -File -Depth 0 -ErrorAction SilentlyContinue

if ($null -eq $AllFiles) {
    Write-Warning "No files found in the current directory: $CurrentDirectory"
    # Create an empty file with just the header if needed (no files to list)
    $Header | Out-File -FilePath $OutputFileName -Encoding UTF8 -Force
    Write-Host "Created empty '$OutputFileName' with header."
    exit
}

# --- Step 2: Filter the list to exclude self and output file ---
Write-Host "Filtering file list (excluding '$ScriptName' and '$OutputFileName')..."
$FilesToProcess = $AllFiles | Where-Object { $_.Name -ne $ScriptName -and $_.Name -ne $OutputFileName }

if ($null -eq $FilesToProcess -or $FilesToProcess.Count -eq 0) {
    Write-Warning "No files found to process (after excluding script and output file)."
    # Write header and first delimiter using a proper array for piping
    # FIX: Use @($Header, $Delimiter) instead of ($Header; $Delimiter)
    @($Header, $Delimiter) | Out-File -FilePath $OutputFileName -Encoding UTF8 -Force
    Write-Host "Created '$OutputFileName' with header and delimiter, but no files were processed."
    exit
} # <-- This closing brace was likely missed by the parser due to the error above it

$FileCount = $FilesToProcess.Count
Write-Host "Found $FileCount file(s) to include in the output."

# --- Step 3: Write the initial block (Header, Filtered List, Delimiter) ---
# This overwrites the output file using the reliable & { ... } method
Write-Host "Writing initial file list to '$OutputFileName'..."
& {
    $Header
    # Generate relative paths for the initial list using the filtered collection
    $FilesToProcess | ForEach-Object { "./$($_.Name)" }
    $Delimiter # First delimiter after the list
} | Out-File -FilePath $OutputFileName -Encoding UTF8 -Force

# --- Step 4: Iterate through the FILTERED list AGAIN to append detailed blocks ---
Write-Host "Appending file paths, content, and delimiters for $FileCount file(s)..."
foreach ($File in $FilesToProcess) { # Iterate through the SAME filtered list
    $RelativePath = "./$($File.Name)"
    Write-Verbose "Processing and appending details for: $RelativePath"

    # 1. Append the relative path
    $RelativePath | Out-File -FilePath $OutputFileName -Encoding UTF8 -Append

    # 2. Append a blank newline for spacing
    "" | Out-File -FilePath $OutputFileName -Encoding UTF8 -Append

    # 3. Append the file content (with error handling)
    try {
        Get-Content -Path $File.FullName -Raw -ErrorAction Stop | Out-File -FilePath $OutputFileName -Encoding UTF8 -Append
    } catch {
        $ErrorMessage = "`n### ERROR READING FILE '$($File.FullName)': $($_.Exception.Message) ###`n"
        Write-Warning ("Error reading file '{0}': {1}" -f $File.FullName, $_.Exception.Message)
        $ErrorMessage | Out-File -FilePath $OutputFileName -Encoding UTF8 -Append
    }

    # 4. Append the delimiter
    $Delimiter | Out-File -FilePath $OutputFileName -Encoding UTF8 -Append
}

Write-Host "Script finished. '$OutputFileName' has been created/updated in $CurrentDirectory."