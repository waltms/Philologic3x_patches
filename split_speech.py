#!/usr/bin/python
# -*- coding: utf-8 -*-

# version 0.1.1

import sys, os, getopt
import re

argv = sys.argv[1:]

idir = ""
odir = ""
split_tag = ""
header_yes = True
footer_yes = True

try:
	opts, args = getopt.getopt(argv,"i:t:o:",["idir=", "tag=", "odir="])
except getopt.GetoptError:
	print 'Usage: split_speech.py -i <idirectory> -t <tag> -o <odirectory>'
	print 'For e.g.: ./split_speech.py -i /Users/Shared/miningtexts/SpeechNarrative/Oratorstosplit -t div1 -o /tmp/testxml'
	sys.exit(2)

for opt, arg in opts:
	if opt in ("-i"):
		idir = arg
		if not idir.startswith("/"):
			print "Please give me the full path..."
			sys.exit()
	elif opt in ("-t"):
		split_tag = arg
	elif opt in ("-o"):
		odir = arg
		if not odir.startswith("/"):
			print "Please give me the full path..."
			sys.exit()

# try to cd to the output directory,
# if doesn't exist then mkdir

try:
	os.chdir(odir)
except OSError:
	try:
		os.mkdir(odir)
	except OSError:
		print "OS Error: permissions? maybe?"

for subdir, dirs, files in os.walk(idir):
	for file in files:
        	filepath = subdir + os.sep + file
		if filepath.endswith(".xml"): 
			print(filepath)

			fi = open(filepath, "r")
			content = fi.read()
			fi.close()

			text_m = re.compile(r"(^.*?)(<body.*)(</body.*)", re.S) 
			text = text_m.match(content)

			header = text.group(1)
			body = text.group(2)
			footer = text.group(3)

			r_string = r"<" + split_tag + r".*?</" + split_tag + ".*?>"
#			div1_m = re.compile(r"<div1.*?</div1.*?>", re.S) 
			div1_m = re.compile(r_string, re.S) 
			div1s = div1_m.findall(body)

			i = 1
			print "Speeches: " + str(len(div1s))
			for div1 in div1s:
				new_content = '\n'.join([header, div1, footer])	
#				new_name = odir + "/" + re.match("(^.*)\.xml", file).group(1) + "-" + split_tag + "-" + str(i) + ".xml"
				new_name = odir + "/" + re.match("(^.*)\.xml", file).group(1) + "-" + str(i).zfill(3) + ".xml"
				print "->" + new_name
				
				of = open(new_name, "w")
				of.write(new_content)
				of.close()

				i += 1
