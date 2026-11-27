# ai-dotfiles

## スキル

`skills/` 直下にある `SKILL.md` を含む各ディレクトリを、`~/.agents/skills/`、`~/.codex/skills/`、`~/.claude/skills/` へ同名のシンボリックリンクとして同期する。
Codex の現在の標準探索先は `~/.agents/skills/` とし、`~/.codex/skills/` は既存環境との互換用に維持する。
このリポジトリを指すリンクのうち、リンク先がなくなったものは同期時に削除する。
通常ファイル、通常ディレクトリ、別のリンクと競合する場合は上書きせずに終了する。

```bash
# リンクの作成・削除内容を確認する
./scripts/link-skills.sh --dry-run

# リンクを同期する
./scripts/link-skills.sh
```

## Claudeの設定

`~/.claude/settings.json` と `.claude/settings.json` の間で `permissions`、`hooks`、`sandbox` を同期する。
`permissions.allow` 内の `mcp__*` エントリは環境固有のため、同期時に自動で除外・保持される。

```bash
# ~/.claude/settings.json → リポジトリへ取り込む (pull)
./scripts/sync-claude-settings.sh --dry-run
./scripts/sync-claude-settings.sh

# リポジトリ → ~/.claude/settings.json へ反映する (push)
./scripts/apply-claude-settings.sh --dry-run
./scripts/apply-claude-settings.sh
```

## リンク検査

リポジトリ全体のリンクを検査するには、[mise](https://mise.jdx.dev/) をインストールし、リポジトリルートで次を実行する。

```bash
mise run lint:links
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
