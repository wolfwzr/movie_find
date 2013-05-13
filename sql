SELECT '<p><table border="0">',

       '<tr><td><P><FONT SIZE="4" COLOR="blue"><B>',title AS '片名','</B></FONT></P></td></tr>',

       '<tr><td><P><FONT SIZE="2" COLOR="DarkGreen"><B> 别名：</B></FONT>',
       '<FONT SIZE="2" COLOR="blue">', alt_title AS '别名', '</FONT></P></td></tr>',

       '<tr><td><P><FONT SIZE="2" COLOR="DarkGreen"><B> 评分：</B></FONT>',
       '<FONT SIZE="2" COLOR="black">',average AS '评分', '</FONT></P></td></tr>',

       '<tr><td><P><FONT SIZE="2" COLOR="DarkGreen"><B> 人数：</B></FONT>',
       '<FONT SIZE="2" COLOR="black">',numRaters AS '评分人数', '</FONT></P></td></tr>',

       '<tr><td><P><FONT SIZE="2" COLOR="DarkGreen"><B> 年份：</B></FONT>',
       '<FONT SIZE="2" COLOR="black">',year AS '年份', '</FONT></P></td></tr>',

       '<tr><td><P><FONT SIZE="2" COLOR="DarkGreen"><B> 国家：</B></FONT>',
       '<FONT SIZE="2" COLOR="black">',country AS '国家','</FONT></P></td></tr>',

       '<tr><td><P><FONT SIZE="2" COLOR="DarkGreen"><B> 类型：</B></FONT>',
       '<FONT SIZE="2" COLOR="black">',type AS '类型','</FONT></P></td></tr>',

       '<tr><td><P><FONT SIZE="2" COLOR="DarkGreen"><B> 内容概要：</B></FONT></P></td></tr>',
       '<tr><td><P><FONT SIZE="2" COLOR="MidnightBlue">',summary AS '内容概要','</FONT></P></td></tr>',

       '</table></p>'
FROM movie
WHERE
    average>=8.0
    AND numRaters>=50000
ORDER BY
    numRaters DESC,
    average DESC;
