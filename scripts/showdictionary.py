# ***************************************************************************************
# ***************************************************************************************
#
#		Name : 		showdictionary.py
#		Author :	Paul Robson (paul@robsons.org.uk)
#		Date : 		8th November 2018
#		Purpose :	List Dictionary contents
#
# ***************************************************************************************
# ***************************************************************************************

import re
from imagelib import *


image = MZImage()
p = 0xC000
dictPage = image.dictionaryPage()

while image.read(dictPage,p) != 0:

	page = image.read(dictPage,p+1)
	addr = image.read(dictPage,p+2) + 256 * image.read(dictPage,p+3)
	name = ""
	p1 = p + 5
	decoding = True
	while decoding:
		name = name + chr(image.read(dictPage,p1) & 0x7F)
		decoding = (image.read(dictPage,p1) & 0x80) == 0
		p1 += 1
	dByte = image.read(dictPage,p + 4)
	if (dByte & 0x0F) == 0:
		descr = "word"
	elif (dByte & 0x0F) == 15:
		descr = "immediate"
	elif (dByte & 0x0F) == 14:
		descr = "variable"
	else:
		descr = "macro ({0} byte(s))".format(dByte & 0x0F)
	assert (dByte & 0x80) == 0,"Private word {0} in dictionary".format(name)
	if (dByte & 0x40) != 0:
		descr += " (protected)"
	print("[{0:04x}] {1:02x}:{2:04x} {3} {4}".format(p,page,addr,name,descr))
	p = p + image.read(dictPage,p)