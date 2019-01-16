#!/bin/bash
MAIN_DIR=$HOME
TARGET_DOWNLOAD=$MAIN_DIR/cache/download
TARGET=$TARGET_DOWNLOAD/cafeteria.html
TARGET_CACHE=$MAIN_DIR/cache
SCHOOL_CODE_INFO=$TARGET_CACHE/school_code/school_code.db
MONTH=$(date +%m)
YEAR=$(date +%Y)
TODAY=$(date +%a)
RED='\033[0;31m'
WHITE='\033[0m'

if [ ! -d "$MAIN_DIR" ]
then
mkdir -p "$MAIN_DIR"
fi

if [ ! -d "$TARGET_CACHE" ]
then
mkdir -p "$TARGET_CACHE"
fi

if [ ! -d "$TARGET_DOWNLOAD" ]
then
mkdir -p "$TARGET_DOWNLOAD"
fi

if [ "$1" = "eng" ]
then
LANG=eng
else
LANG=kor
fi

function DISPLAY_HELP(){
echo "$(LANG $LANG DISPLAY_HELP)"
exit 0
}

function DIRECT_DISPLAY(){
if [ ! -e "$TARGET" ]
then
read -s -n1 -p "! $(LANG $LANG ERROR_FAILDREQUEST)
$(LANG $LANG PRESS_ANYKEY)" press
exit 0
fi
echo "
| $YEAR. $MONTH |
"
PRINT_TYPE=TODAY
if [ "$(date +%d | cut -b1)" = "0" ]
then
i=$(date +%d | cut -b2)
else
i=$(date +%d)
fi
PARS_COMMON
PARS_PRINT
PRT_ALLERGY
CLR_SCRIPT
read -s -n1 -p "
$(LANG $LANG PRESS_ANYKEY)" press
exit 0
}

function DIRECT_DISPLAY_SELETED(){
if [ ! -e "$TARGET" ]
then
read -s -n1 -p "! $(LANG $LANG ERROR_FAILDREQUEST)
$(LANG $LANG PRESS_ANYKEY)" press
exit 0
fi
echo "
| $YEAR. $MONTH |
"
i=$1
TODAY=$(date -d $YEAR$MONTH$i | awk '{print $1}')
PRINT_TYPE=TODAY
PARS_COMMON
PARS_PRINT
PRT_ALLERGY
CLR_SCRIPT
read -s -n1 -p "
$(LANG $LANG PRESS_ANYKEY)
기본실행을 먼저 하십시오" press
echo
exit 0
}

function PARS_COMMON(){
CARTE="$(grep "<div>$i<" $TARGET)"
CARTE_EN="$(grep "<div>$i<" $TARGET | cut -d">" -f3)"
sed -i 's/&amp;/ /g' $TARGET
}

function PARS_BREAKFAST(){
if [ "$(echo "$CARTE" | grep "조식")" = "" ]
then
CARTE_BREAKFAST="$(LANG $LANG CARTE_NODATA)"
else
CARTE_BREAKFAST="$(echo "$CARTE" | cut -d"[" -f2 | sed 's/조식] //')"
fi
}

function PARS_LUNCH(){
if [ "$(echo "$CARTE" | grep "중식")" = "" ]
then
CARTE_LUNCH="$(LANG $LANG CARTE_NODATA)"
else
if [ "$CARTE_BREAKFAST" = "$(LANG $LANG CARTE_NODATA)" ]
then
CARTE_LUNCH="$(echo "$CARTE" | cut -d"[" -f2 | sed 's/중식] //')"
else
CARTE_LUNCH="$(echo "$CARTE" | cut -d"[" -f3 | sed 's/중식] //')"
fi
fi
}

function PARS_DINNER(){
if [ "$(echo "$CARTE" | grep "석식" | tr -s "] " "O")" = "" ]
then
CARTE_DINNER="$(LANG $LANG CARTE_NODATA)"
else
if [ "$CARTE_BREAKFAST" != "$(LANG $LANG CARTE_NODATA)" ]
then
if [ "$CARTE_LUNCH" != "$(LANG $LANG CARTE_NODATA)" ]
then
CARTE_DINNER="$(echo "$CARTE" | cut -d"[" -f4 | sed 's/석식] //')"
fi
fi
if [ "$CARTE_BREAKFAST" = "$(LANG $LANG CARTE_NODATA)" ]
then
if [ "$CARTE_LUNCH" = "$(LANG $LANG CARTE_NODATA)" ]
then
CARTE_DINNER="$(echo "$CARTE" | cut -d"[" -f2 | sed 's/석식] //')"
fi
fi
if [ "$CARTE_BREAKFAST" = "조식] " ]
then
if [ "$CARTE_LUNCH" = "$(LANG $LANG CARTE_NODATA)" ]
then
CARTE_DINNER="$(echo "$CARTE" | cut -d"[" -f3 | sed 's/석식] //')"
fi
fi
if [ "$CARTE_BREAKFAST" = "$(LANG $LANG CARTE_NODATA)" ]
then
if [ "$CARTE_LUNCH" = "중식] " ]
then
CARTE_DINNER="$(echo "$CARTE" | cut -d"[" -f3 | sed 's/석식] //')"
fi
fi
fi
}

function PARS_PRINT(){
if [ "$CARTE_EN" = "$i<br/" ]
then
CARTE="$(grep "<div>$i<" $TARGET | tr -s "<>/tdivbr" " " | sed "s/ $i //")"
PARS_BREAKFAST
PARS_LUNCH
PARS_DINNER
if [ $PRINT_TYPE = TODAY ]
then
if [ -e $TARGET_CACHE/ADDED_ALLERGY ]
then
CENCOR_ALLERGY_COMMON
CENCOR_ALLERGY_BREAKFAST
CENCOR_ALLERGY_LUNCH
CENCOR_ALLERGY_DINNER
CENCOR_ALLERGY_CLEAR
fi
fi
echo "| $MONTH. $i ($(LANG $LANG DATE_DAYOFAWEAK)) |
-----------------------------------------------------------------------------------------------------------------------
[$(LANG $LANG CARTE_BREAKFAST)] | $CARTE_BREAKFAST
[$(LANG $LANG CARTE_LUNCH)] | $CARTE_LUNCH
[$(LANG $LANG CARTE_DINNER)] | $CARTE_DINNER
-----------------------------------------------------------------------------------------------------------------------
"
else
echo "| $MONTH. $i ($TODAY) |
-----------------------------------------------------------------------------------------------------------------------
$(LANG $LANG ERROR_NODATA)
-----------------------------------------------------------------------------------------------------------------------
"
fi
}

function CLR_SCRIPT(){
if [ -e $TARGET_DOWNLOAD/cafeteria.html ]
then
mv $TARGET_DOWNLOAD/cafeteria.html $TARGET_CACHE/$SCHOOL_CODE.cache
fi
if [ -e $TARGET_CACHE/cafeteria.html ]
then
rm $TARGET_CACHE/cafeteria.html
fi
}

function PRT_ALLERGY(){
echo "* $(LANG $LANG ALLERGY_TITLE)
$(LANG $LANG ALLERGY_INFO)"
}

function CHK_ALLERGY(){
echo "* $(LANG $LANG ALLERGY_TITLE)
$(LANG $LANG ALLERGY_INFO)"
}

function CENCOR_ALLERGY_COMMON(){
ALLERGY_NUM="$(cat $TARGET_CACHE/ADDED_ALLERGY | tr -cd "," | wc -m)"
COUNT_A=1
while [ $COUNT_A -le "$ALLERGY_NUM" ]
do
FILE=$(cut -f $COUNT_A -d',' $TARGET_CACHE/ADDED_ALLERGY)
touch $TARGET_DOWNLOAD/$FILE
COUNT_A="$(expr $COUNT_A + 1)"
done
}

function CENCOR_ALLERGY_BREAKFAST(){
MENU_NUM=$(echo "$CARTE_BREAKFAST " | tr -cd " " | wc -m)
COUNT=1
while [ $COUNT -le "$MENU_NUM" ]
do
BF="$(echo "$CARTE_BREAKFAST " | cut -f $COUNT -d" ")"
NUM_ARGY=$(echo "$BF" | tr -cd "." | wc -m)
COUNT_ARGY=1
if [ $COUNT_ARGY = 1 ]
then
MENU="$(echo "$BF" | cut -f $COUNT_ARGY -d"." | tr -d [0-9])"
fi
unset CARTE_BREAKFAST_NUM
while [ $COUNT_ARGY -le "$NUM_ARGY" ]
do
ARGY_NUM="$(echo "$BF" | cut -f $COUNT_ARGY -d"." | sed 's/[^0-9]//g')"
if [ -e $TARGET_DOWNLOAD/$ARGY_NUM ]
then
ARGY_WARNING="$(printf "${RED}$ARGY_NUM${WHITE}")"
else
ARGY_WARNING="$(printf "${WHITE}$ARGY_NUM")"
fi
CARTE_BREAKFAST_NUM="$CARTE_BREAKFAST_NUM"$ARGY_WARNING"."
COUNT_ARGY="$(expr $COUNT_ARGY + 1)"
done
TOTAL_BREAKFAST=""$MENU""$CARTE_BREAKFAST_NUM""
CARTE_BREAKFAST_A="$CARTE_BREAKFAST_A"$TOTAL_BREAKFAST" "
COUNT="$(expr $COUNT + 1)"
done
CARTE_BREAKFAST="$(echo "$CARTE_BREAKFAST_A"DEL | sed "s/"$MENU\ DEL"/""/")"
}

function CENCOR_ALLERGY_LUNCH(){
MENU_NUM=$(echo "$CARTE_LUNCH " | tr -cd " " | wc -m)
COUNT=1
while [ $COUNT -le "$MENU_NUM" ]
do
LC="$(echo "$CARTE_LUNCH " | cut -f $COUNT -d" ")"
NUM_ARGY=$(echo "$LC" | tr -cd "." | wc -m)
COUNT_ARGY=1
if [ $COUNT_ARGY = 1 ]
then
MENU="$(echo "$LC" | cut -f $COUNT_ARGY -d"." | tr -d [0-9])"
fi
unset CARTE_LUNCH_NUM
while [ $COUNT_ARGY -le "$NUM_ARGY" ]
do
ARGY_NUM="$(echo "$LC" | cut -f $COUNT_ARGY -d"." | sed 's/[^0-9]//g')"
if [ -e $TARGET_DOWNLOAD/$ARGY_NUM ]
then
ARGY_WARNING="$(printf "${RED}$ARGY_NUM${WHITE}")"
else
ARGY_WARNING="$(printf "${WHITE}$ARGY_NUM")"
fi
CARTE_LUNCH_NUM="$CARTE_LUNCH_NUM"$ARGY_WARNING"."
COUNT_ARGY="$(expr $COUNT_ARGY + 1)"
done
TOTAL_LUNCH=""$MENU""$CARTE_LUNCH_NUM""
CARTE_LUNCH_A="$CARTE_LUNCH_A"$TOTAL_LUNCH" "
COUNT="$(expr $COUNT + 1)"
done
CARTE_LUNCH="$(echo "$CARTE_LUNCH_A"DEL | sed "s/"$MENU\ DEL"/""/")"
}

function CENCOR_ALLERGY_DINNER(){
MENU_NUM=$(echo "$CARTE_DINNER " | tr -cd " " | wc -m)
COUNT=1
while [ $COUNT -le "$MENU_NUM" ]
do
DN="$(echo "$CARTE_DINNER " | cut -f $COUNT -d" ")"
NUM_ARGY=$(echo "$DN" | tr -cd "." | wc -m)
COUNT_ARGY=1
if [ $COUNT_ARGY = 1 ]
then
MENU="$(echo "$DN" | cut -f $COUNT_ARGY -d"." | tr -d [0-9])"
fi
unset CARTE_DINNER_NUM
while [ $COUNT_ARGY -le "$NUM_ARGY" ]
do
ARGY_NUM="$(echo "$DN" | cut -f $COUNT_ARGY -d"." | sed 's/[^0-9]//g')"
if [ -e $TARGET_DOWNLOAD/$ARGY_NUM ]
then
ARGY_WARNING="$(printf "${RED}$ARGY_NUM${WHITE}")"
else
ARGY_WARNING="$(printf "${WHITE}$ARGY_NUM")"
fi
CARTE_DINNER_NUM="$CARTE_DINNER_NUM"$ARGY_WARNING"."
COUNT_ARGY="$(expr $COUNT_ARGY + 1)"
done
TOTAL_DINNER=""$MENU""$CARTE_DINNER_NUM""
CARTE_DINNER_A="$CARTE_DINNER_A"$TOTAL_DINNER" "
COUNT="$(expr $COUNT + 1)"
done
CARTE_DINNER="$(echo "$CARTE_DINNER_A"DEL | sed "s/"$MENU\ DEL"/""/")"
}

function CENCOR_ALLERGY_CLEAR(){
find $TARGET_DOWNLOAD/* ! -name cafeteria.html -exec rm {} \;
}

function DOWN_CARTE(){
case $1 in
서울특별시 )
SCHOOL_REGION=stu.sen.go.kr
;;
인천광역시 )
SCHOOL_REGION=stu.ice.go.kr
;;
부산광역시 )
SCHOOL_REGION=stu.pen.go.kr
;;
광주광역시 )
SCHOOL_REGION=stu.gen.go.kr
;;
대전광역시 )
SCHOOL_REGION=stu.dje.go.kr
;;
대구광역시 )
SCHOOL_REGION=stu.dge.go.kr
;;
세종특별자치시 )
SCHOOL_REGION=stu.sje.go.kr
;;
울산광역시 )
SCHOOL_REGION=stu.use.go.kr
;;
경기도 )
SCHOOL_REGION=stu.goe.go.kr
;;
강원도 )
SCHOOL_REGION=stu.kwe.go.kr
;;
충청북도 )
SCHOOL_REGION=stu.cbe.go.kr
;;
충청남도 )
SCHOOL_REGION=stu.cne.go.kr
;;
경상북도 )
SCHOOL_REGION=stu.gbe.go.kr
;;
경상남도 )
SCHOOL_REGION=stu.gne.go.kr
;;
전라북도 )
SCHOOL_REGION=stu.jbe.go.kr
;;
전라남도 )
SCHOOL_REGION=stu.jne.go.kr
;;
제주특별자치도 )
SCHOOL_REGION=stu.jje.go.kr
;;
esac
wget -q -O $TARGET --no-check-certificate --user-agent="Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.3) Gecko/2008092416 Firefox/3.0.3" "http://$SCHOOL_REGION/sts_sci_md00_001.do?&schulCode=$SCHOOL_CODE&schulCrseScCode=4&schulKndScCode=04&schYm=$YEAR$MONTH"
}

function LANG(){
if [ $1 = eng ]
then
case $2 in
ASK_ALLERGY )
echo "Type your allegry (ADD one by one, DONE: 0)"
;;
ADDED_ALLERGY )
echo "Current registered allergy number"
;;
ADD_BACKGROUND )
echo "Adding to the desktop"
;;
ADD_DESKTOP )
echo "1. Right click on your desktop
2. Click 'New'
3. Click 'Shortcut'
4. Copy & Paste C:\Windows\System32\bash.exe -c \"$MAIN_DIR/cafeteria eng -d $SCHOOL_CODE\"
5. Name your shortcut
6. Done"
;;
ALREAY_ADDED )
printf "${RED}This number is already registered{WHITE}"
;;
ALLERGY_TITLE )
echo "Allergy Information"
;;
ALLERGY_INFO )
echo "1.Egg 2.Milk 3.Buckwheat 4.Peanut 5.Soybean 6.Wheat 7.Chub mackerel 8.Crab 9.Shrimp 10.Pork 11.Peach 12.Tomato 13.Sodium sulfite 14.Walnut 15.Chicken 16.Beaf 17.Squid 18.Shellfish(Including Oyster,Abalone,Mussel)"
;;
CACHE_SIZE )
echo "CACHE TOTAL"
;;
CARTE_BREAKFAST )
echo "BREAKFAST"
;;
CARTE_LUNCH )
echo "LUNCH"
;;
CARTE_DINNER )
echo "DINNER"
;;
CARTE_CANCEL )
printf "${RED}CANCEL (취소){WHITE}"
;;
CARTE_MONTHLY )
echo "MONTH"
;;
CARTE_NODATA )
echo "NOTHING"
;;
CARTE_TODAY )
echo "TODAY"
;;
CARTE_SELECT )
echo "SELECT"
;;
CHECK_CAHCE )
echo "Checking cache..."
;;
CLEAR_FILE )
echo "Clearing..."
;;
DATE_DAYOFAWEAK )
if [ $TODAY = Mon ]
then
echo "Mon"
elif [ $TODAY = Tue ]
then
echo "Tue"
elif [ $TODAY = Wed ]
then
echo "Wed"
elif [ $TODAY = Thu ]
then
echo "Thu"
elif [ $TODAY = Fri ]
then
echo "Fri"
elif [ $TODAY = Sat ]
then
echo "Sat"
elif [ $TODAY = Sun ]
then
echo "Sun"
fi
;;
DATE_FULL )
echo "DATE"
;;
DATE_HOUR )
echo "TIME"
;;
DISPLAY_HELP )
echo "Usage: ./cafeteria [LANG] [OPTION1] [OPTION2]

		[LANG]
		default (no type): Korean
		eng: English

		[OPTION1]
		-c: clear OPTION2
		-d: display directly
		argy: add your allergy informations and display for warning
		rtime: measure script running time
		help: display help
		   
		[OPTION2]
		cache: clear downloaded school info (ONLY FOR -c OPTION)
		argy: clear allegry info (ONLY FOR -c OPTION)
		school_code: display directly (ONLY FOR -d OPTION)"
;;
DOWN_CARTEINFO )
echo "Downloading table of menus information..."
;;
DOWN_SCHOOLCODE )
echo "Downloading school code..."
;;
ERROR_DONOTUSESHORT )
printf "${RED}Abbreviations not available${WHITE}"
;;
ERROR_DONOTUSESPACE )
printf "${RED}Unable to enter space${WHITE}"
;;
ERROR_FAILDREQUEST )
printf "${RED}False request.${WHITE}"
;;
ERROR_NODATA )
printf "${RED}NO DATA${WHITE}"
;;
ERROR_NOTFOUNDLOG )
printf "${RED}There is no record.${WHITE}"
;;
ERROR_NOT_SUPPORT_YET )
printf "${RED}Not supported yet.${WHITE}"
;;
LOCATION_NAME )
echo "LOCAL"
;;
LOADING_NOTICE )
echo "Loading notice..."
;;
LOAD_SCHOOL )
echo " schools loaded"
;;
PRESS_ANYKEY )
echo "Press any key"
;;
REMOVE_CACHE )
echo "Removing cache..."
;;
RESULT_EXIT )
echo "Exit script"
;;
RESULT_FAILD )
printf "${RED}FAILED${WHITE}"
;;
RESULT_SUCCESS )
echo "OK"
;;
SCHOOL_NAME )
echo "SCHOOL"
;;
SCRIPT_TITLE )
echo "~ A National High School Diet Chart ~"
;;
SEARCH_SCHOOL )
echo "High School Search"
;;
SEARCH_WORDS )
echo "WORDS"
;;
UPDATE_NEWVERSION )
echo "Updating with new information..."
;;
UPLOAD_SCHOOLID )
echo "Don't you see which school you want?"
;;
UPLOAD_SCHOOLID_TITLE )
echo "SCHOOL REQUEST (@: REQUIRED)"
;;
UPLOAD_SCHOOLID_SITE )
echo "School Homepage"
;;
UPLOAD_SCHOOLID_REGION )
echo "@ School Region (sen, ice...)"
;;
UPLOAD_SCHOOLID_NAME )
echo "@ School Name (FULLNAME)"
;;
UPLOAD_SCHOOLID_REQUEST )
echo "Requesting..."
;;
esac
elif [ $1 = kor ]
then
case $2 in
ASK_ALLERGY )
echo "등록할 알레르기의 번호를 입력하세요 (하나씩 등록, 완료: 0)"
;;
ADDED_ALLERGY )
echo "현재 등록된 알레르기 번호"
;;
ADD_BACKGROUND )
echo "바탕화면에 추가"
;;
ADD_DESKTOP )
echo "1. 바탕화면 우클릭
2. '새로 만들기' 클릭
3. '바로 가기' 클릭
4. C:\Windows\System32\bash.exe -c \"$MAIN_DIR/cafeteria -d $SCHOOL_CODE\" 복사 후 붙여넣기
5. '바로 가기' 이름 정하기
6. 완료"
;;
ALREAY_ADDED )
printf "${RED}이미 등록되어 있는 번호입니다${WHITE}"
;;
ALLERGY_TITLE )
echo "알레르기 정보"
;;
ALLERGY_INFO )
echo "1.난류 2.우유 3.메밀 4.땅콩 5.대두 6.밀 7.고등어 8.게 9.새우 10.돼지고기 11.복숭아 12.토마토 13.아황산류 14.호두 15.닭고기 16.쇠고기 17.오징어 18.조개류(굴,전복,홍합 포함)"
;;
CACHE_SIZE )
echo "캐시크기"
;;
CARTE_BREAKFAST )
echo "조식"
;;
CARTE_LUNCH )
echo "점심"
;;
CARTE_DINNER )
echo "저녁"
;;
CARTE_CANCEL )
printf "${RED}취소 (CANCEL)${WHITE}"
;;
CARTE_MONTHLY )
echo "월간식단"
;;
CARTE_NODATA )
printf "${RED}없음${WHITE}"
;;
CARTE_TODAY )
echo "오늘식단"
;;
CARTE_SELECT )
echo "선택"
;;
CHECK_CAHCE )
echo "캐시 확인 중..."
;;
CLEAR_FILE )
echo "초기화 중..."
;;
DATE_DAYOFAWEAK )
if [ $TODAY = Mon ]
then
echo "월"
elif [ $TODAY = Tue ]
then
echo "화"
elif [ $TODAY = Wed ]
then
echo "수"
elif [ $TODAY = Thu ]
then
echo "목"
elif [ $TODAY = Fri ]
then
echo "금"
elif [ $TODAY = Sat ]
then
echo "토"
elif [ $TODAY = Sun ]
then
echo "일"
fi
;;
DATE_FULL )
echo "날짜"
;;
DATE_HOUR )
echo "시간"
;;
DISPLAY_HELP )
echo "사용법: ./cafeteria [언어] [옵션1] [옵션2]

		[언어]
		기본 (무입력): 한국어
		eng: 영어
          
		[옵션1]
		-c: OPTION2를 청소
		-d: 식단표 바로 표시
		argy: 알레르기 정보를 추가하고 식단표에 경고를 표시합니다
		rtime: 스크립트 실행시간을 측정합니다 (디버그)
		help: 도움말
		   
		[OPTION2]
		cache: 저장된 학교정보를 제거합니다 (-c 옵션전용)
		argy: 저장된 알레르기 정보를 제거합니다 (-c 옵션전용)
		학교코드: 식단표 바로 표시 (-d 옵션전용)"
;;
DOWN_CARTEINFO )
echo "식단표 정보 다운로드 중..."
;;
DOWN_SCHOOLCODE )
echo "학교코드 다운로드 중..."
;;
ERROR_DONOTUSESHORT )
printf "${RED}약어 사용 불가${WHITE}"
;;
ERROR_DONOTUSESPACE )
printf "${RED}공백 입력 불가${WHITE}"
;;
ERROR_FAILDREQUEST )
printf "${RED}잘못된 요청입니다${WHITE}"
;;
ERROR_NODATA )
printf "${RED}결과없음${WHITE}"
;;
ERROR_NOTFOUNDLOG )
printf "${RED}검색기록이 존재하지 않습니다.${WHITE}"
;;
ERROR_NOT_SUPPORT_YET )
printf "${RED}아직 지원히지 않습니다${WHITE}"
;;
LOCATION_NAME )
echo "지역"
;;
LOADING_NOTICE )
echo "공지 불러오는 중..."
;;
LOAD_SCHOOL )
echo "곳의 학교"
;;
PRESS_ANYKEY )
echo "종료하려면 아무 키나 누르세요"
;;
REMOVE_CACHE )
echo "캐시 제거 중..."
;;
RESULT_FAILD )
printf "${RED}실패${WHITE}"
;;
RESULT_SUCCESS )
echo "성공"
;;
RESULT_EXIT )
echo "스크립트를 종료합니다"
;;
SCHOOL_NAME )
echo "학교명"
;;
SCRIPT_TITLE )
echo "~ 전국 고등학교 식단표 ~"
;;
SEARCH_SCHOOL )
echo "고등학교 검색"
;;
SEARCH_WORDS )
echo "검색어"
;;
UPDATE_NEWVERSION )
echo "새로운 정보로 업데이트 중..."
;;
UPLOAD_SCHOOLID )
echo "원하는 학교가 표시되지 않습니까?"
;;
UPLOAD_SCHOOLID_TITLE )
echo "학교 신청서 (@: 필수)"
;;
UPLOAD_SCHOOLID_SITE )
echo "학교 홈페이지 주소"
;;
UPLOAD_SCHOOLID_REGION )
echo "@ 학교지역 (경기도, 강원도...)"
;;
UPLOAD_SCHOOLID_NAME )
echo "@ 학교이름 (풀네임)"
;;
UPLOAD_SCHOOLID_REQUEST )
echo "신청하는 중..."
;;
esac
fi
}

case "$1" in

eng )
LANG=eng
if [ "$2" = nn ]
then
NOTICE_DP=0
else
NOTICE_DP=1
fi
if [ "$2" = rtime ]
then
RTIME=0
else
RTIME=1
fi
if [ "$2" = argy ]
then
ADD_ALLERGY=1
fi
if [ "$2" = help ]
then
DISPLAY_HELP
fi
if [ "$2" = "-d" ]
then
DIRECT_DISPLAY=1
THIRD=1
fi
if [ "$2" = "-s" ]
then
THIRD=1
DIRECT_DISPLAY_SELETED=1
fi
;;

rtime )
LANG=kor
RTIME=1
NOTICE_DP=1
;;

argy )
LANG=kor
ADD_ALLERGY=1
;;

help )
LANG=kor
DISPLAY_HELP
;;

-d )
LANG=kor
DIRECT_DISPLAY=1
THIRD=0
;;

-s )
LANG=kor
THIRD=0
DIRECT_DISPLAY_SELETED=1
;;

* )
LANG=kor
NOTICE_DP=1
;;
esac

if [ "$DISPLAY_HELP" = 1 ]
then
DISPLAY_HELP
fi

if [ "$RTIME" = 1 ]
then
START_SCRIPT_TIME="$(date +%s)"
fi

if [ "$DIRECT_DISPLAY_SELETED" = 1 ]
then
if [ "$THIRD" = 0 ]
then
TARGET="$TARGET_CACHE/$2.cache"
DIRECT_DISPLAY_SELETED $3
elif [ "$THIRD" = 1 ]
then
TARGET="$TARGET_CACHE/$3.cache"
DIRECT_DISPLAY_SELETED $4
fi
fi

if [ "$DIRECT_DISPLAY" = 1 ]
then
if [ "$THIRD" = 0 ]
then
TARGET="$TARGET_CACHE/$2.cache"
elif [ "$THIRD" = 1 ]
then
TARGET="$TARGET_CACHE/$3.cache"
fi
DIRECT_DISPLAY
fi

case "$ADD_ALLERGY" in
1 )
echo "! $(LANG $LANG CLEAR_FILE)"
PRT_ALLERGY
echo ""
echo "" > $TARGET_CACHE/ADDED_ALLERGY
COUNT_ADD_ARGY=1
while true
do
read -p "! $(LANG $LANG ADDED_ALLERGY): $ADDED_ALLERGY_NOW

* $(LANG $LANG ASK_ALLERGY): " NUM_ALLERGY

if [ "$NUM_ALLERGY" = 0 ]
then
echo "! $(LANG $LANG RESULT_EXIT)"
break
fi
if [ "$COUNT_ADD_ARGY" != 1 ]
then
if [ "$(grep -w "$NUM_ALLERGY" $TARGET_CACHE/ADDED_ALLERGY)" = "$ADDED_ALLERGY_NOW" ]
then
echo "@ $(LANG $LANG ALREAY_ADDED)"
else
ADDED_ALLERGY_NOW=""$ADDED_ALLERGY_NOW"$NUM_ALLERGY,"
echo "$ADDED_ALLERGY_NOW" > $TARGET_CACHE/ADDED_ALLERGY
fi
else
ADDED_ALLERGY_NOW=""$ADDED_ALLERGY_NOW"$NUM_ALLERGY,"
echo "$ADDED_ALLERGY_NOW" > $TARGET_CACHE/ADDED_ALLERGY
fi
COUNT_ADD_ARGY="$(expr $COUNT_ADD_ARGY + 1)"
done
exit 0
;;
esac

if [ "$(find $TARGET_CACHE -maxdepth 1 -type f -name "*" | head -n 1)" != "" ]
then
CACHE_TOTAL="$(expr "$(find $TARGET_CACHE -maxdepth 1 -type f -name "*" -ls | awk '{ result += $7 } END { print result }')" / 1024)KB"
else
CACHE_TOTAL="0KB"
fi

case $1 in
-l|--log )
if [ ! -e $TARGET_CACHE/.SEARCH_LOG ]
then
echo "! ERROR: $(LANG $LANG ERROR_NOTFOUNDLOG)"
exit 0
fi
echo "      |$(LANG $LANG DATE_FULL)|    |$(LANG $LANG DATE_FULL)|    |$(LANG $LANG LOCATION_NAME)|      |$(LANG $LANG SCHOOL_NAME)|   |$(LANG $LANG SEARCH_WORDS)|"
cat $TARGET_CACHE/.SEARCH_LOG
exit 0
;;
-c|--clear )
if [ "$2" = cache ]
then
echo -n "! $(LANG $LANG REMOVE_CACHE)"
find $TARGET_CACHE/*.cache ! -name ADDED_ALLERGY -exec rm {} \; 2> /dev/null
echo " [$(LANG $LANG RESULT_SUCCESS)]"
fi
if [ "$2" = argy ]
then
echo -n "! $(LANG $LANG REMOVE_CACHE)"
rm $TARGET_CACHE/ADDED_ALLERGY 2> /dev/null
echo " [$(LANG $LANG RESULT_SUCCESS)]"
fi
exit 0
;;
* )
#clear
;;
esac
if [ "$CACHE_TOTAL" = "KB" ]
then
CACHE_TOTAL="$(LANG $LANG ERROR_NODATA)"
fi
if [ ! -e $SCHOOL_CODE_INFO ]
then
echo -n "! $(LANG $LANG DOWN_SCHOOLCODE)"
wget -q -O $SCHOOL_CODE_INFO "http://mokky.dothome.co.kr/cafeteria/cache/school_code/school_code.db"
if [ -e $SCHOOL_CODE_INFO ]
then
echo " [$(LANG $LANG RESULT_SUCCESS)]
"
else
echo " [$(LANG $LANG RESULT_FAILED)]"
exit 0
fi
fi
START_ULOG_TIME="$(date +%s)"
echo "$(LANG $LANG SCRIPT_TITLE)
! $(nl $SCHOOL_CODE_INFO | tail -n 1 | awk '{print $1}')$(LANG $LANG LOAD_SCHOOL)
! $(LANG $LANG CACHE_SIZE): $CACHE_TOTAL"
STOP_ULOG_TIME="$(date +%s)"
START_SEARCH_TIME="$(date +%s)"
read -p "* $(LANG $LANG SEARCH_SCHOOL): " search
STOP_SEARCH_TIME="$(date +%s)"
if [ "$search" != "" ]
then
SCHOOL_NUM=0
echo "==========================================="
for i in $(grep "$search" $SCHOOL_CODE_INFO | awk '{print $3}')
do
if [ -e "$TARGET_CACHE/$(grep $i $SCHOOL_CODE_INFO | awk '{print $1}').cache" ]
then
PRINT_CACHE="[C] "
else
unset PRINT_CACHE
fi
SCHOOL_NUM=$(expr $SCHOOL_NUM + 1)
echo "$SCHOOL_NUM. $PRINT_CACHE$i"
done
if [ "$SCHOOL_NUM" = 0 ]
then
echo "$(LANG $LANG ERROR_NODATA)"
else
echo "0. $(LANG $LANG CARTE_CANCEL)"
fi
echo "==========================================="
elif [ "$search" == "" ]
then
SCHOOL_NUM=0
fi
START_PROCEED_TIME="$(date +%s)"
case $SCHOOL_NUM in
0 )
read -p "! $(LANG $LANG ERROR_DONOTUSESHORT)
! $(LANG $LANG ERROR_DONOTUSESPACE)

! $(LANG $LANG UPLOAD_SCHOOLID) [y/n]: " upload
;;
1 )
select=1
read -p "b. $(LANG $LANG ADD_BACKGROUND)
* $(LANG $LANG CARTE_TODAY)=1, $(LANG $LANG CARTE_MONTHLY)=2 [$(LANG $LANG CARTE_SELECT)]: " seltype
if [ "$seltype" = b ]
then
SCHOOL_CODE=$(grep $search $SCHOOL_CODE_INFO | awk '{print $1}' | head -n $select | tail -n 1)
echo "
$(LANG $LANG ADD_DESKTOP)
"
read -s -n1 -p "$(LANG $LANG PRESS_ANYKEY)" press
echo ""
exit 0
fi
if [ "$seltype" = 1 ]
then
PRINT_TYPE=TODAY
elif [ "$seltype" = 2 ]
then
PRINT_TYPE=MONTHLY
elif [ "$seltype" = "0" ]
then
echo "! $(LANG $LANG RESULT_EXIT)"
exit 0
else
echo "! $(LANG $LANG ERROR_FAILDREQUEST)"
exit 0
fi
;;
* )
read -p "* $(LANG $LANG CARTE_SELECT): " select
if [ "$select" = "" ]
then
echo "! $(LANG $LANG ERROR_DONOTUSESPACE)"
exit 0
fi
if [ "$(echo $select | cut -b1)" = "m" ]
then
PRINT_TYPE=MONTHLY
select="$(echo $select | rev | cut -d'm' -f1 | rev)"
elif [ "$select" = "0" ]
then
echo "! $(LANG $LANG RESULT_EXIT)"
exit 0
else
PRINT_TYPE=TODAY
fi
;;
esac
SCHOOL_NAME=$(grep $search $SCHOOL_CODE_INFO | awk '{print $3}' | head -n $select | tail -n 1)
SCHOOL_CODE=$(grep $search $SCHOOL_CODE_INFO | awk '{print $1}' | head -n $select | tail -n 1)
SCHOOL_REGION_NAME=$(grep $search $SCHOOL_CODE_INFO | awk '{print $2}' | head -n $select | tail -n 1)
if [ -e $TARGET_CACHE/$SCHOOL_CODE.cache ]
then
USE_CACHE=1
else
USE_CACHE=0
fi
case $USE_CACHE in
1 )
echo -n "! $(LANG $LANG CHECK_CAHCE)"
TARGET_CACHE_DATE=$(grep ?schYm $TARGET_CACHE/$SCHOOL_CODE.cache | head -n 1 | cut -d'"' -f2 | rev | cut -d"=" -f1 | rev)
if [ "$TARGET_CACHE_DATE" != "$YEAR$MONTH" ]
then
echo " [$(LANG $LANG RESULT_FAILD)]"
echo -n "! $(LANG $LANG UPDATE_NEWVERSION)"
DOWN_CARTE $SCHOOL_REGION_NAME
echo " [$(LANG $LANG RESULT_SUCCESS)]"
elif [ "$TARGET_CACHE_DATE" = "$YEAR$MONTH" ]
then
echo " [$(LANG $LANG RESULT_SUCCESS)]"
TARGET=$TARGET_CACHE/$SCHOOL_CODE.cache
fi
;;
0 )
echo -n "! $(LANG $LANG DOWN_CARTEINFO)"
DOWN_CARTE $SCHOOL_REGION_NAME
if [ -e $TARGET ]
then
echo " [$(LANG $LANG RESULT_SUCCESS)]"
else
echo " [$(LANG $LANG RESULT_FAILD)]"
exit 0
fi
;;
esac
sed -i -e 's/\s//g' $TARGET
echo "
| $YEAR. $MONTH |
"
case $PRINT_TYPE in
TODAY )
if [ "$(date +%d | cut -b1)" = "0" ]
then
i=$(date +%d | cut -b2)
else
i=$(date +%d)
fi
PARS_COMMON
PARS_PRINT
;;
MONTHLY )
LAST_DAY=$(date -d "-$(date +%d) days +1 month" +%d)
for i in $(seq 1 $LAST_DAY)
do
if [ "$(echo $i | cut -b2)" = "" ]
then
DATE="0$i"
else
DATE=$i
fi
TODAY=$(date -d $YEAR$MONTH$DATE | awk '{print $1}')
PARS_COMMON
PARS_PRINT
done
;;
esac
STOP_PROCEED_TIME="$(date +%s)"
PRT_ALLERGY
CLR_SCRIPT
if [ "$RTIME" = 1 ]
then
STOP_SCRIPT_TIME="$(date +%s)"
TOTAL_ULOG_TIME="$(expr $STOP_ULOG_TIME - $START_ULOG_TIME)"
TOTAL_SEARCH_TIME="$(expr $STOP_SEARCH_TIME - $START_SEARCH_TIME)"
TOTAL_PROCEED_TIME="$(expr $STOP_PROCEED_TIME - $START_PROCEED_TIME)"
TOTAL_RUNNING_TIME="$(expr $STOP_SCRIPT_TIME - $START_SCRIPT_TIME)"
echo "
--- SEARCH TIME: $TOTAL_SEARCH_TIME sec
--- PROCEED TIME: $TOTAL_PROCEED_TIME sec
--- TOTAL RUNNING TIME: $TOTAL_RUNNING_TIME sec"
fi
