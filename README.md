# Live Editor CLI

[![Build Status](https://secure.travis-ci.org/liveeditor/liveeditor_cli.svg?branch=master)](http://travis-ci.org/liveeditor/liveeditor_cli)

A command line interface for building, previewing, and syncing your Live Editor
theme.

## System Requirements

Ruby 2.1+

## Installation

To install Live Editor CLI, run this command:

```bash
$ gem install liveeditor_cli
```

## Common Commands

```bash
$ liveeditor new TITLE            # Generate a new theme in a subfolder based on
                                  # TITLE.

$ liveeditor login                # Log in to the Live Editor service.

$ liveeditor generate SUBCOMMAND  # Generate a layout, content template, or
                                  # navigation menu.
                                  #
                                  # Valid SUBCOMMANDs:
                                  # -  layout
                                  # -  content_template
                                  # -  navigation

$ liveeditor validate [TARGET]    # Validate that theme is implemented
                                  # correctly.
                                  #
                                  # Optional TARGETs:
                                  # -  all (default)
                                  # -  assets
                                  # -  config
                                  # -  content_templates
                                  # -  layouts
                                  # -  navigation
                                  # -  theme

$ liveeditor server               # Run a development server for previewing your
                                  # theme.

$ liveeditor push                 # Validate and push theme files to Live Editor
                                  # for publication.

$ liveeditor help [COMMAND]       # Instructions for all commands (or optionally
                                  # details about a single COMMAND).
```

For a complete list of commands and options, refer to the
[Live Editor CLI Reference Guide][1].

## License

The MIT License (MIT)

* Copyright © 2016 Minimal Orange, LLC


[1]: http://www.liveeditorcms.com/support/designers/themes/cli-reference/
