# ***************************************************************************************
# ***************************************************************************************
#
#		Name : 		makedictionary.py
#		Author :	Paul Robson (paul@robsons.org.uk)
#		Date : 		8th November 2018
#		Purpose :	Create initial dictionary from kernel.lst
#
# ***************************************************************************************
# ***************************************************************************************

import re
from imagelib import *

image = MZImage()

src = [x.lower() for x in open("kernel.lst").readlines() if x[:10] == "__mzdefine"]
src.sort()
for l in src:
	m = re.match("^__mzdefine_([0-9a-f_]+)\s*\=\s*\$([0-9a-f]+)",l)
	assert m is not None
	word = "".join([chr(int(x,16)) for x in m.group(1).split("_")])
	address = int(m.group(2),16)
	image.addDictionary(word,image.currentCodePage(),address)
image.save()

