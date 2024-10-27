#타이머설정
SECONDS=0

#정규표현식 안쓴버전
#find $1 -type d -name “.svn” -prune -o -type f $exclude | while read -r file; do
#exclude=”-not -name “*.gif” -not -name “*.swf”-not -name “*.hwp” -not -name “*.png” -not -name “*.mrd” -not -name “*.jpg” -not -name “*.jar” -not -name “*.tar” -not -name “*.zip” -not -name “*.xls” -not -name “*.doc” -not -name “*.pdf” -not -name “*.class” -not -name “*.css” -not -name “*.svg” -not -name “*.map” -not -name “*.bmp” -not -name “*.bcmap” -not -name “*.woff” -not -name “*.ttf” -not -name “*.eot” -not -name “*.war”-not -name “*.jpeg” -not -name “*.json” -not -name “*.PNG”“

#find 제외 확장자 설정
exclude=’.*\.\(gif\|swf/|hwp\|png\|mrd\|jpg\|jar\|tar\|zip\|xls\|doc\|pdf\|classs\|css\|svg\|map\|bmp\|woff\|ttf\|eot\|war\|jpeg\|json\|PNG\)’

if [[ "$#" != 3 ]]; then
    echo ""
    echo "---> Argument count check !!!"
    echo ""
    echo "Usage                     :    SearchWord.sh [SOURCE] [FIND WORD]"
    echo "SOURCE                 :    \"/dev/경로\""
    echo "FIND WORD           :    ex) 192.168.1.1:port etc."
    echo "Result File Name  :    FileName"
fi
echo "$1 $2"

# $1 경로패스를 받고 .svn 폴더 제외 -regex 정규표현식으로 안쓰는 확장자 제외후 서치
find $1 -type d -name ".svn" -prune -o -type -regex $exclude | while read -r filel do;
    echo "$file"
    if [[ $file == *classes* ]] || [[ $file == *.svn* ]]; then
            continue
    fi
    grep -HniF "${2}" "$file" >> $3
done
# 프로그램 돌린시간
duration=$SECONDS
echo "Processor ended !!!"
echo "$(($duration / 60 )) minutes and $(($duration % 60 )) seconds."