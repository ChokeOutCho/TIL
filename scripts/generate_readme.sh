#!/bin/bash
cd "$GITHUB_WORKSPACE"

# 1. 최상위 README 업데이트
sed -n '//q;p' README.md > README.tmp
echo "" >> README.tmp
echo "# 📚 학습 일지 목차" >> README.tmp

for dir in posts/*/; do
    [ -d "$dir" ] || continue
    dir_name=$(basename "$dir")
    
    # 폴더 이름에 링크 걸기
    echo "### 📂 [$dir_name]($dir)" >> README.tmp
    
    # 최근 5개 파일만 표로 보여주기
    echo "| 제목 | 링크 |" >> README.tmp
    echo "| --- | --- |" >> README.tmp
    
    # 시간순(최신순) 정렬 후 5개만 추출
    find "$dir" -maxdepth 1 -name "*.md" ! -name "README.md" -printf "%T@ %p\n" | sort -nr | head -n 5 | cut -d' ' -f2- | while read -r file; do
        filename=$(basename "$file")
        echo "| $filename | [$filename]($file) |" >> README.tmp
    done
    echo "" >> README.tmp
done
mv README.tmp README.md

# 2. 각 하위 README 자동 생성 (이전과 동일)
for dir in posts/*/; do
    [ -d "$dir" ] || continue
    dir_name=$(basename "$dir")
    readme_path="${dir}README.md"
    
    cat <<EOF > "$readme_path"
# 📂 $dir_name 학습 정리

이 폴더는 **$dir_name**에 관한 학습 기록과 실습 내용을 담는다.

## 🎯 학습 목표
- [ ] 

## 📝 학습 리스트
| 제목 | 링크 |
| --- | --- |
EOF
    find "$dir" -maxdepth 1 -name "*.md" ! -name "README.md" | while read -r file; do
        filename=$(basename "$file")
        echo "| $filename | [$filename]($file) |" >> "$readme_path"
    done
done