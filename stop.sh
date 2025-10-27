#!/bin/bash

# VGGTのCUDA VNC環境を停止するスクリプト

echo "🛑 VGGT CUDA VNC環境を停止しています..."

# Docker Composeで停止
docker compose down

echo "✅ CUDA VNC環境を停止しました。"
echo ""
echo "📋 その他のコマンド:"
echo "   再起動: ./start.sh"
echo "   ログ確認: docker compose logs"
echo "   完全削除: docker compose down --rmi all -v"
