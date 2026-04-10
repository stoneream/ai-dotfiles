# ai-dotfiles

## スキル

```bash
# 実行内容のドライラン
./skills/link-skills.sh --dry-run

# skills/* を ~/.codex/skills/* と ~/.claude/skills/* にリンクする
./skills/link-skills.sh
```

## ~/.codex/config.toml

信用済みのディレクトリがconfig.tomlに追記されるが、機微な名前を含むディレクトリの露出防止のため以下の手順になっている。

```bash
# backup & generate
./codex-config/generate-config.sh

# diff (信頼済みプロジェクトをよしなにコピペ)
diff ~/.codex/config.toml ./codex-config/backup-config.toml

# apply
cp ./codex-config/config.toml ~/.codex/config.toml
```
