#!/bin/bash

# 1. 최상위 README 업데이트
sed -n '//q;p' README.md > README.tmp
echo "" >> README.tmp
echo "# 학습 일지 목차" >> README.tmp

for dir in posts/*/; do
    dir_name=$(basename "$dir")
    echo "### 📂 $dir_name" >> README.tmp
    echo "- **[폴더 바로가기]($dir)**" >> README.tmp
    echo "" >> README.tmp
done
mv README.tmp README.md

# 2. 각 하위 폴더별 README 자동 생성
for dir in posts/*/; do
    dir_name=$(basename "$dir")
    readme_path="${dir}README.md"
    
    echo "# 📂 $dir_name 학습 정리" > "$readme_path"
    echo "" >> "$readme_path"
    echo "## 📝 목록" >> "$readme_path"
    echo "| 제목 | 링크 |" >> "$readme_path"
    echo "| --- | --- |" >> "$readme_path"
    
    for file in "$dir"/*.md; do
        filename=$(basename "$file")
        if [ "$filename" != "README.md" ]; then
            echo "| $filename | [$filename]($file) |" >> "$readme_path"
        fi
    done
done