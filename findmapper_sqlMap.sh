#!/bin/bash
export LC_ALL=C 

DT=`date "+%m%d%H%M"`

search_path="/data/tools/ktw/SQL_FILENAME.xml"

for file in $(find "$search_path" -name "*.xml" ! -size 0);
do
if [ ! -s "$file" ]; then
continue
fi
#파일이 비어있으면 패스
if [ "$file" == *" "* ];then
continue
fi
#공백이 포함된경우 패스
MN=`grep -c -E '<mapper[[:space:]]namespace|<sqlMap[[:space:]]namespace' "$file"`
if [ $MN -eq 0 ]; then
continue
fi
#매퍼와 스페이스를 대입해 조건에 맞는데이터를 $파일 변수에 넣고 조건에 맞지않으면 패스
echo $MN
awk -v Fname=$file 'BEGIN{
}
{
gsub("=", " = ", $0); #'=' 기호 앞뒤로 공백 추가
gsub("\"", " \" ",$0); #따옴표 앞뒤로 공백 추가
for( i = 0; i<= NF; i++){
if( $i == "namespace" ){
Namespace=$( i+3 );  # namespace 값을 저장
NSflag = 1;
}
if( NSflag == 1 && $i == "id" ){
ID=$(i+3); # id 값을 저장
IDflag = 1;
 }
if (NSflag == 1 && IDflag == 1){
Tname=sprintf("%s.%s",Namespace,ID); # namespace와 id를 조합
}
printf("%s:%s:%n",Fname,FNR,Tname) # 파일명:줄 번호:조합된 이름 출력
}
}' "$file" >> "testfile1"
