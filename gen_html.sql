SELECT '<style>.n{TEXT-DECORATION:none} </style>';
SELECT '<a name="content"></a><h3 align="center"> 目  录</h2>';
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
       '<tr><td><a class=n href="http://movie.douban.com/subject/',id,'/"><h3><FONT SIZE="4" COLOR="blue"><B>',title,'</B></FONT></h3></a></td></tr>',
       '<tr><td><img src="images/',id,'.jpg"></td></tr>',
       '<tr><td><P><FONT SIZE="2" COLOR="DarkGreen"><B> 别名：</B></FONT>',
       '<FONT SIZE="2" COLOR="blue">', alt_title,'</FONT></P></td></tr>',
       '<tr><td><P><FONT SIZE="2" COLOR="DarkGreen"><B> 评分：</B></FONT>',
       '<FONT SIZE="2" COLOR="black">',average,'</FONT></P></td></tr>',
       '<tr><td><P><FONT SIZE="2" COLOR="DarkGreen"><B> 人数：</B></FONT>',
       '<FONT SIZE="2" COLOR="black">',numRaters,'</FONT></P></td></tr>',
       '<tr><td><P><FONT SIZE="2" COLOR="DarkGreen"><B> 导演：</B></FONT>',
       '<FONT SIZE="2" COLOR="black">',director,'</FONT></P></td></tr>',
       '<tr><td><P><FONT SIZE="2" COLOR="DarkGreen"><B> 主演：</B></FONT>',
       '<FONT SIZE="2" COLOR="black">',"cast",'</FONT></P></td></tr>',
       '<tr><td><P><FONT SIZE="2" COLOR="DarkGreen"><B> 年份：</B></FONT>',
       '<FONT SIZE="2" COLOR="black">',year,'</FONT></P></td></tr>',
       '<tr><td><P><FONT SIZE="2" COLOR="DarkGreen"><B> 国家：</B></FONT>',
       '<FONT SIZE="2" COLOR="black">',country,'</FONT></P></td></tr>',
       '<tr><td><P><FONT SIZE="2" COLOR="DarkGreen"><B> 类型：</B></FONT>',
       '<FONT SIZE="2" COLOR="black">',"type",'</FONT></P></td></tr>',
       '<tr><td><P><FONT SIZE="2" COLOR="DarkGreen"><B> 内容概要：</B></FONT></P></td></tr>',
       '<tr><td><P><FONT SIZE="2" COLOR="MidnightBlue">',summary,'</FONT></P></td></tr>',
       '<tr><td><a class=n href="#content"><FONT SIZE="1" COLOR="DarkGreen">[目录]</FONT></a></td></tr>',
       '</table></p>'
FROM movie
WHERE
    average>=8.0
    AND numRaters>=10000
ORDER BY
    average DESC,
    numRaters DESC;
