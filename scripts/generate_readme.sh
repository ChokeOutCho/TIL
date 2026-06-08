#!/bin/bash

# 워킹 디렉토리 강제 지정
cd "$GITHUB_WORKSPACE"

# 1. 최상위 README 업데이트 (기존과 동일)
sed -n '//q;p' README.md > README.tmp
echo "" >> README.tmp
echo "# 📚 학습 일지 목차" >> README.tmp

for dir in posts/*/; do
    [ -d "$dir" ] || continue
    dir_name=$(basename "$dir")
    echo "### 📂 $dir_name" >> README.tmp
    echo "- **[폴더 바로가기]($dir)**" >> README.tmp
done
mv README.tmp README.md

# 2. 하위 README 강제 생성 (로그 포함)
echo "DEBUG: Starting sub-README generation..."

for dir in posts/*/; do
    [ -d "$dir" ] || continue
    dir_name=$(basename "$dir")
    readme_path="${dir}README.md"
    
    echo "DEBUG: Processing folder: $dir"
    
    # 강제로 파일 생성
    cat <<EOF > "$readme_path"
# 📂 $dir_name 학습 정리
## 📝 학습 리스트
| 제목 | 링크 |
| --- | --- |
EOF
    
    # 생성 확인
    if [ -f "$readme_path" ]; then
        echo "DEBUG: Successfully created $readme_path"
    else
        echo "DEBUG: FAILED to create $readme_path"
    fi
done