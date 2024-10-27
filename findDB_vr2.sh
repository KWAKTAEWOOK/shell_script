#!/bin/bash
export LC_ALL=C 
# 스크립트의 명령이 C 로케일에서 실행되도록 설정

search_path="/data/tools/ktw/"
# 검색할 디렉토리의 경로를 지정

output_folder="output" 
# 출력 파일을 저장할 디렉토리의 이름을 지정합니다.

file_list="file_list.txt"  
# 검색 결과를 저장할 파일의 이름을 지정합니다.

declare -A db_types=(["oracle"]=".*oracle.*" ["informix"]=".*informix.*" ["cubrid"]=".*cubrid.*" ["mysql"]=".*mysql.*" ["tibero"]=".*tibero.*")
# 데이터베이스 유형및 정규식 패턴을 배열로 저장합니다.

rm file_list.txt
# 이전 검색 결과의 파일이 남아있으면 삭제합니다.

mkdir -p "$output_folder"
# 출력 디렉토리가 없으면 생성합니다.

for file in $(find "$search_path" \ ( -name "*.java" -o -name "*.xml" -o -name "*.properties" -o -name "*.js" -o -name "*.jsp" -o -name "*.html" \) ! size 0)
# 검색 경로에서 지정된 확장자를 가진 파일을 찾아 for 루프로 처리
do
    if [ ! -s "$file" ]; then 
            continue; 
    fi
    # 파일이 존재하지 않거나 크기가 0인 경우 건너뜁니다.
    if [ "$file" == *" "* ]; then 
            continue; 
    fi
    # 파일 경로에 공백이 포함된 경우 건너뜁니다. 공백이 포함된경우 파일명을 " "을 "_"로 치환하는 작업이 선행되어야합니다.
    output_file="$output_folder/${file#"$search_path"}"
    # 출력 파일의 경로를 생성합니다.
    mkdir -p "$(dirname "$output_file")"
    # 출력 파일의 디렉토리가 없으면 생성합니다.
    declare -A db_flags=(["oracle"]="" ["informix"]="" ["cubrid"]="" ["mysql"]="" ["tibero"]="")
    # 데이터베이스 유형별로 플래그를 초기화합니다.
    if [[ "$file" == *.java || "$file" == *.js ]]; then
        uncommented=$(awk '{ 
            in_comment = 0 
            gsub(/\/\*/, " /* ", $0) 
            gsub(/   \*\//, " */ ", $0) 
            gsub(/\/\*.*\*\//, "", $0) 
            if (!match($0, /https?:\/\//)) {
                gsub(/\/\/.*/, "", $0) 
            }
            if (match($0, /^\s*\/\/.*https?:\/\//)) {
            gsub(/^\s*\/\/.*/, "", $0) 
            }
            printf("%s\n", $0) 
        }' "$file" | sed -e '/\/\*/,/\*\//d')
# Java 또는 JavaScript 파일인 경우 주석을 제거하고 URL을 예외로 처리합니다. 단 맨앞에 //주석이 있을경우 URL이있어도 삭제됩니다
    elif [[ "$file" == *.xml || "$file" == *.html ]]; then
        uncommented=$(perl -0777 -pe 's/<!--.*?-->//gs' "$file")
# XML 또는 HTML 파일인 경우 주석을 제거합니다.
        echo "$uncommented" > "$output_file"
# 주석이 제거된 내용을 출력 파일에 저장합니다.
    elif [[ "$file" == *.properties ]]; then 
        uncommented=$(sed -e 's/#.*//' -e 's/!.*//' "$file")
# properties 파일인 경우 주석을 제거합니다.
    elif [[ "$file" == *.jsp ]]; then 
        uncommented=$(awk '{
            in_comment = 0
            gsub(/<%--/, " <%-- ", $0)
            gsub(/--%>/, " --%> ", $0)
            gsub(/<%--.*--%>/, "", $0)
            gsub(/\/\*/, " /* ", $0)
            gsub(/\*\//, " */ ", $0)
            if (!match($0, /https?:\/\//)) {
                gsub(/\/\/.*/, "", $0) 
            }
            if (match($0, /^\s*\/\/.*https?:\/\//)) { 
            gsub(/^\s*\/\/.*/, "", $0) 
            }
            gsub(/\/\*.*\*\//, "", $0)
            printf("%s\n", $0) 
        }' "$file" | sed '/<%--/,/--%>/d' | sed '/\/\*/,/\*\//d')
# JSP 파일인 경우 주석을 제거하고 URL을 예외로 처리합니다.
    else
        uncommented=$(cat "$file")
# 그 외의 경우 파일 내용을 그대로 사용합니다.
    fi
    for db_type in "${!db_types[@]}"; do
        if echo "$uncommented" | grep -q "${db_types[$db_type]}" ; then
            db_flags[$db_type]=$db_type
        fi
    done
# 데이터베이스 유형별로 검색 결과를 확인하고 플래그를 설정합니다.
    for db_flag in "${!db_flags[@]}"; do
        if [ -n "${db_flags[$db_flag]}" ]; then
            echo "${db_flags[$db_flag]} : ${file}" >> "$file_list"
        fi
    done
    # 검색 결과를 파일에 저장합니다.
    if [[ "$file" == *.java || "$file" == *.js ]]; then 
        awk '{ 
            in_comment = 0 
            gsub(/\/\*/, " /* ", $0) 
            gsub(/   \*\//, " */ ", $0) 
            gsub(/\/\*.*\*\//, "", $0) 
            if (!match($0, /https?:\/\//)) {
                gsub(/\/\/.*/, "", $0) 
            }
            if (match($0, /^\s*\/\/.*https?:\/\//)) { 
            gsub(/^\s*\/\/.*/, "", $0) 
            }
            printf("%s\n", $0) 
        }' "$file" | sed -e '/\/\*/,/\*\//d' > "$output_file"
# Java 또는 JavaScript 파일인 경우 주석을 제거하고 URL을 예외로 처리한 후 출력 파일에 저장합니다.
    elif [[ "$file" == *.xml || "$file" == *.html ]]; then
        perl -0777 -pe 's/<!--.*?-->//gs' "$file" > "$output_file"
# XML 또는 HTML 파일인 경우 주석을 제거한 후 출력 파일에 저장합니다.
    elif [[ "$file" == *.properties ]]; then 
        sed -e 's/#.*//' -e 's/!.*//' "$file" > "$output_file"
# properties 파일인 경우 주석을 제거한 후 출력 파일에 저장합니다.
    elif [[ "$file" == *.jsp ]]; then 
        awk '{
            in_comment = 0
            gsub(/<%--/, " <%-- ", $0)
            gsub(/--%>/, " --%> ", $0)
            gsub(/<%--.*--%>/, "", $0)
            gsub(/\/\*/, " /* ", $0)
            gsub(/\*\//, " */ ", $0)
            if (!match($0, /https?:\/\//)) {
                gsub(/\/\/.*/, "", $0) 
            }
            if (match($0, /^\s*\/\/.*https?:\/\//)) {
            gsub(/^\s*\/\/.*/, "", $0) 
            }
            gsub(/\/\*.*\*\//, "", $0)
            printf("%s\n", $0) 
        }' "$file" | sed '/<%--/,/--%>/d' | sed '/\/\*/,/\*\//d' > "$output_file"
# JSP 파일인 경우 주석을 제거하고 URL을 예외로 처리한 후 출력 파일에 저장합니다.
    fi
done
