#!/bin/bash
set -e

cd "$(dirname "$0")"

echo "🔄 S3 백엔드 파일 이름 변경: backend_s3.tf → backend_s3.tf.bak"
mv backend_s3.tf backend_s3.tf.bak

echo "✅ 로컬 백엔드 활성화: backend_local.tf.bak → backend_local.tf"
mv backend_local.tf.bak backend_local.tf

echo "⚙️ Terraform 초기화 (local backend)"
terraform init -reconfigure

echo "✅ 로컬 백엔드로 전환 완료"

