# Changelog

このプロジェクトの変更履歴です。形式は [Keep a Changelog](https://keepachangelog.com/ja/1.1.0/) に準じます。

## [Unreleased]

### Fixed
- `hosts.txt` の行末コメント（例: `https://qiita.com/ # test qiita`）を削除した後に残る前後の空白を取り除き、URL が不正になって `NO SSL` と誤判定される問題を修正 ([#2](https://github.com/ackcell/ssl-certification-expire-check/pull/2))
- `while read` に `IFS= read -r` を指定し、バックスラッシュが消えないように修正 ([#2](https://github.com/ackcell/ssl-certification-expire-check/pull/2))
- 変数を `"$1"` などでクォートし、`printf` の書式文字列に URL を渡さないように修正。URL に `%` を含んでも正しく出力される ([#2](https://github.com/ackcell/ssl-certification-expire-check/pull/2))
- `curl` の接続を 1 回にまとめ、結果を使い回すように変更 ([#2](https://github.com/ackcell/ssl-certification-expire-check/pull/2))
- 引数（`-u` / `-f`）が無い場合に usage を表示して終了するように変更 ([#2](https://github.com/ackcell/ssl-certification-expire-check/pull/2))

### Changed
- `curl` に `--max-time 30` を追加し、応答しないホストで停止しないように変更 ([#2](https://github.com/ackcell/ssl-certification-expire-check/pull/2))
- `usage_exit` の終了コードを 1 に戻し、`exit 0` を明示 ([#2](https://github.com/ackcell/ssl-certification-expire-check/pull/2))
- 冗長な `${DATE:-'date'} >/dev/null` 行を削除（直後の `--version` チェックで十分） ([#2](https://github.com/ackcell/ssl-certification-expire-check/pull/2))

### Known issues
- 接続失敗（443 番が閉じている等）と SSL 証明書の欠如を区別せず、どちらも `NO SSL` と出力する
- 負の日数（期限切れ）のときの `printf "%03d"` の出力が `-05` のようになり、`sort` の並びが崩れうる
- `checksingle` の戻り値は呼び出し側で使われていない（TODO: rc handling）

## [2021-12-23]

### Changed
- `checker.sh` の後処理を変更（[977c735](https://github.com/ackcell/ssl-certification-expire-check/commit/977c735)）
  - `checksingle` の戻り値を変更（有効期限なし: `return 5` → `return 2`、SSL 問題あり: `return 1` に明示）。呼び出し側では使われていない
  - `usage_exit` の終了コードを 1 から 99 に変更 ※ Unreleased で 1 に戻した
  - `exit 0` を `exit` に変更 ※ Unreleased で `exit 0` に戻した
  - 作業メモ用の `######` コメントを追加 ※ Unreleased で削除した

### Documentation
- README.md を Bitbucket 上で編集（[0e4c915](https://github.com/ackcell/ssl-certification-expire-check/commit/0e4c915)）

## [2021-12-22]

### Added
- SSL 証明書の有効期限を取得するシェルスクリプト `checker.sh` を追加（`-u` で単一 URL、`-f` でファイル指定）（[c40e9f7](https://github.com/ackcell/ssl-certification-expire-check/commit/c40e9f7)）
- テスト用 URL リスト `hosts.txt` を追加（[c40e9f7](https://github.com/ackcell/ssl-certification-expire-check/commit/c40e9f7)）
- README.md の使い方・出力例を追加（[c40e9f7](https://github.com/ackcell/ssl-certification-expire-check/commit/c40e9f7)）
- `.gitignore` を追加（[db8438d](https://github.com/ackcell/ssl-certification-expire-check/commit/db8438d)）
