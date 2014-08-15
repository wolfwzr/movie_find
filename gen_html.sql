SELECT '<a name="content"></a>',
       '<font align=center class=title>目&nbsp;&nbsp;&nbsp;&nbsp;录</font>';
SELECT '<ol>';
SELECT '<li align="left"><FONT SIZE="2">',
       '<a class=n href="#',id,'">',title,'&nbsp;/&nbsp;',alt_title,'&nbsp;(',average,'/',numRaters,')</a>',
       '</FONT></li>'
FROM movie
WHERE
    average>=8.0
    AND numRaters>=10000
ORDER BY
    average DESC,
    numRaters DESC;
SELECT '</ol><br><br><br><br>';

SELECT '<p><table border="0"><a name="',id,'"></a>',
       '<tr><td colspan=2 align=left>',
            '<a class=n href="http://movie.douban.com/subject/',id,'/"><h3>',
            '<FONT class=title>',title,'</font></h3></a></td></tr>',
       '<tr><td ROWSPAN=9 VALIGN=top width=80><br/>',
            '<img src="images/',id,'.jpg"></td>',
       '<tr><td><font class=field_head> 别名：</font>',
            '<font class=field_body>',alt_title,'</font></td></tr>',
       '<tr><td><font class=field_head> 评分：</font>',
            '<font class=field_body>',average,'</font></td></tr>',
       '<tr><td><font class=field_head> 人数：</font>',
            '<font class=field_body>',numraters,'</font></td></tr>',
       '<tr><td><font class=field_head> 导演：</font>',
            '<font class=field_body>',director,'</font></td></tr>',
       '<tr><td><font class=field_head> 主演：</font>',
            '<font class=field_body>',"cast",'</font></td></tr>',
       '<tr><td><font class=field_head> 年份：</font>',
            '<font class=field_body>',year,'</font></td></tr>',
       '<tr><td><font class=field_head> 国家：</font>',
            '<font class=field_body>',country,'</font></td></tr>',
       '<tr><td><font class=field_head> 类型：</font>',
            '<font class=field_body>',"type",'</font></td></tr>',
       '<tr><td colspan=2><font class=field_head> 内容概要：</font></td></tr>',
       '<tr><td colspan=2><font class=field_summary>',summary,'</font></td></tr>',
       '<tr><td><a class=n href="#content">',
            '<font class=field_back_to_content>[回到目录]</font></a></td></tr>',
       '</table></p>'
FROM movie
WHERE
    average>=8.0
    AND numRaters>=10000
ORDER BY
    average DESC,
    numRaters DESC;
