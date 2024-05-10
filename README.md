## Installation

1. Install & start [Karabiner Elements](https://karabiner-elements.pqrs.org/)
1. Clone this repository
1. Delete the default `~/.config/karabiner` folder
1. Create a symlink with `ln -s ~/github/mxstbr/karabiner ~/.config` (where `~/github/mxstbr/karabiner` is your local path to where you cloned the repository)
1. [Restart karabiner_console_user_server](https://karabiner-elements.pqrs.org/docs/manual/misc/configuration-file-path/) with ``launchctl kickstart -k gui/`id -u`/org.pqrs.karabiner.karabiner_console_user_server``

## Development

```
npm run build
```

builds the `karabiner.json` from the `rules.ts`.

```
npm run watch
```

watches the TypeScript files and rebuilds whenever they change.

typing and base model shamelessly stolen from https://github.com/mxstbr/karabiner