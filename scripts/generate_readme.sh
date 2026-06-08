#!/bin/bash

# README 상단 내용 유지 (마커 위까지)
sed -n '//q;p' README.md > README.tmp
echo "" >> README.tmp
echo "# 학습 일지 목차" >> README.tmp

# posts 하위 폴더들을 순회
for dir in posts/*/; do
    dir_name=$(basename "$dir")
    echo "" >> README.tmp
    echo "### 📂 $dir_name" >> README.tmp
    echo "| 제목 | 링크 |" >> README.tmp
    echo "| --- | --- |" >> README.tmp
    
    # 해당 폴더 내의 md 파일 리스트업
    for file in "$dir"/*.md; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            echo "| $filename | [$filename]($file) |" >> README.tmp
        fi
    done
done

mv README.tmp README.md