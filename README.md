# VGGT CUDA VNC Environment

CUDA対応のVNC環境をDocker Composeで簡単に起動できるようにしたセットアップです。

## 🚀 クイックスタート
### 前提条件
- DockerおよびDocker Composeがインストールされていること
- xserverがインストールされていること
- NVIDIA GPU搭載マシンで、NVIDIAドライバとnvidia-container-toolkit(インストールのパッケージは調べておく)がインストールされていること
# 1. パッケージ更新
sudo apt update

# 2. 必要ツールをインストール
sudo apt install -y ca-certificates curl gnupg lsb-release

# 3. Docker公式のGPGキー登録
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# 4. Docker公式リポジトリ追加
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 5. Docker Engine インストール
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 6. 権限設定（sudo不要でdocker使う）
sudo usermod -aG docker $USER


### 起動
```bash
cd Ubuntu_vnc
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

### 前提条件
- NVIDIAドライバ 560.94 以降（ホストOS側）
- NVIDIA Container Toolkit（`nvidia-container-runtime` が Docker から利用可能であること）
- Docker 20.10 以降

WSL2環境の場合は、WSLディストリビューション内にも`nvidia-container-toolkit`を導入し、`/etc/docker/daemon.json`に以下のような設定を追加してください。
```json
{
  "default-runtime": "nvidia",
  "runtimes": {
    "nvidia": {
      "path": "nvidia-container-runtime",
      "runtimeArgs": []
    }
  }
}
```
設定変更後は `sudo systemctl restart docker`（WSLでは`sudo service docker restart`）でDockerデーモンを再起動します。

### ポート
- 6080: noVNC（ブラウザVNC）

### GPU
- すべてのGPUが利用可能
- CUDA 12.6 (ベースイメージ) + cuDNN 8

### GPU 動作確認
コンテナ起動後に以下を実行して、ホストの GPU が認識されているか確認できます。
```bash
docker exec -it cuda-vnc bash -lc "nvidia-smi"
```
想定される出力例：
```
Mon Oct 27 21:58:14 2025
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 560.35.02              Driver Version: 560.94         CUDA Version: 12.6     |
|-----------------------------------------+------------------------+----------------------|
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA GeForce RTX 3070        On  |   00000000:01:00.0  On |                  N/A |
|  0%   45C    P8              9W /  220W |    1294MiB /   8192MiB |      0%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+
                                                                                          
+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI        PID   Type   Process name                              GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|    0   N/A  N/A        22      G   /Xwayland                                   N/A      |
+-----------------------------------------------------------------------------------------+
```
PyTorchが CUDA を正しく認識しているかは次のコマンドでも確認できます。
```bash
docker exec -it cuda-vnc bash -lc "python3 - <<'PY'\nimport torch\nprint('torch version:', torch.__version__)\nprint('cuda available:', torch.cuda.is_available())\nprint('current device:', torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'N/A')\nPY"
```

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
