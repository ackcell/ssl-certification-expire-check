#!/usr/bin/env bash
# DATE="gdate" # gnu date command
# TODO:rc handling
${DATE:-'date'} >/dev/null
if $DATE --version >/dev/null 2>&1 ; then
    :
else
    echo Not using GNU date: set GNU date command into DATE environment variable, then run again
    exit 99
fi

usage_exit() {
        echo "Usage: $0 [-f file] [-h] [-u url]" 1>&2
        exit 1
}

while getopts u:f:h OPT
do
    case $OPT in
        "u" ) URL="$OPTARG";;
        "f" ) FILE="$OPTARG";;
        "h" ) usage_exit;;
        \?) usage_exit;;
    esac
done
function date2remain() {
  #$1: epoch time
  today=`$DATE -u +%s`

  remains=$(($1-$today))
  echo $(($remains/60/60/24))
}
function checksingle() {
  # url,infoを返す
SSL=$(curl -v $1 3> /dev/null 2>&1 1>&3 |grep ' SSL certificate problem'|head -n 1|sed  's/.*SSL certificate problem://')

if [ ${#SSL} -eq 0 ]; then
  # SSL障害なし
  # expire dateを取得する
  EDATE=$(curl -v $1 3> /dev/null 2>&1 1>&3 | grep 'expire date:'|head -n 1|sed  's/.*expire date://')
  if [ ${#EDATE} -eq 0 ]; then
    # 有効期限なし
    echo "000,$1, NO SSL"
    return 5
  else
    # 有効期限あり
    will_expire=`$DATE -d "$EDATE" -u +%s` # epoch time
    daysafter=`date2remain $will_expire`
    printf "%03d" $daysafter
    printf ","
    printf $1
    printf ","
    printf "$EDATE"
    return 0
  fi

else
  # SSL問題あり
  echo "000,$1, $SSL"
  return 1
fi
}
if [ ${#FILE} -ne 0 ]; then
  cat "$FILE" | while read line
    do
      line=`echo $line|sed 's/#.*//g'`
      if [ ${#line} -lt 1 ]; then
        continue
      fi
      INFO=`checksingle $line`
      echo "$INFO"
    done
fi
if [ ${#URL} -ne 0 ]; then
  INFO=`checksingle $URL`
  echo "$INFO"
fi
exit 0
