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
    
    # --- 템플릿 부분 시작 ---
    cat <<EOF > "$readme_path"
# 📂 $dir_name 학습 정리

이 폴더는 **$dir_name**에 관한 학습 기록과 실습 내용을 담고 있습니다.

## 🎯 학습 목표
- [ ] 
- [ ] 

## 📝 학습 리스트
| 제목 | 링크 |
| --- | --- |
EOF
    # --- 템플릿 부분 끝 ---
    
    # 파일 목록 추가
    for file in "$dir"/*.md; do
        filename=$(basename "$file")
        if [ "$filename" != "README.md" ]; then
            echo "| $filename | [$filename]($file) |" >> "$readme_path"
        fi
    done
done