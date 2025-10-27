#!/bin/bash

# VGGTのCUDA VNC環境を起動するスクリプト

echo "🚀 VGGT CUDA VNC環境を起動しています..."

# 既存のコンテナがあれば停止・削除
if [ "$(docker ps -aq -f name=cuda-vnc)" ]; then
    echo "📦 既存のcuda-vncコンテナを停止・削除しています..."
    docker stop cuda-vnc 2>/dev/null
    docker rm cuda-vnc 2>/dev/null
fi

# workspaceディレクトリを作成（存在しない場合）
if [ ! -d "./workspace" ]; then
    echo "📁 workspaceディレクトリを作成しています..."
    mkdir -p ./workspace
fi

# Docker Composeでビルド・起動
echo "🔨 Dockerイメージをビルドしています..."
docker compose build

echo "🚀 コンテナを起動しています..."
docker compose up -d

# 起動確認
echo "⏳ コンテナの起動を待機しています..."
sleep 5

if [ "$(docker ps -q -f name=cuda-vnc)" ]; then
    echo "✅ CUDA VNC環境が正常に起動しました！"
    echo ""
    echo "🌐 VNC接続情報:"
    echo "   URL: http://localhost:6080"
    echo "   パスワード: 1234"
    echo ""
    echo "📋 便利なコマンド:"
    echo "   ログ確認: docker compose logs -f"
    echo "   停止: docker compose down"
    echo "   コンテナ内に入る: docker exec -it cuda-vnc bash"
    echo ""
    echo "🎉 ブラウザで http://localhost:6080 にアクセスしてください！"
else
    echo "❌ コンテナの起動に失敗しました。ログを確認してください:"
    docker compose logs
fi
