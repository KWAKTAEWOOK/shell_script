#!/bin/bash
export LC_ALL=C #한글인식파일
search_path="/data/tools/ktw/" #서치경로
output_folder="output" #코멘트삭제file 디렉토리
file_list="file_list.txt"  #DB확인및경로 리스트
#DB TYPE 변수선언
oracle_pn=".*oracle.*"
informix_pn=".*informix.*"
cubrid_pn=".*cubrid.*"
mysql_pn=".*mysql.*"
tibero_pn=".*tibero.*"
rm file_list.txt
mkdir -p "$output_folder" #디렉토리 생성
for file in $(find "$search_path" \ ( -name "*.java" -o -name "*.xml" -o -name "*.properties" -o -name "*.js" -o -name "*.jsp" -o -name "*.html" \) ! size 0) 
#확장자 서치로직 단 size가0인건 제외
do
    output_file="$output_folder/${file#"$search_path"}"
     mkdir -p "$(dirname "$output_file")"
    db_ora="" #oracle
    db_info="" #informix
    db_cb="" #cubrid
    db_my="" #mysql
    db_tb="" #tibero
    if [[ "$file" == *.java || "$file" == *.js ]]; then
    uncommented=$(awk '{ 
            in_comment = 0 
            gsub(/\/\*/, " /* ", $0) 
            gsub(/   \*\//, " */ ", $0) 
            gsub(/\/\*.*\*\//, "", $0) 
            gsub(/\/\/.*/, "", $0) 
            printf("%s\n", $0) 
            }' "$file" | sed -e '/\/\*/,/\*\//d')
      elif [[ "$file" == *.xml || "$file" == *.html ]]; then
       uncommented=$(perl -0777 -pe 's/<!--.*?-->//gs' "$file")
                   echo "$uncommented" > "$output_file"
      elif [[ "$file" == *.properties ]]; then 
                    uncommented=$(sed 's/#.*//' "$file")
      elif [[ "$file" == *.jsp ]]; then 
                    uncommented=$(awk '{
                     in_comment = 0
                     gsub(/<%--/, " <%-- ", $0)
                     gsub(/--%>/, " --%> ", $0)
                     gsub(/<%--.*--%>/, "", $0)
                     gsub(/\/\*/, " /* ", $0)
                     gsub(/\*\//, " */ ", $0)
                     gsub(/\/\/.*/, "", $0)
                     gsub(/\/\*.*\*\//, "", $0)
                     printf("%s\n", $0) 
                     }' "$file" | sed '/<%--/,/--%>/d' | sed '/\/\*/,/\*\//d')
     else
                    uncommented=$(cat "$file")
        fi
    if echo "$uncommented" | grep -q "$oracle_pn" "$file"; then
        db_ora="oracle"
    fi
    if echo "$uncommented" | grep -q "$informix_pn" "$file"; then
        db_info="informix"
    fi
    if echo "$uncommented" | grep -q "$cubrid_pn" "$file"; then
        db_cb="cubrid"
    fi
    if echo "$uncommented" | grep -q "$mysql_pn" "$file"; then
        db_my="mysql"
    fi
    if echo "$uncommented" | grep -q "$tibero_pn" "$file"; then
        db_tb="tibero"
    fi
    
     if [[ "$file" == *.java || "$file" == *.js ]]; then 
            awk '{ 
            in_comment = 0 
            gsub(/\/\*/, " /* ", $0) 
            gsub(/   \*\//, " */ ", $0) 
            gsub(/\/\*.*\*\//, "", $0) 
            gsub(/\/\/.*/, "", $0) 
            printf("%s\n", $0) 
            }' "$file" | sed -e '/\/\*/,/\*\//d' > "$output_file"
        elif [[ "$file" == *.xml || "$file" == *.html ]]; then
                    perl -0777 -pe 's/<!--.*?-->//gs' "$file" > "$output_file"
        elif [[ "$file" == *.properties ]]; then 
                    sed 's/#.*//' "$file" > "$output_file"
        elif [[ "$file" == *.jsp ]]; then 
                    awk '{
                     in_comment = 0
                     gsub(/<%--/, " <%-- ", $0)
                     gsub(/--%>/, " --%> ", $0)
                     gsub(/<%--.*--%>/, "", $0)
                     gsub(/\/\*/, " /* ", $0)
                     gsub(/\*\//, " */ ", $0)
                     gsub(/\/\/.*/, "", $0)
                     gsub(/\/\*.*\*\//, "", $0)
                     printf("%s\n", $0) 
                     }' "$file" | sed '/<%--/,/--%>/d' | sed '/\/\*/,/\*\//d' > "$output_file"
                     fi
#한 파일에 여러DB가 들어있을경우
                     if [ -n "$db_ora" ]; then
                     echo "$db_ora : ${file}" >> "$file_list"
                     fi
                     if [ -n "$db_info" ]; then
                     echo "$db_info : ${file}" >> "$file_list"
                     fi
                     if [ -n "$db_cb" ]; then
                     echo "$db_cb : ${file}" >> "$file_list"
                     fi
                     if [ -n "$db_my" ]; then
                     echo "$db_my : ${file}" >> "$file_list"
                     fi
                     if [ -n "$db_tb" ]; then
                     echo "$db_tb : ${file}" >> "$file_list"
                     fi
done
