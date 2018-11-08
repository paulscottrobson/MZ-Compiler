#
#		Test the boot read/write works
# 
rm bootloader.sna boot.img
#
#		Create a dummy boot.img file
#
python3 makedemoimage.py
#
#		Assemble with testing on
#
zasm -buw bootloader.asm -l bootloader.lst -o bootloader.sna
#
#		Run it
#
if [ -e bootloader.sna ] 
then
	wine ../bin/CSpect.exe -zxnext -cur -brk -exit -w3 bootloader.sna 2>/dev/null
#	sh ../bin/zrun.sh ./ bootloader.sna
fi
