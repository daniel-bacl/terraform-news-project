#!/bin/bash

set -e
cd "$(dirname "$0")/src"

echo "📦 Installing dependencies from requirements.txt..."
pip install -r requirements.txt -t .

echo "🧹 Cleaning up unnecessary files..."
find . -type d -name "__pycache__" -exec rm -rf {} +
rm -rf *.dist-info *.egg-info

echo "🗜 Creating zip file..."
cd ..
zip -r sql_init.zip src > /dev/null

echo "✅ Done! Created zip at: $(realpath sql_init.zip)"

