# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

Maybe your next idea?

## [0.3.0] - 2021-02-18

### Added

- bash uninstaller

### Changed

- `code-connect` is now not just one alias anymore, but two aliases.

  - The `code-connect` alias is added functionality of this repo, it points to `code_connect.py`
  - The `code` alias checks whether `code` is in the PATH and omits using `code-connect` in this case. This is useful for the integrated terminal as a `code` executable is injected by VS Code into the PATH. Thus, `code` should just run that existing executable, not `code-connect` instead.

    See [#8](https://github.com/chvolkmann/code-connect/issues/8)

- bash installer is now fancy
- All bash-related files are now in the `bash/` folder
- All `code_connect.py` is now in the `bin/` folder
- Fisher installation logic ([#10](https://github.com/chvolkmann/code-connect/pull/10))

## [0.2.2] - 2021-02-16

### Added

- Code styling with black, isort and flake8
- Poetry for managing code style dev dependencies
- CI with Github Actions
- Bash installation script
- More docs on code_connect.py

## [0.2.1] - 2021-02-15

- Integrates [#4](https://github.com/chvolkmann/code-connect/pull/4)

### Changed

- Created a `functions` folder and put `code_connect.py` into it. This lets [fisher](https://github.com/jorgebucaran/fisher#creating-a-plugin) discover it and copy it when installing. `code.fish` provides the alias.

## [0.2.0] - 2021-02-15

- Integrates [#2](https://github.com/chvolkmann/code-connect/pull/2)

### Changed

- `source` was used to make `code` available through `code_connect.py`, which only output a shell string.

  Now, `code_connect.py` is a direct wrapper around `code` and calls it as a subprocess. Thus, `code_connect.py` can ne be used as an alias for `code`. No need to `activate` anything first.

- Scanning for a valid IPC socket is now done any time `code` is called.

### Fixed

- `code` doesn't use stale IPC sockets anymore.

## [0.1.1] - 2021-02-14

- Integrates [#1](https://github.com/chvolkmann/code-connect/pull/1)

### Fixed

- Now raises an error when the `socat` binary cannot be found (#1)

## [0.1.0] - 2021-02-13

### Added

- Initial release of `code-connect` and the corresponding fish plugin

[unreleased]: https://github.com/chvolkmann/code-connect/compare/v0.3.0...HEAD
[0.3.0]: https://github.com/chvolkmann/code-connect/compare/v0.2.2...v0.3.0
[0.2.2]: https://github.com/chvolkmann/code-connect/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/chvolkmann/code-connect/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/chvolkmann/code-connect/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/chvolkmann/code-connect/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/chvolkmann/code-connect/releases/tag/v0.1.0
