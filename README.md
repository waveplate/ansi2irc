# ansi2irc

**ansi2irc** is a powerful, bidirectional converter between IRC control codes and ANSI SGR escape sequences. It is designed to handle complex ANSI art with a lightweight Virtual Terminal state machine, ensuring that cursor movements and screen clears are correctly translated into a streamable IRC format.

## Features

*   **Bidirectional Conversion:** Converts ANSI to IRC (`ansi2irc`) and IRC to ANSI (`irc2ansi`).
*   **Auto-Detection:** Automatically detects the input format to determine the conversion direction.
*   **High-Fidelity Color Matching:**
    *   Uses a fast, cached lookup table to map between IRC's 99-color palette and ANSI's 256-color palette.
    *   Separates chroma from luma in color matching to preserve grayscales and vivid colors accurately.
    *   Supports Truecolor (24-bit) ANSI input by downsampling to the nearest available palette color.
    *   Optionally outputs Truecolor (24-bit) ANSI from IRC input for exact color reproduction (`--truecolor`).
*   **Virtual Terminal Emulator:** Includes a lightweight VT emulator to handle cursor positioning (`H`, `f`, `A`, `B`, `C`, `D`), screen clearing (`J`), and line clearing (`K`) sequences, flattening complex ANSI animations or art into a line-by-line format suitable for IRC.
*   **Encoding Support:** Explicit support for CP437 (commonly used in ANSI art) and other encodings.

## Installation

`ansi2irc` is a standalone Python 3 script with no external dependencies.

### Automated Install

You can install the script and the `irc2ansi` alias automatically to `~/.local/bin` (ensure this is in your `$PATH`):

```bash
curl -s https://raw.githubusercontent.com/waveplate/ansi2irc/develop/install.sh | bash
```

### Manual Install

```bash
wget -q https://raw.githubusercontent.com/waveplate/ansi2irc/develop/ansi2irc -O ~/.local/bin/ansi2irc
chmod +x ~/.local/bin/ansi2irc
ln -sf ~/.local/bin/ansi2irc ~/.local/bin/irc2ansi
```

This will download the `ansi2irc` script to your local bin directory, make it executable, and symlink `irc2ansi` to it for convenience

## Usage

Reads from standard input (stdin) or a file, and writes to standard output (stdout).

```bash
# Convert a file and print to stdout
ansi2irc art.ans

# Pipe output to another tool
ansi2irc art.ans | irccat

# Convert IRC logs to display in terminal
cat irc.log | ansi2irc -d ansi
```

### Command Line Arguments

```text
usage: ansi2irc [-h] [-d {irc,ansi,auto}] [-t TOLERANCE] [-e ENCODING]
                [--cp437] [-w WIDTH] [-c] [-r]
                [file]

Convert between ANSI SGR and IRC color/control codes

positional arguments:
  file                  Input file (default: stdin)

options:
  -h, --help            show this help message and exit
  -d, --direction {irc,ansi,auto}
                        Conversion direction (target format).
                        'irc': ANSI -> IRC
                        'ansi': IRC -> ANSI
                        'auto': Detect based on content (default)
  -t TOLERANCE, --tolerance TOLERANCE
                        Grayscale tolerance for chroma separation (default: 16)
  -e ENCODING, --encoding ENCODING
                        Input encoding (e.g., utf-8, latin1)
  --cp437               Force CP437 encoding (optimized for ANSI art)
  -w WIDTH, --width WIDTH
                        Wrap width for ansi2irc (default: 80 if --cp437 is set,
                        otherwise unlimited)
  --truecolor           Use 24-bit Truecolor ANSI output instead of 256-color
                        palette
  -c, --no-cache        Do not read/write color lookup cache
  -r, --rebuild         Force rebuild of color lookup tables
```

## Examples

**Viewing legacy ANSI art on IRC:**
```bash
ansi2irc --cp437 blocks.ans
```

**Previewing an IRC message in your terminal:**
```bash
printf "\x0304Hello \x02World\x0F" | irc2ansi
```

## Technical Details

### Color Mapping
The tool generates a mapping between the standard 99-color IRC palette and the Xterm 256-color palette. To ensure the best visual results, it calculates the Euclidean distance between colors but applies a special "chroma vs. luma" protection:
*   **Grayscale Protection:** If a source color is neutral (gray), it will only map to a target color that is also neutral. This prevents gray blocks from turning into muddy brown or dark blue.
*   **Caching:** Because generating these maps involves checking thousands of combinations, the result is cached in `~/.cache/ansi2irc/lookup.json` (or strictly `$XDG_CACHE_HOME`).

### Supported Codes
*   **IRC:** Color (`^C`), Bold (`^B`), Underline (`^_`), Reverse (`^V`), Italic (`^]`), Reset (`^O`)
*   **ANSI:**
    *   Reset (`0`), Bold (`1`), Italic (`3`), Underline (`4`), Reverse (`7`)
    *   Foreground/Background colors: Standard (30-37, 40-47), Bright (90-97, 100-107), 256-color (`38;5;n`), Truecolor (`38;2;r;g;b`)
    *   Cursor movement: Up/Down/Right/Left (`A`,`B`,`C`,`D`), Position (`H`,`f`), Save/Restore (`s`,`u`)
    *   Erasing: Display (`J`), Line (`K`)
