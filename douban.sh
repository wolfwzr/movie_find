#! /bin/bash

LIST_BASE_URL="http://movie.douban.com/tag/"
JSON_BASE_URL="https://api.douban.com/v2/movie/"

 DB_FILE="movie.db"
 SQL_TXT="insert.sql"
TAG_FILE="tags"

 PDF_OUTPUT="douban_movie.pdf"
HTML_OUTPUT="douban_movie.html"
GEN_HTML_SQL_FILE="gen_html.sql"
HTML2PDF="wkhtmltopdf"

LIST_FILE="$(mktemp)"
TMP="$(mktemp)"

FIREFOX_AGENT_STRING="Mozilla/5.0 (Windows NT 6.1; WOW64; rv:23.0) Gecko/20130406 Firefox/23.0"
AGENT_STRING="$FIREFOX_AGENT_STRING"

my_wget()
{
    local src
    local file

    [ $# -ne 2 ] && {
        echo "Usage: my_wget <src> <file>"
        return
    }

    src=$1
    file=$2
    wget -c --user-agent="$AGENT_STRING" -o /dev/null -O "$file" "$src" 
}

# 创建数据库和表
create_db()
{
    sqlite3 "$DB_FILE" << EOF
CREATE TABLE movie(
    id INTERGER PRIMARY KEY,
    average REAL,
    numRaters INTERGER,
    title TEXT NOT NULL,
    alt_title TEXT,
    image TEXT NOT NULL,
    country TEXT,
    year TEXT,
    language TEXT,
    director TEXT,
    cast TEXT,
    type TEXT,
    summary TEXT
);
EOF
}

# 执行SQL语句
exec_sql()
{
    sqlite3 "$DB_FILE" ".read $SQL_TXT"
}

# 解析json文件并生成SQL语句
gen_sql()
{
    local id

    cat /dev/null > "$SQL_TXT"
    for json in json/*; do 
        id=${json##*/}
        id=${id%%\.json}
        echo "[PRASE] $json"
        python gen_sql_by_jsons.py "$json" "$id" >> "$SQL_TXT"
    done 
}

# 生成html格式报告
gen_html_report()
{
    cat > "$HTML_OUTPUT" << EOF
<html> 
    <head><meta http-equiv="content-type" content="text/html;charset=utf-8"></head>
    <body>
EOF
    sqlite3 -separator "" "$DB_FILE" ".read $GEN_HTML_SQL_FILE" >> "$HTML_OUTPUT"
    cat >> "$HTML_OUTPUT" << EOF
    <P align="left"><FONT SIZE="2" COLOR="BLUE">GitHub Project: <a href="https://github.com/wolfwzr/movie_find">https://github.com/wolfwzr/movie_find</a></FONT><br>
    <FONT SIZE="2" COLOR="BLUE">小白狼出品</FONT></P>
    </body> 
</html>
EOF
}

# 生成pdf格式报告
gen_pdf_report()
{
    gen_html_report
    "${HTML2PDF}" "$HTML_OUTPUT" "$PDF_OUTPUT"
}

# 下载数据库中所有电影的封面
down_images()
{
    local info="$(mktemp)"
    local id
    local image
    local image_name
    local wget_cnt
    local max_wget=100

    mkdir -p images
    sqlite3 "$DB_FILE" "SELECT id,image FROM movie;" > "$info"
    while read line; do
        id=${line%%|*}
        image=${line##*|}
        image_name="${id}.jpg"
        while :; do
            wget_cnt=$(pgrep -c wget)
            [ "$wget_cnt" -lt "$max_wget" ] && {
                echo "[ GET ] $image"
                my_wget "$image" "images/$image_name" &
                break
            } || {
                echo "[SLEEP] wget number: $wget_cnt"
                sleep 1
            }
        done
    done < "$info"
    # 等待下载完成
    while :; do
        wget_cnt=$(pgrep -c wget)
        [ "$wget_cnt" -ne 0 ] && {
            echo "[SLEEP] wget number: $wget_cnt"
            sleep 1
        } || break
    done
    rm -f "$info"
}

# 下载指定电影列表网页的电影信息（json文件）
# 参数一：目标网址
get_movies_by_page()
{
    local num
    local index
    local page_url
    local wget_cnt
    local json_url
    local json_file

    [ $# -ne 1 ] && {
        echo "Usage: deal_with_page <page_url>"
        return
    }

    page_url="$1"
    echo "[ GET ] $page_url"
    my_wget "$page_url" "$LIST_FILE"
    grep 'class="nbg"' "$LIST_FILE" | grep -o "http://movie.douban.com/subject/[0-9]*" | sort | uniq > "$TMP"
    while read movie_page_url; do
        index=${movie_page_url##*/}
        json_url="$JSON_BASE_URL/$index"
        json_file="json/${index}.json"
        echo "[ GET ] $json_file"
        # 后台下载电影信息(json文件）以加快下载速度
        my_wget "$json_url" "$json_file" &
    done < "$TMP"

    # 等待当前页面的电影信息(json文件)全部下载完成
    while :; do
        wget_cnt=$(pgrep -c wget)
        [ "$wget_cnt" -eq 0 ] && break || {
            echo "[SLEEP] wget number: $wget_cnt"
            sleep 1
        }
    done
}

# 根据标签获取电影信息（下载json文件）
# 参数一：目标标签
get_movies_by_tag()
{
    local tag
    local tag_list_url

    [ $# -ne 1 ] && {
        echo "Usage: get_jsons_by_tag <tag>"
        return
    }

    tag=$1
    tag_list_url="$LIST_BASE_URL/$tag"
    while :; do
        [ -z "$tag_list_url" ] && break
        # 解析当前页面的电影列表
        get_movies_by_page "$tag_list_url"
        # 获取下一页地址
        my_wget "$tag_list_url" "$LIST_FILE"
        tag_list_url=$(grep -o "<[^<]*后页" "$LIST_FILE" | grep -o "http://[^\"]*")
    done
}

just_test()
{
    #gen_html_report
    gen_pdf_report
    rm -f "$TMP" "$LIST_FILE"
    exit 0
}

########### Code Start From Here ###########

mkdir -p json images

#just_test

while read tag; do
    get_movies_by_tag "$tag"
done < "$TAG_FILE"
rm -f "$TMP" "$LIST_FILE"

gen_sql
create_db
exec_sql
down_images
gen_html_report
gen_pdf_report
exit 0
