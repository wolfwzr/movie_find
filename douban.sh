#! /bin/bash

LIST_BASE_URL="http://movie.douban.com/tag/"
JSON_BASE_URL="https://api.douban.com/v2/movie/"

DB_FILE=movie.db
SQL_TXT=insert.sql

 PDF_OUTPUT="index.pdf"
HTML_OUTPUT="index.html"
HTML_PREFIX="html_prefix"
HTML_SUFFIX="html_suffix"
HTML2PDF="./wkhtmltopdf-i386"

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
    country TEXT,
    year TEXT,
    language TEXT,
    director TEXT,
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

    cat /etc/null > "$SQL_TXT"
    for json in json/*; do 
        id=${json##*/}
        id=${id%%\.json}
        echo "[PRASE] $json"
        python gen_sql_by_jsons.py "$json" "$id" >> "$SQL_TXT"
    done 
}

gen_html()
{
    cat "$HTML_PREFIX" > "$HTML_OUTPUT"
    sqlite3 -html -header "$DB_FILE"           "\
        SELECT                                  \
            title       AS '片名',              \
            alt_title   AS '别名',              \
            numRaters   AS '评分人数',          \
            average     AS '评分',              \
            country     AS '国家',              \
            year        AS '年份',              \
            type        AS '类型',              \
            summary     AS '内容概要'           \
        FROM movie                              \
        WHERE                                   \
            average>=8.0                        \
            AND numRaters>=10000                \
        ORDER BY                                \
            numRaters DESC,                     \
            average DESC;                       \
        " >> "$HTML_OUTPUT"
    cat "$HTML_SUFFIX" >> "$HTML_OUTPUT"
}

gen_html_v2()
{
    cat > "$HTML_OUTPUT" << EOF
<html> 
    <head><meta http-equiv="content-type" content="text/html;charset=utf-8"></head>
    <body>
EOF
    sqlite3 -separator "" "$DB_FILE" ".read sql" >> "$HTML_OUTPUT"
    cat >> "$HTML_OUTPUT" << EOF
    </body> 
</html>
EOF
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
    echo "[WGET] $page_url"
    wget -c "$page_url" -O "$LIST_FILE" -o /dev/null
    grep 'class="nbg"' "$LIST_FILE" | grep -o "http://movie.douban.com/subject/[0-9]*" | sort | uniq > "$TMP"
    while read movie_page_url; do
        index=${movie_page_url##*/}
        json_url="$JSON_BASE_URL/$index"
        json_file="json/${index}.json"
        echo "[WGET] $json_file"
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

########### Code Start From Here ###########


gen_html_v2
exit 0

mkdir -p json
while read tag; do
    get_movies_by_tag "$tag"
done < tags
rm -fv "$TMP" "$LIST_FILE"

gen_sql
create_db
exec_sql
gen_html
gen_pdf
exit 0