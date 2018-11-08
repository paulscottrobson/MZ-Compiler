# ***************************************************************************************
# ***************************************************************************************
#
#		Name : 		imagelib.py
#		Author :	Paul Robson (paul@robsons.org.uk)
#		Date : 		8th November 2018
#		Purpose :	MZ Binary Image Library
#
# ***************************************************************************************
# ***************************************************************************************

class MZImage(object):
	def __init__(self,fileName = "boot.img"):
		self.fileName = fileName
		h = open(fileName,"rb")
		self.image = [x for x in h.read(-1)]
		self.sysInfo = self.read(0,0x8004)+self.read(0,0x8005)*256
		h.close()

	def dictionaryPage(self):
		return 0x20

	def currentCodePage(self):
		return self.read(0,self.sysInfo+4)

	def address(self,page,address):
		assert address >= 0x8000 and address <= 0xFFFF
		if address < 0xC000:
			return address & 0x3FFF
		else:
			return (page - 0x20) * 0x2000 + 0x4000 + (address & 0x3FFF)

	def read(self,page,address):
		self.expandImage(page,address)
		return self.image[self.address(page,address)]

	def write(self,page,address,data):
		self.expandImage(page,address)
		assert data >= 0 and data < 256
		self.image[self.address(page,address)] = data

	def expandImage(self,page,address):
		required = self.address(page,address)
		while len(self.image) <= required:
			self.image.append(0x00)

	def addDictionary(self,name,page,address):
		p = self.findEndDictionary()
		#print("{0:04x} {1:20} {2:02x}:{3:04x}".format(p,name,page,address))
		assert len(name) < 32 and name != "","Bad name '"+name+"'"
		dp = self.dictionaryPage()
		self.write(dp,p+0,len(name)+5)
		self.write(dp,p+1,page)
		self.write(dp,p+2,address & 0xFF)
		self.write(dp,p+3,address >> 8)
		self.write(dp,p+4,len(name) & 0x1F)
		for i in range(0,len(name)):
			self.write(dp,p+5+i,ord(name[i]))
		p = p + len(name) + 5
		self.write(dp,p,0)

	def findEndDictionary(self):
		p = 0xC000
		while self.read(self.dictionaryPage(),p) != 0:
			p = p + self.read(self.dictionaryPage(),p)
		return p

	def save(self,fileName = None):
		fileName = self.fileName if fileName is None else fileName
		h = open(fileName,"wb")
		h.write(bytes(self.image))		
		h.close()

if __name__ == "__main__":
	z = MZImage()
	print(len(z.image))
	print(z.address(z.dictionaryPage(),0xC000))
	z.save()


