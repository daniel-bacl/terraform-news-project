#!/bin/bash
set -e

# 의존성 설치 디렉토리 초기화
rm -rf python
mkdir -p python

# requirements.txt 기준 패키지 설치
pip install -r requirements.txt -t python

# zip 압축
zip -r ../lambda_layer.zip python
