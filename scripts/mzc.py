# ***************************************************************************************
# ***************************************************************************************
#
#		Name : 		mzc.py
#		Author :	Paul Robson (paul@robsons.org.uk)
#		Date : 		9th November 2018
#		Purpose :	MZ Compiler
#
# ***************************************************************************************
# ***************************************************************************************

from imagelib import *
import re,sys

# ***************************************************************************************
#
#										Error Class
#
# ***************************************************************************************

class CompilerException(Exception):
	def __init__(self,errorMsg):
		Exception.__init__(self)
		self.message = errorMsg

# ***************************************************************************************
#
#							Dictionary Entry Base Class
#
# ***************************************************************************************

class DictionaryEntry(object):
	def __init__(self,name,page,address):
		self.name = name
		self.page = page
		self.address = address 
		self.private = False
		self.protected = False
		self.inDictionary = False
	def getName(self):
		return self.name 
	def getAddress(self):
		return self.address
	def getPage(self):
		return self.page
	def setInDictionaryFlag(self):
		self.inDictionary = True
	def makePrivate(self):
		self.private = True
	def makeProtected(self):
		self.protected = True
	def getTypeByte(self):
		flags = 0x80 if self.private else 0x00 
		flags = flags + (0x40 if self.protected else 0x00)
		return flags
	def canTransferToImage(self):
		return (not self.private) and (not self.inDictionary)

# ***************************************************************************************
#
#							  Dictionary Entry classes
#
# ***************************************************************************************

#
#		Normal word
#
class DictionaryStandardWord(DictionaryEntry):
	def getTypeByte(self):
		return DictionaryEntry.getTypeByte(self)+0
	def generateCode(self,compiler):
		compiler.generateCallCode(self.getPage(),self.getAddress())

#
#		Immediate word (which we can't use)
#
class DictionaryImmediateWord(DictionaryEntry):
	def getTypeByte(self):
		return DictionaryEntry.getTypeByte(self)+15
	def generateCode(self,compiler):
		raise CompilerException("Cannot process immediate words in Python compiler")
#
#		Variable
#
class DictionaryVariableWord(DictionaryEntry):
	def __init__(self,name,page,address):
		DictionaryEntry.__init__(self,name,page,address)
		self.makePrivate()
	def getTypeByte(self):
		return 14
	def generateCode(self,compiler):
		compiler.generateConstantCode(self.getAddress())

#
#		Code copying macro
#
class DictionaryMacroWord(DictionaryEntry):
	def __init__(self,name,page,address,size):
		DictionaryEntry.__init__(self,name,page,address)
		self.size = size
	def getSize(self):
		return self.size
	def getTypeByte(self):
		return DictionaryEntry.getTypeByte(self)+self.size
	def generateCode(self,compiler):
		compiler.generateMacroCode(self.getSize(),self.getAddress())

# ***************************************************************************************
#
#										Dictionary Class
#
# ***************************************************************************************

class Dictionary(object):
	def __init__(self,image):
		self.image = image
		self.elements = {}
		self.lastElement = None
		self.loadImageDictionary()
	#
	#		Load the dictionary from the image into a Python structure
	#
	def loadImageDictionary(self):
		dp = self.image.dictionaryPage()
		p = 0xC000
		while self.image.read(dp,p) != 0:
			#
			#		Basic information
			#
			page = self.image.read(dp,p+1)
			address = self.image.read(dp,p+2) + self.image.read(dp,p+3) * 256
			typeByte = self.image.read(dp,p+4)
			#
			#		Get Name
			#
			p1 = p + 5
			name = ""
			while p1 is not None:
				name += chr(self.image.read(dp,p1) & 0x7F)
				p1 = (p1 + 1) if (self.image.read(dp,p1) & 0x80) == 0 else None
			#
			#		Create equivalent DictionaryEntry type
			#
			if (typeByte & 0x0F) == 0:
				self.elements[name] = DictionaryStandardWord(name,page,address)
			elif (typeByte & 0x0F) == 15:
				self.elements[name] = DictionaryImmediateWord(name,page,address)
			else:
				size = typeByte & 0x0F
				assert size >= 1 and size < 10
				self.elements[name] = DictionaryMacroWord(name,page,address,size)
			#
			#		Mark as already being in the dictionary in image
			#
			self.elements[name].setInDictionaryFlag()
			#
			#		Go to next
			#
			p = p + self.image.read(dp,p)
	#
	#		See if word in dictionary
	#
	def find(self,word):
		word = word.lower()
		return self.elements[word] if word in self.elements else None
	#
	#		Add a new element to the Python dictionary.
	#
	def addDictionary(self,entry):
		if entry.getName() in self.elements:
			raise CompilerException("Duplicate word name '{0}'".format(entry.getName()))
		self.elements[entry.getName()] = entry 
		self.lastElement = entry
	#
	#		Get last entry
	#
	def getLastEntry(self):
		if self.lastElement is None:
			raise CompilerException("No definition to modify")
		return self.lastElement
	#
	#		Synchronise the dictionary in the image memory with the Python version
	#
	def updateImageDictionary(self,image):
		for w in self.elements.keys():
			if self.elements[w].canTransferToImage():
				self.elements[w].setInDictionaryFlag()
				self.image.addDictionary(w,self.elements[w].getPage(),self.elements[w].getAddress())
				self.image.xorLastTypeByte(self.elements[w].getTypeByte())

# ***************************************************************************************
#		
#									Compiler class
#
# ***************************************************************************************

class Compiler(object):
	def __init__(self,sourceFile = "boot.img",objectFile = "boot.img"):
		self.objectFileName = objectFile
		self.image = MZImage(sourceFile)
		si = self.image.getSysInfo()
		self.sourcePage = self.image.currentCodePage()
		self.sourceAddress = self.image.read(0,si+0) + self.image.read(0,si+1) * 256
		self.dictionary = Dictionary(self.image)
		self.echo = False
		self.ifTarget = None
		self.beginTarget = None
		self.forTarget = None
		#print("{0:x} {1:x}".format(self.sourcePage,self.sourceAddress))
	#
	#		Save back out. Update source position
	#
	def save(self):
		si = self.image.getSysInfo()
		#
		#		Update code point
		#
		self.image.write(0,si+0,self.sourceAddress & 0xFF)
		self.image.write(0,si+1,self.sourceAddress >> 8)
		self.image.write(0,si+4,self.sourcePage)
		#
		#		Update dictionary and write out.
		#
		self.dictionary.updateImageDictionary(self.image)
		self.image.save(self.objectFileName)
	#
	#		Compile a byte of code
	#
	def cByte(self,byte):
		if self.echo:
			print("{0:02x}:{1:04x} {2:02x}".format(self.sourcePage,self.sourceAddress,byte))
		self.image.write(self.sourcePage,self.sourceAddress,byte)
		self.sourceAddress += 1
	#
	#		Compile a word of code
	#
	def cWord(self,word):
		if self.echo:
			print("{0:02x}:{1:04x} {2:04x}".format(self.sourcePage,self.sourceAddress,word))
		self.image.write(self.sourcePage,self.sourceAddress,word & 0xFF)
		self.image.write(self.sourcePage,self.sourceAddress+1,word >> 8)
		self.sourceAddress += 2
	#
	#		Compile a single line of code
	#
	def compileLine(self,line):
		line = line if line.find("//") < 0 else line[:line.find("//")]
		self.lineSource = [x for x in line.split(" ") if x != ""]
		self.lineSourceIndex = 0
		word = self.get()
		while word is not None:
			self.compileWord(word)
			word = self.get()
	#
	#		Get next word in line
	#
	def get(self):
		if self.lineSourceIndex >= len(self.lineSource):
			return None
		word = self.lineSource[self.lineSourceIndex]
		self.lineSourceIndex += 1
		return word
	#
	#		Compile a word
	#
	def compileWord(self,word):
		if self.echo:
			print("***** {0} *****".format(word))
		#
		# 								defining word
		#
		if word == ":":
			word = self.get()
			if word is None:
				raise CompilerException("Missing word name for :")
			newEntry = DictionaryStandardWord(word,self.sourcePage,self.sourceAddress)
			self.dictionary.addDictionary(newEntry)
			if word == "main":
				self.image.setRunAddress(self.sourcePage,self.sourceAddress)
			return			
		#
		# 								dictionary words
		#
		element = self.dictionary.find(word.lower())
		if element is not None:
			element.generateCode(self)
			return
		#
		# 								numeric constants
		#
		if re.match("^\-?[0-9]+$",word):
			self.generateConstantCode(int(word,10) & 0xFFFF)
			return
		#
		# 								string constants
		#
		if word[0] == '"':
			addr = self.generateString(word[1:].replace("_"," "))
			self.generateConstantCode(addr)
			return
		#
		# 									variable
		#
		if word == 'variable':
			word = self.get()
			if word is None:
				raise CompilerException("Missing word name for variable")
			newEntry = DictionaryVariableWord(word,self.sourcePage,self.sourceAddress)
			self.dictionary.addDictionary(newEntry)
			self.cWord(0)
			return
		#
		# 									!! x @@ x && x
		#
		if word == "!!" or word == "@@" or word == "&&":
			vword = self.get()
			if vword is None:
				raise CompilerException("Missing word name for variable modifier")
			entry = self.dictionary.find(vword.lower())
			if entry is None:
				raise CompilerException("Unknown variable for variable modifier")
			if not isinstance(entry,DictionaryVariableWord):
				raise CompilerException("Identifier "+vword+" is not a variable")
			if word == "&&":
				self.generateConstantCode(entry.getAddress())
			if word == "!!":
				self.cByte(0x22)											# LD (xxxx),HL
				self.cWord(entry.getAddress())
			if word == "@@":
				self.cByte(0xEB) 											# EX DE,HL
				self.cByte(0x2A)											# LD HL,(xxxx)
				self.cWord(entry.getAddress())
			return
		#
		# 							begin .. -until/until/again
		#

		#
		# 							if .. then
		#
		if word == "-if" or word == "if":
			self.ifTarget = self.createConditionalBranch(">=0" if word == "-if" else "=0")
			return
		if word == "then":
			self.patchBranch(self.ifTarget,self.sourceAddress,"if")
			return
		#
		# 							for .. i .. next
		#
		if word == "begin":
			self.beginTarget = self.sourceAddress
			return

		if word == "again" or word == "until" or word == "-until":
			if word == "again":
				targetAddress = self.createConditionalBranch("always")
			else:
				targetAddress = self.createConditionalBranch(">=0" if word == "-until" else "=0")
			self.patchBranch(targetAddress,self.beginTarget,"begin")
			return
		#
		# 				 private, protected and other control words
		#
		if word == "private":
			self.dictionary.getLastEntry().makePrivate()
			return
		if word == "protected":
			self.dictionary.getLastEntry().makeProtected()
			return

		print(word)
		raise CompilerException("Unknown word "+word)
	#
	#		Generate code to call page:address from here.
	#
	def generateCallCode(self,page,address):
		assert self.sourcePage == page,"Paging calls not implemented"
		self.cByte(0xCD)													# CALL xxxx
		self.cWord(address)
	#
	#		Generate code to do A->B ; A := <constant>
	#
	def generateConstantCode(self,const):
		self.cByte(0xEB) 													# EX DE,HL
		self.cByte(0x21) 													# LD HL,xxxx
		self.cWord(const)
	#
	#		Generate a conditional branch
	#
	def createConditionalBranch(self,branchType):
		if branchType == "=0":
			self.cByte(0x7C) 												# LD A,H
			self.cByte(0xB5)												# OR L
			self.cByte(0xCA)												# JP Z,xxxx
		elif branchType == ">=0":
			self.cByte(0xCB)												# BIT 7,H
			self.cByte(0x7C)
			self.cByte(0xCA)												# JP Z,xxxx
		elif branchType == "always":
			self.cByte(0xC3)												# JP xxxx
		patchAddress = self.sourceAddress
		self.cWord(0)														# dummy target address
		return patchAddress
	#
	#		Close a conditional branch
	#
	def patchBranch(self,patchAddress,targetAddress,errorInfo):
		if targetAddress is None:
			raise CompilerException("Missing {0} in structure".format(errorInfo))
		self.image.write(self.sourcePage,patchAddress,targetAddress & 0xFF)
		self.image.write(self.sourcePage,patchAddress+1,targetAddress >> 8)
	#
	#		Generate an inline string and return its logical address
	#
	def generateString(self,str):
		self.cByte(0x18)													# JR xx
		self.cByte(len(str)+1)
		addr = self.sourceAddress
		for c in str:
			self.cByte(ord(c))
		self.cByte(0x00)
		return addr
	#
	#		Generate code from a macro / code copier word
	#
	def generateMacroCode(self,size,address):
		for i in range(0,size):
			self.cByte(self.image.read(self.sourcePage,address))
			address += 1


c = Compiler()
src = """
: main2

begin 0 until
begin 1 -until
begin 2 again

debug halt
 """.replace("\n"," ")
print(src)
c.compileLine(src)
c.save()	

#
# TODO: for/i/next
# TODO: Wrapper
#
