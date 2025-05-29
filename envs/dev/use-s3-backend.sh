#!/bin/bash
set -e

cd "$(dirname "$0")"

echo "🔄 로컬 백엔드 파일 이름 변경: backend_local.tf → backend_local.tf.bak"
mv backend_local.tf backend_local.tf.bak

echo "✅ S3 백엔드 복원: backend_s3.tf.bak → backend_s3.tf"
mv backend_s3.tf.bak backend_s3.tf

echo "⚙️ Terraform 초기화 (S3 backend)"
terraform init -reconfigure

echo "✅ S3 백엔드로 복원 완료"

