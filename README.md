# ai-dotfiles

## スキル

`skills/` 直下の各ディレクトリを、`~/.codex/skills/` と `~/.claude/skills/` へ同名のシンボリックリンクとして同期する。
このリポジトリを指すリンクのうち、リンク先がなくなったものは同期時に削除する。
通常ファイル、通常ディレクトリ、別のリンクと競合する場合は上書きせずに終了する。

```bash
# リンクの作成・削除内容を確認する
./scripts/link-skills.sh --dry-run

# リンクを同期する
./scripts/link-skills.sh
```

## ~/.codex/config.toml / hooks.json

信用済みのディレクトリがconfig.tomlに追記されるが、機微な名前を含むディレクトリの露出防止のため以下の手順になっている。

```bash
# backup & generate
./codex-config/generate-config.sh

# diff (信頼済みプロジェクトをよしなにコピペ)
diff ./codex-config/backup/config.toml ./codex-config/dist/config.toml
diff ./codex-config/backup/hooks.json ./codex-config/dist/hooks.json

# apply
cp ./codex-config/dist/config.toml ~/.codex/config.toml
cp ./codex-config/dist/hooks.json ~/.codex/hooks.json
```

## ~/.codex/rules/default.rules

```bash
./codex-config/link-rules.sh
```

## 関連リポジトリ

- https://github.com/stoneream/toolbox
