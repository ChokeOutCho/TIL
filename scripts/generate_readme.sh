#!/bin/bash
cd "$GITHUB_WORKSPACE"

# 1. 최상위 README 업데이트
sed -n '//q;p' README.md > README.tmp
echo "" >> README.tmp
echo "# 📚 학습 일지" >> README.tmp

for dir in posts/*/; do
    [ -d "$dir" ] || continue
    dir_name=$(basename "$dir")
    
    echo "### 📂 [$dir_name]($dir)" >> README.tmp
    
    # 최근 5개 파일만 추출 (확장자 제거)
    find "$dir" -maxdepth 1 -name "*.md" ! -name "README.md" -printf "%T@ %p\n" | sort -nr | head -n 5 | cut -d' ' -f2- | while read -r file; do
        filename=$(basename "$file" .md)
        echo "- [$filename]($file)" >> README.tmp
    done
    echo "" >> README.tmp
done
mv README.tmp README.md

# 2. 각 하위 README 자동 생성
for dir in posts/*/; do
    [ -d "$dir" ] || continue
    dir_name=$(basename "$dir")
    readme_path="${dir}README.md"
    
    cat <<EOF > "$readme_path"
# 📂 $dir_name

[⬅️ 전체 목록으로 돌아가기](../README.md)

---

## 목록
EOF

    # 수정된 부분: $(basename "$file")을 사용하여 경로를 제거하고 파일명만 추출
    find "$dir" -maxdepth 1 -name "*.md" ! -name "README.md" | while read -r file; do
        filename=$(basename "$file" .md)
        just_filename=$(basename "$file") 
        echo "- [$filename]($just_filename)" >> "$readme_path"
    done
done