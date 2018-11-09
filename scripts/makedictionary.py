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
#
#		Read in all the __mzdefine(*) labels
#
labels = {}
for l in [x.lower() for x in open("kernel.lst").readlines() if x[:10] == "__mzdefine"]:
	m = re.match("^__mzdefine_([0-9a-fnd_]+)\s*\=\s*\$([0-9a-f]+)",l)
	assert m is not None,l+" syntax"
	assert m.group(1) not in labels,l+" duplicate"
	labels[m.group(1)] = int(m.group(2),16)
#
#		Sort them by address
#
keys = [x for x in labels.keys()]
keys.sort(key = lambda x:labels[x])

#
#		For each key (that's not a macro end)
#
for l in keys:
	if l[-4:] != "_end":
		#
		#		Analyse it
		#
		word = "".join([chr(int(x,16)) for x in l.split("_")])
		isProtected = False
		if word[-1] == "p":
			isProtected = True
			word = word[:-1]
		wType = word[-1]
		assert wType == "m" or wType == "w"
		wName = word[:-3]
		#print(wType,wName,labels[l])
		#
		#		Add to the physical dictionary in the image
		#
		image.addDictionary(wName,image.currentCodePage(),labels[l])
		#
		#		Set the type byte for macros to the macro length
		#
		if wType == "m":
			size = labels[l+"_end"]-labels[l]
			assert size <= 6,"Macro size for "+wName+ "??"
			image.xorLastTypeByte(size)
		#
		#		Set protected flag if wanted
		#
		if isProtected:
			image.xorLastTypeByte(0x40)
#
#		Write the image out.
#
image.save()

