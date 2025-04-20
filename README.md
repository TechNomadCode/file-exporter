# Simple File Consolidator (PowerShell)

This PowerShell script gathers files directly from the *current directory* where it is executed, filters out the script file itself and the designated output file (`output.txt`), and concatenates their paths and contents into that single output file.

This is a simpler alternative to Git-based consolidation, useful when you only need to package files from a single, flat directory.

## Features

*   Scans the current directory only (`-Depth 0`).
*   Processes only files, not directories.
*   Automatically excludes the script file itself and the output file (`output.txt` by default).
*   Generates a single output file (`output.txt`) containing:
    *   A header (`Files:` by default).
    *   A list of relative paths (`./filename.ext`) of all included files.
    *   A separator (`===`).
    *   The full content of each included file, preceded by its relative path and separated by the separator.
*   Overwrites the output file on each run.
*   Uses `Get-Content -Raw` to preserve file content formatting.
*   Uses UTF8 encoding for the output file.
*   Includes basic error handling for reading file content.

## Prerequisites

*   **PowerShell:** Version 5.1 or later recommended. (Git is *not* required for this script).

## Usage

1.  **Save the script:** Save the PowerShell script code to a file, for example, `consolidate_current_dir.ps1`.
2.  **Place files:** Ensure the files you want to consolidate are in the *same directory* as the script.
3.  **Navigate:** Open PowerShell or Windows Terminal and change the directory (`cd`) to where you saved the script and the files.
4.  **Run the script:** Execute the script using:
    ```powershell
    .\consolidate_current_dir.ps1
    ```
    *(Replace `consolidate_current_dir.ps1` with the actual name you saved the script as).*
5.  **Check the output:** A file named `output.txt` (by default) will be created or overwritten in the same directory, containing the consolidated file list and contents.

## Output File Format (`output.txt`)

The generated `output.txt` file has the following structure:

```
Files:
./some_file.txt
./another_script.ps1
./config.json
===
./some_file.txt

<Content of some_file.txt>
===
./another_script.ps1

<Content of another_script.ps1>
===
./config.json

<Content of config.json>
===
```

## Customization

*   **Output File Name, Delimiter, Header:** Modify the `$OutputFileName`, `$Delimiter`, and `$Header` variables at the beginning of the script.
    ```powershell
    $OutputFileName = "packaged_files.txt"
    $Delimiter = "--- FILE BREAK ---"
    $Header = "Included Files:"
    ```
*   **Filtering:** To add more complex filtering (e.g., exclude specific file types), modify the `Where-Object` clause that creates the `$FilesToProcess` variable.

## Limitations

*   Only processes files in the immediate directory where the script is run. It does not search subdirectories.
*   Does not sort the files; the order depends on the output of `Get-ChildItem`.
*   Filtering is basic (only excludes self and output).

## License

This project is licensed under the MIT License - see the LICENSE.md(LICENSE) file for details.
