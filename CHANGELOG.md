# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[unreleased]: https://github.com/chvolkmann/code-connect/compare/v0.2.1...HEAD
[0.2.1]: https://github.com/chvolkmann/code-connect/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/chvolkmann/code-connect/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/chvolkmann/code-connect/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/chvolkmann/code-connect/releases/tag/v0.1.0
