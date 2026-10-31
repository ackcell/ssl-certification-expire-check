# Changelog

All notable changes to this project are documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Fixed
- Trim leading and trailing whitespace after stripping inline comments from `hosts.txt` lines (e.g. `https://qiita.com/ # test qiita`). Previously the trailing space was passed into the URL, causing a false `NO SSL` result ([#2](https://github.com/ackcell/ssl-certification-expire-check/pull/2))
- Use `IFS= read -r` when reading `hosts.txt` so backslashes are preserved ([#2](https://github.com/ackcell/ssl-certification-expire-check/pull/2))
- Quote variables (`"$1"`, `"$line"`) and stop passing URLs as `printf` format strings, so URLs containing `%` are printed correctly ([#2](https://github.com/ackcell/ssl-certification-expire-check/pull/2))
- Show usage and exit when neither `-u` nor `-f` is given ([#2](https://github.com/ackcell/ssl-certification-expire-check/pull/2))

### Changed
- Make a single `curl` request per URL and reuse its verbose output ([#2](https://github.com/ackcell/ssl-certification-expire-check/pull/2))
- Add `--max-time 30` to `curl` so unresponsive hosts do not block the run ([#2](https://github.com/ackcell/ssl-certification-expire-check/pull/2))
- Restore exit code 1 for `usage_exit` and set `exit 0` explicitly ([#2](https://github.com/ackcell/ssl-certification-expire-check/pull/2))
- Remove the redundant `${DATE:-'date'} >/dev/null` line; the `--version` check that follows is sufficient ([#2](https://github.com/ackcell/ssl-certification-expire-check/pull/2))

### Known issues
- A connection failure (e.g. port 443 closed) and a missing SSL certificate are both reported as `NO SSL`.
- For expired certificates (negative remaining days), `printf "%03d"` outputs values like `-05`, which breaks `sort` ordering.
- The return value of `checksingle` is not used by the caller (TODO: rc handling).

## [2021-12-23]

### Changed
- Post-processing changes in `checker.sh` ([977c735](https://github.com/ackcell/ssl-certification-expire-check/commit/977c735)):
  - `checksingle` return values changed: no expiry date `return 5` → `return 2`; SSL problem now explicitly `return 1`. The caller does not use these values.
  - `usage_exit` exit code changed from 1 to 99 (reverted to 1 in Unreleased).
  - `exit 0` changed to `exit` (reverted to `exit 0` in Unreleased).
  - Added `######` working-note comments (removed in Unreleased).

### Documentation
- README.md edited online on Bitbucket ([0e4c915](https://github.com/ackcell/ssl-certification-expire-check/commit/0e4c915)).

## [2021-12-22]

### Added
- `checker.sh`: shell script that fetches SSL certificate expiry dates; `-u` for a single URL, `-f` for a file of URLs ([c40e9f7](https://github.com/ackcell/ssl-certification-expire-check/commit/c40e9f7)).
- `hosts.txt`: sample list of test URLs ([c40e9f7](https://github.com/ackcell/ssl-certification-expire-check/commit/c40e9f7)).
- README.md with usage and sample output ([c40e9f7](https://github.com/ackcell/ssl-certification-expire-check/commit/c40e9f7)).
- `.gitignore` ([db8438d](https://github.com/ackcell/ssl-certification-expire-check/commit/db8438d)).
