# fish-walkthrough

`fish-walkthrough` is a [Fish shell](https://fishshell.com/) plugin to make
running shell scripts, that might go wrong, easy!


## Why?

I used to have a collection of shell scripts for sysadmin. However, often,
something would go wrong in the middle of the script, and I'd have to manually
copy-paste each command from the script, and possibly adding other commands in
between.

With `fish-walkthrough`, the process of copy-pasting is automated, and applying
interventions is easy.

## Installation

The entire plugin consists of three files:

- `functions/walkthrough.fish`: the actual script
- `completions/walkthrough.fish`: autocomplete for the command
- `conf.d/walkthrough-binds.fish`: default keybindings for the command (optional)

To install, just make sure they end up in your Fish config directory. For
example, with Fisher:

```shell
fisher install stag-enterprises/walkthrough
```

## Usage

- Start a script: `walkthrough script.sh`
- Put the next command onto the command line: `walkthrough -n (or --next)`
- Put the Nth next command onto the command line: `walkthrough -n N`
- Go back: `walkthrough -b N (or --back)`
- Repeat the same command: `walkthrough -a (or --again)`
- Go to the Nth command: `walkthrough -g N (or --goto)`
- List the current command and the 4 commands around it: `walkthrough -l (or --list)`
- Use fzf to select a command to run: `walkthrough -s (or --select)`
- Reset: `walktrough -r (or --reset)`
- Get the current script: `walkthrough -w (or --which)`
- Get the current command number: `walkthrough -e (or --where)`
- Autopilot (run until exit code 1): `walkthrough -p`

## Keybinds

- Next: `Alt-,`
- Back: `Alt-.`
- List: `Alt-/`
- Again: `Alt-;`
- Select: `Alt-'`
