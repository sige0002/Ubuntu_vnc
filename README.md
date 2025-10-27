# VGGT CUDA VNC Environment

CUDA対応のVNC環境をDocker Composeで簡単に起動できるようにしたセットアップです。

## 🚀 クイックスタート

### 起動
```bash
cd Ubbuntu_vnc
./start.sh
```

### 停止
```bash
./stop.sh
```

## 📋 使用方法

### 1. 環境起動
```bash
./start.sh
```
このコマンドで以下が自動実行されます：
- 既存のコンテナがあれば停止・削除
- workspaceディレクトリの作成
- Dockerイメージのビルド
- コンテナの起動

### 2. VNCアクセス
ブラウザで以下にアクセス：
- URL: http://localhost:6080
- パスワード: 1234

### 3. 環境停止
```bash
./stop.sh
```

## 🛠️ 便利なコマンド

### ログ確認
```bash
docker compose logs -f
```

### コンテナ内に入る
```bash
docker exec -it cuda-vnc bash
```

### 完全削除（イメージも含む）
```bash
docker compose down --rmi all -v
```

### 手動でのDocker Compose操作
```bash
# ビルド
docker compose build

# 起動（デタッチモード）
docker compose up -d

# 停止
docker compose down

# ログ確認
docker compose logs
```

## 📁 ディレクトリ構成

```
VGGT/
├── Dockerfile          # CUDA VNC環境の定義
├── docker-compose.yml  # Docker Compose設定
├── start.sh           # 起動スクリプト
├── stop.sh            # 停止スクリプト
├── workspace/         # 作業ディレクトリ（コンテナと共有）
└── README.md          # このファイル
```

## 🔧 設定詳細

### ポート
- 6080: noVNC（ブラウザVNC）

### GPU
- すべてのGPUが利用可能
- CUDA 12.1.1 + cuDNN 8

### 環境
- Ubuntu 22.04
- XFCE4デスクトップ環境
- Python 3
- 基本的な開発ツール

### ボリューム
- `./workspace` → `/workspace` (コンテナ内の作業ディレクトリ)

## 🚨 トラブルシューティング

### コンテナが起動しない場合
```bash
# ログを確認
docker compose logs

# 手動で起動してみる
docker compose up
```

### GPU が認識されない場合
- nvidia-docker2がインストールされているか確認
- nvidia-container-runtimeが設定されているか確認

### ポートが使用中の場合
docker-compose.ymlの`ports`セクションを編集してポート番号を変更してください。

## 📝 従来の手順との比較

### 従来の手順
```bash
# 1. SSHポートフォワーディング
ssh -L 6080:localhost:6080 sadasue@<リモートPC>

# 2. 別ターミナルでDocker起動
docker run -it --gpus all -p 6080:6080 --name cuda-vnc cuda-vnc
```

### 新しい手順
```bash
# ワンコマンドで完了！
./start.sh
```
