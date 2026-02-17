# CI/CD ガイド

このドキュメントでは、このリポジトリの GitHub Actions を使用した自動ビルド・リリースプロセスについて説明します。

## ワークフロー概要

このプロジェクトには1つのワークフロー（`.github/workflows/release-default.yml`）が定義されています。

### release-default.yml

**目的**: バージョンタグがプッシュされたときに、自動で Docker イメージをビルドして Dockerhub にリリースします。

**トリガー条件**:
- `v[0-9]+.[0-9]+.[0-9]+` 形式のタグが push されたとき
  - 例: `v1.2.3`, `v1.29.2` など

**実行される処理**:
1. リポジトリをチェックアウト
2. タグからバージョン番号を抽出（`v1.2.3` → `1.2.3`）
3. Dockerhub にログイン
4. Docker イメージをビルド＆プッシュ
   - イメージ名: `procube/nginx-modsec-builder:1.2.3`
5. README.md を Dockerhub の Description に同期

---

## 使用方法

### 1. 前提条件：Docker Hubのシークレット設定

GitHub Actions ワークフローを実行するには、Dockerhub 認証情報を GitHub Secrets に登録する必要があります。

**GitHub側の設定手順**:
1. GitHub リポジトリの [Settings] → [Secrets and variables] → [Actions] に移動
2. 以下の2つのシークレットを新規作成:
   - `DOCKER_USERNAME`: Dockerhub のユーザー名
   - `DOCKER_PASSWORD`: Dockerhub のパスワード（またはAccess Token）

> **注意**: Dockerhub に認証情報を新規作成する場合は、**「Read, Write, Delete」権限**を持つAccess Tokenの使用を推奨します。

---

### 2. リリースの実行

#### ステップ1：ローカルでコミット・プッシュ

```bash
# コード変更をコミット
git add .
git commit -m "Update ModSecurity configuration"

# mainブランチにプッシュ
git push origin main
```

※ この時点では GitHub Actions は実行されません。

#### ステップ2：タグを作成してプッシュ

```bash
# バージョンタグを作成（例: v1.29.2）
git tag v1.29.2

# タグをリモートにプッシュ
git push origin v1.29.2
```

※ タグをリモートにプッシュした時点で GitHub Actions が自動で実行されます。

---

### 3. ワークフロー実行状況の確認

1. GitHub リポジトリの **Actions** タブを開く
2. **"release apps"** という名前のワークフロー実行を確認
3. ステップごとの実行状況・ログを確認可能

---

## 既存タグの再実行

同じタグで再度ビルド・リリースしたい場合（Dockerfile を修正した場合など）:

```bash
# ローカルでタグを削除
git tag -d v1.29.2

# リモートのタグも削除
git push origin :refs/tags/v1.29.2

# 改めてタグを作成・プッシュ
git tag v1.29.2
git push origin v1.29.2
```

---

## トラブルシューティング

### ワークフローが実行されない

**原因**: タグが既にリモートに存在し、新しい変更が反映されていない。

**解決方法**: 上記「既存タグの再実行」に従ってタグを削除・再作成してください。

### Dockerhub へのプッシュに失敗する

**原因**: GitHub Secrets に登録した認証情報が不正または Access Token 権限が不足しています。

**確認事項**:
- `DOCKER_USERNAME` と `DOCKER_PASSWORD` が正しく設定されているか
- Access Token を使用している場合、**「Read, Write, Delete」権限**があるか
- Dockerhub のアカウントがリポジトリ（`procube/nginx-modsec-builder`）に対して書き込み権限を持っているか

---

## 参考資料

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Build and Push Action](https://github.com/docker/build-push-action)
- [Docker Hub Description Action](https://github.com/peter-evans/dockerhub-description)
