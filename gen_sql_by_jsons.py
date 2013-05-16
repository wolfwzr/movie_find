#! /usr/bin/python

import json
import sys

if len(sys.argv) < 2:
	sys.exit()

path=sys.argv[1]
m_id=sys.argv[2]

f=file(path)
s=json.load(f)

numRaters=s["rating"]["numRaters"]
average=float(s["rating"]["average"])
title=s["title"].encode("utf-8").replace("'","''")
alt_title=s["alt_title"].encode("utf-8").replace("'","''")
summary=s["summary"].encode("utf-8").replace("'","''")
image=s["image"].encode("utf-8").replace("'","''")

val=""
if s.has_key("attrs") and s["attrs"].has_key("year"):
	size=len(s["attrs"]["year"])
	for i in range(0, size):
		val=val + s["attrs"]["year"][i] + " "
year=val.encode("utf-8").replace("'","''")

val=""
if s.has_key("attrs") and s["attrs"].has_key("country"):
	size=len(s["attrs"]["country"])
	for i in range(0, size):
		val=val + s["attrs"]["country"][i] + " "
country=val.encode("utf-8").replace("'","''")

val=""
if s.has_key("attrs") and s["attrs"].has_key("language"):
	size=len(s["attrs"]["language"])
	for i in range(0, size):
		val=val + s["attrs"]["language"][i] + " "
language=val.encode("utf-8").replace("'","''")

val=""
if s.has_key("attrs") and s["attrs"].has_key("director"):
	size=len(s["attrs"]["director"])
	for i in range(0, size):
		val=val + s["attrs"]["director"][i] + " "
director=val.encode("utf-8").replace("'","''")

val=""
if s.has_key("attrs") and s["attrs"].has_key("cast"):
	size=len(s["attrs"]["cast"])
	for i in range(0, size):
		val=val + s["attrs"]["cast"][i] + " "
cast=val.encode("utf-8").replace("'","''")

val=""
if s.has_key("attrs") and s["attrs"].has_key("movie_type"):
	size=len(s["attrs"]["movie_type"])
	for i in range(0, size):
		val=val + s["attrs"]["movie_type"][i] + " "
m_type=val.encode("utf-8").replace("'","''")

print "INSERT INTO movie VALUES (" +\
	str(m_id) 	+ ","   +\
	str(average)	+ ","   +\
	str(numRaters)	+ ",'"  +\
	title 		+ "','" +\
	alt_title 	+ "','" +\
	image 		+ "','" +\
	country 	+ "','" +\
	year 		+ "','" +\
	language 	+ "','" +\
	director 	+ "','" +\
	cast 		+ "','" +\
	m_type 		+ "','" +\
	summary 	+ "');"

