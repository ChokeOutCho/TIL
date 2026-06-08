#!/bin/bash
echo "DEBUG: Checking posts folder..."
find posts -maxdepth 2 -name "*.md"

# README 상단 내용 유지
sed -n '/<!-- START -->/q;p' README.md > README.tmp
echo "<!-- START -->" >> README.tmp
echo "" >> README.tmp
echo "# 📚 학습 일지 목차" >> README.tmp

# 리스트 생성
for dir in posts/*/; do
    echo "### 📂 $(basename "$dir")" >> README.tmp
    echo "| 제목 | 링크 |" >> README.tmp
    echo "| --- | --- |" >> README.tmp
    for file in "$dir"/*.md; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            echo "| $filename | [$filename]($file) |" >> README.tmp
        fi
    done
    echo "" >> README.tmp
done

mv README.tmp README.md