

put_progress() {
    # env: TITLE
    local PROGRESS="$1"
    local PREFIX=$(printf "%s %3d%% [" "$TITLE" "$PROGRESS" )
    local SUFFIX="]"
    local PREFIX_LEN=${#PREFIX}
    local SUFFIX_LEN=${#SUFFIX}
    # 为了支持中文Title（2字符宽度），title长度需要要减去两次。已经在PREFIX减去过长度了，这里在减去1次。
    local TITLE_LEN=${#TITLE} 
    local WIDTH=$(stty -F /dev/tty size | cut -d' ' -f 2)
    local BAR_WIDTH=$(( WIDTH - PREFIX_LEN - SUFFIX_LEN - TITLE_LEN ))
    local RATE
    local i

    echo -ne "\r${PREFIX}"
    for (( i=1; i<=BAR_WIDTH; i++ )); do
        let "RATE= i*100 / BAR_WIDTH"
        if (( RATE <= PROGRESS )) && (( PROGRESS != 0 )); then
            echo -ne "#"
        else
            echo -ne " "
        fi
    done
    echo -ne "${SUFFIX}\r"
}

fake_progress_bar() {
    local PROGRESS="$1"
    local SEC="$2"
    local TIMES=$(( SEC * 5 ))
    local i
    put_progress 0
    for (( i=1; i<=TIMES; i++ )); do
        sleep 0.2
        put_progress $(( PROGRESS * i / TIMES ))
    done
    echo
}

active_progress_bar() {
    local PROGRESS
    local TIMELEFT # 剩余全部秒数
    local SEC_LEFT # 剩余秒数
    local MINUTE_LEFT # 剩余分钟数
    put_progress 0
    while read PROGRESS TIMELEFT; do
        if [[ "$TIMELEFT" != "" ]];then
            let "SEC_LEFT=TIMELEFT % 60"
            let "MINUTE_LEFT=TIMELEFT / 60"
            TITLE="剩余时间: ${MINUTE_LEFT}分钟${SEC_LEFT}秒" put_progress "$PROGRESS"
        else
            put_progress "$PROGRESS"
        fi
    done
    echo
}


test_put_progress(){
    put_progress 2
}

test_fake_progress_bar(){
    TITLE="进度条测试Title" fake_progress_bar 100 25
}

test_active_progress_bar() {
    local TIMELEFT
    local i
    local SUM=$1
    for (( i=0; i<=SUM; i++ )); do
        let "TIMELEFT=(SUM-i) / 5"
        echo "$i" "$TIMELEFT"
        sleep 0.2
    done | active_progress_bar
}

test_active_progress_bar 32
