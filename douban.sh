#! /bin/bash

LIST_BASE_URL="http://movie.douban.com/tag/"
JSON_BASE_URL="https://api.douban.com/v2/movie/"

DB_FILE=movie.db
SQL_TXT=insert.sql

 PDF_OUTPUT="douban_movie.pdf"
HTML_OUTPUT="douban_movie.html"
GEN_HTML_SQL_FILE="gen_html.sql"
HTML2PDF="wkhtmltopdf"

LIST_FILE=".list.html"
TMP=".tmp"

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

exec_sql()
{
    sqlite3 "$DB_FILE" ".read $SQL_TXT"
}

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

gen_html()
{
    cat > "$HTML_OUTPUT" << EOF
<html> 
    <head><meta http-equiv="content-type" content="text/html;charset=utf-8"></head>
    <body>
EOF
    sqlite3 -separator "" "$DB_FILE" ".read $GEN_HTML_SQL_FILE" >> "$HTML_OUTPUT"
    cat >> "$HTML_OUTPUT" << EOF
    <P><h3><FONT SIZE="2" COLOR="BLUE">Project: https://github.com/wolfwzr/movie_find.git</FONT></h3></P>
    </body> 
</html>
EOF
}

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
                echo "[GET] $image"
                wget -c -o /dev/null -O "images/$image_name" "$image" &
                break
            } || {
                echo "[SLEEP] wget number: $wget_cnt"
                sleep 1
            }
        done
    done < "$info"
    # waitting for download complete
    while :; do
        wget_cnt=$(pgrep -c wget)
        [ "$wget_cnt" -ne 0 ] && {
            echo "[SLEEP] wget number: $wget_cnt"
            sleep 1
        } || break
    done
    rm -f "$info"
}

gen_pdf()
{
    gen_html
    "${HTML2PDF}" "$HTML_OUTPUT" "$PDF_OUTPUT"
}

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
    echo "[GET] $page_url"
    wget -c "$page_url" -O "$LIST_FILE" -o /dev/null
    grep 'class="nbg"' "$LIST_FILE" | grep -o "http://movie.douban.com/subject/[0-9]*" | sort | uniq > "$TMP"
    while read movie_page_url; do
        index=${movie_page_url##*/}
        json_url="$JSON_BASE_URL/$index"
        json_file="json/${index}.json"
        echo "[GET] $json_file"
        # 后台下载电影信息(json文件）以加快下载速度
        wget -c "$json_url" -O "$json_file" -o /dev/null &
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
        wget "$tag_list_url" -O "$LIST_FILE" -o /dev/null
        tag_list_url=$(grep -o "<[^<]*后页" "$LIST_FILE" | grep -o "http://[^\"]*")
    done
}

test()
{
    #gen_html
    gen_pdf
    exit 0
}

########### Code Start From Here ###########

mkdir -p json images

#test

while read tag; do
    get_movies_by_tag "$tag"
done < tags
rm -fv "$TMP" "$LIST_FILE"

gen_sql
create_db
exec_sql
down_images
gen_html
gen_pdf
exit 0
