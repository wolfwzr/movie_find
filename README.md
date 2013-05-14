movie_find
==========

根据给定标签抓取豆瓣上的电影，然后从中筛选并排序出结果，以html和pdf格式输出。

### 依赖工具
* bash
* python
* sqlite3
* wkhtmltopdf
用来将html转换成pdf
下载地址：http://code.google.com/p/wkhtmltopdf/
安装完成后确保wkhtmltopdf命令能运行

### 使用方法
1. git clone https://github.com/wolfwzr/movie_find.git
2. cd movie_find
3. 编辑tags文件，写入感兴趣的标签，一行一个，如"动画","剧情","李连杰",...
4. ./douban.sh
5. 结果以html和pdf形式保存，分别为douban_movie.html和douban_movie.pdf。

