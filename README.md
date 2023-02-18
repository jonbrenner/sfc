## Requirements

This is be a shell function in order to access the history. I looked into using go, but an external command doesn't have easy access to the history stored in the shell. Sometimes, the history is stored in memory and flushed to disk when the shell is closed, so reading it from a file doesn't really work.

- working on zsh
- working on bash
- it should use the "fc" command since it's more versatile and a POSIX standard

## Syntax

```
NAME

sfc - save a command from history to a markdown file

SYNOPSIS

sfc [-f FILE] [-c COMMENT] [n...]

DESCRIPTION

sfc creates a markdown formatted description of commands from shell history.

Output is sent to STDOUT if no file is passed via argument or environment variable. The user can supply a description for the comment at the command line. If not, they are prompted to add one interactively.

A command-separated list of indexes corresponding to the shell history is sent to the output. If no index is specified, the last command in history is used.

EXAMPLES

Prompt the user for a comment and add the comment and last command in history to the file in SPC_FILE environment variable.
SFC_FILE="${HOME}/cheat.md" sfc

Print the comment, command at 101, and each command from 90-95 to STDOUT. Commands are outputed in the order specified.
sfc -c "My comment." 101,90-95

```

