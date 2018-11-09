# ***************************************************************************************
# ***************************************************************************************
#
#		Name : 		buildwords.py
#		Author :	Paul Robson (paul@robsons.org.uk)
#		Date : 		7th November 2018
#		Purpose :	Build __words.asm for kernel.
#
# ***************************************************************************************
# ***************************************************************************************

import os,re
fileList = []
for root,dirs,files in os.walk("core"):
	for f in files:
		if f[-5:] == ".word":
			fileList.append(root+os.sep+f)
fileList.sort()
#
#			Create file list.
#
h = open("__words.asm","w")
for f in fileList:
	src = [x.rstrip().replace("\t"," ") for x in open(f).readlines()]
	src = [x for x in src if x.strip() != ""]
	m = re.match("^\;\s*\@(\w+)\s+(.*)$",src[0])
	assert m is not None,"Failing for "+f+" first line is "+src[0]	
	wName = m.group(2).lower().strip()
	wType = m.group(1).lower().strip()
	isProtected = False
	if wName[-9:] == "protected":
		wName = wName[:-9].strip()
		isProtected = True
	assert wType == "word" or wType == "macro","Bad type for "+f

	h.write("; ---------------------------------------------------------\n")
	h.write("; Name : {0} Type : {1}\n".format(m.group(2).lower().strip(),wType))
	h.write("; ---------------------------------------------------------\n\n")

	wName = wName + "::"+wType[0]+("p" if isProtected else "")
	scrambleName = "__mzdefine_"+"_".join("{0:02x}".format(ord(c)) for c in wName)

	if wType == "word":
		h.write("{0}:\n".format(scrambleName))
		for s in src[1:]:
			h.write(s+"\n")

	if wType == "macro":			
		h.write("{0}:\n".format(scrambleName))
		for s in src[1:]:
			h.write(s+"\n")
		if wName != ";::mp":
			assert src[-1].strip() != "ret","Macro "+wName+" ends in ret"
		h.write("{0}_end:\n".format(scrambleName))
		h.write("  ret\n")
			
	#print(wName,scrambleName,wType)
	h.write("\n")
h.close()
print("Built file with {0} words".format(len(fileList)))