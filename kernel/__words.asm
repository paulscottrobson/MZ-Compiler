; ---------------------------------------------------------
; Name : + Type : macro
; ---------------------------------------------------------

__mzdefine_2b:
  nop
  ld a,end___mzdefine_2b-__mzdefine_2b-3
  add  hl,de
end___mzdefine_2b:
  ret

; ---------------------------------------------------------
; Name : and Type : word
; ---------------------------------------------------------

__mzdefine_61_6e_64:
  ld   a,h
  and  d
  ld   h,a
  ld   a,l
  and  e
  ld   l,a
  ret

; ---------------------------------------------------------
; Name : / Type : word
; ---------------------------------------------------------

__mzdefine_2f:
  push  de
  call  DIVDivideMod16
  ex   de,hl
  pop  de
  ret

; ---------------------------------------------------------
; Name : = Type : word
; ---------------------------------------------------------

__mzdefine_3d:
 ld   a,h
 cp   d
 jr   nz,__COMFalse
 ld   a,l
 cp   e
 jr   nz,__COMFalse
__COMTrue:
 ld   hl,$FFFF
 ret
__COMFalse:
 ld   hl,$0000
 ret

; ---------------------------------------------------------
; Name : > Type : word
; ---------------------------------------------------------

__mzdefine_3e:
__COMP_GT:
 ld   a,h
    xor  d
    jp   m,__Greater
    sbc  hl,de
    jp   c,__COMTrue
    jp   __COMFalse
__Greater:
 bit  7,d
    jp   nz,__COMFalse
    jp     __COMTrue

; ---------------------------------------------------------
; Name : >= Type : word
; ---------------------------------------------------------

__mzdefine_3e_3d:
 dec  hl
 jp   __COMP_GT

; ---------------------------------------------------------
; Name : < Type : word
; ---------------------------------------------------------

__mzdefine_3c:
 dec  hl
 jp   __COMP_LE

; ---------------------------------------------------------
; Name : <= Type : word
; ---------------------------------------------------------

__mzdefine_3c_3d:
__COMP_LE:
 ld   a,h
    xor  d
    jp   m,__LessEqual
    sbc  hl,de
    jp   nc,__COMTrue
    jp   __COMFalse
__LessEqual:
 bit  7,d
    jp   z,__COMFalse
    jp   __COMTrue

; ---------------------------------------------------------
; Name : mod Type : word
; ---------------------------------------------------------

__mzdefine_6d_6f_64:
  push  de
  call  DIVDivideMod16
  pop  de
  ret

; ---------------------------------------------------------
; Name : * Type : word
; ---------------------------------------------------------

__mzdefine_2a:
  jp   MULTMultiply16

; ---------------------------------------------------------
; Name : <> Type : word
; ---------------------------------------------------------

__mzdefine_3c_3e:
 ld   a,h
 cp   d
 jp   nz,__COMTrue
 ld   a,l
 cp   e
 jp   nz,__COMTrue
 jp   __COMFalse

; ---------------------------------------------------------
; Name : or Type : word
; ---------------------------------------------------------

__mzdefine_6f_72:
  ld   a,h
  or   d
  ld   h,a
  ld   a,l
  or   e
  ld   l,a
  ret

; ---------------------------------------------------------
; Name : - Type : macro
; ---------------------------------------------------------

__mzdefine_2d:
  nop
  ld a,end___mzdefine_2d-__mzdefine_2d-3
  push  de
  ex   de,hl
  xor  a
  sbc  hl,de
  pop  de
end___mzdefine_2d:
  ret

; ---------------------------------------------------------
; Name : xor Type : word
; ---------------------------------------------------------

__mzdefine_78_6f_72:
  ld   a,h
  xor   d
  ld   h,a
  ld   a,l
  xor  e
  ld   l,a
  ret

; ---------------------------------------------------------
; Name : +! Type : word
; ---------------------------------------------------------

__mzdefine_2b_21:
  ld   a,(hl)
  add  a,e
  ld   (hl),a
  inc  hl
  ld   a,(hl)
  adc  a,d
  ld   (hl),a
  dec  hl
  ret

; ---------------------------------------------------------
; Name : @ Type : macro
; ---------------------------------------------------------

__mzdefine_40:
  nop
  ld a,end___mzdefine_40-__mzdefine_40-3
  ld   a,(hl)
  inc  hl
  ld   h,(hl)
  ld   l,a
end___mzdefine_40:
  ret

; ---------------------------------------------------------
; Name : c@ Type : macro
; ---------------------------------------------------------

__mzdefine_63_40:
  nop
  ld a,end___mzdefine_63_40-__mzdefine_63_40-3
  ld   l,(hl)
  ld   h,0
end___mzdefine_63_40:
  ret

; ---------------------------------------------------------
; Name : p@ Type : word
; ---------------------------------------------------------

__mzdefine_70_40:
  push  bc
  ld   c,l
  ld   b,h
  in   l,(c)
  ld   h,0
  pop  bc
  ret

; ---------------------------------------------------------
; Name : p! Type : word
; ---------------------------------------------------------

__mzdefine_70_21:
  push  bc
  ld   c,l
  ld   b,h
  out  (c),e
  pop  bc
  ret

; ---------------------------------------------------------
; Name : ! Type : macro
; ---------------------------------------------------------

__mzdefine_21:
  nop
  ld a,end___mzdefine_21-__mzdefine_21-3
  ld   (hl),e
  inc  hl
  ld   (hl),d
  dec  hl
end___mzdefine_21:
  ret

; ---------------------------------------------------------
; Name : c! Type : macro
; ---------------------------------------------------------

__mzdefine_63_21:
  nop
  ld a,end___mzdefine_63_21-__mzdefine_63_21-3
  ld   (hl),e
end___mzdefine_63_21:
  ret

; ---------------------------------------------------------
; Name : break protected Type : macro
; ---------------------------------------------------------

__mzdefine_62_72_65_61_6b:
  nop
  ret
  ld a,end___mzdefine_62_72_65_61_6b-__mzdefine_62_72_65_61_6b-3
  db   $DD,$01
end___mzdefine_62_72_65_61_6b:
  ret

; ---------------------------------------------------------
; Name : copy Type : word
; ---------------------------------------------------------

__mzdefine_63_6f_70_79:
  ld   a,b         ; nothing to do.
  or   c
  ret  z
  push  bc
  push  de
  push  hl
  xor  a          ; find direction.
  sbc  hl,de
  ld   a,h
  add  hl,de
  bit  7,a         ; if +ve use LDDR
  jr   z,__copy2
  ex   de,hl         ; LDIR etc do (DE) <- (HL)
  ldir
__copyExit:
  pop  hl
  pop  de
  pop  bc
  ret
__copy2:
  add  hl,bc         ; add length to HL,DE, swap as LDDR does (DE) <- (HL)
  ex   de,hl
  add  hl,bc
  dec  de          ; -1 to point to last byte
  dec  hl
  lddr
  jr   __copyExit

; ---------------------------------------------------------
; Name : debug Type : word
; ---------------------------------------------------------

__mzdefine_64_65_62_75_67:
DebugShow:
  push  bc
  push  de
  push  hl
  push  bc
  push  de
  push  hl
  ld   a,(SIScreenHeight)     ; on the bottom line
  dec  a
  ld  e,a
  ld  d,0
  ld   h,d
  ld   a,(SIScreenWidth)
  ld   l,a
  call  MULTMultiply16
  pop  de          ; display A
  ld   c,'A'
  call  __DisplayHexInteger
  pop  de          ; display B
  ld   c,'B'
  call  __DisplayHexInteger
  pop  de          ; display B
  ld   c,'C'
  call  __DisplayHexInteger
  pop  hl
  pop  de
  pop  bc
  ret
__DisplayHexInteger:
  push  de
  ld   d,5
  ld   e,c
  set  7,e
  call  WriteCharacter
  inc  hl
  pop  de
  ld   a,d
  call  __DisplayHexByte
  ld   a,e
__DisplayHexByte:
  push  af
  rrc  a
  rrc  a
  rrc  a
  rrc  a
  call  __DisplayHexNibble
  pop  af
__DisplayHexNibble:
  push  de
  ld   d,4
  and  15
  cp   10
  jr   c,__DHN2
  add  a,7
__DHN2: add  a,48
  ld   e,a
  call  WriteCharacter
  inc  hl
  pop  de
  ret

; ---------------------------------------------------------
; Name : .hex Type : word
; ---------------------------------------------------------

__mzdefine_2e_68_65_78:
PrintHexWord:
  ld   a,' '
  call  PrintCharacter
  ld   a,h
  call  PrintHexByte
  ld   a,l
  call  PrintHexByte
  ret
; *********************************************************************************
;
;        Print A in hexadecimal
;
; *********************************************************************************
PrintHexByte:
  push  af
  rrc  a
  rrc  a
  rrc  a
  rrc  a
  call  __PrintNibble
  pop  af
__PrintNibble:
  and  15
  cp   10
  jr   c,__PNIsDigit
  add  7
__PNIsDigit:
  add  48
  jp   PrintCharacter

; ---------------------------------------------------------
; Name : fill Type : word
; ---------------------------------------------------------

__mzdefine_66_69_6c_6c:
  ld   a,b         ; nothing to do.
  or   c
  ret  z
  push bc
  push  hl
__fill1:ld   (hl),e
  inc  hl
  dec  bc
  ld   a,b
  or   c
  jr   nz,__fill1
  pop  hl
  pop  bc
  ret

; ---------------------------------------------------------
; Name : halt Type : word
; ---------------------------------------------------------

__mzdefine_68_61_6c_74:
HaltZ80:
  di
  halt
  jr   HaltZ80

; ---------------------------------------------------------
; Name : io.colour Type : word
; ---------------------------------------------------------

__mzdefine_69_6f_2e_63_6f_6c_6f_75_72:
  ld   l,a
  ld   (IOColour),a
  ret

; ---------------------------------------------------------
; Name : io.emit Type : word
; ---------------------------------------------------------

__mzdefine_69_6f_2e_65_6d_69_74:
  ld   a,l
PrintCharacter:
  push  de
  push  hl
  ld   e,a
  ld   a,(IOColour)
  ld   d,a
  ld   hl,(IOScreenPosition)
  call  WriteCharacter
  inc  hl
  ld   (IOScreenPosition),hl
  pop  hl
  pop  de
  ret

; ---------------------------------------------------------
; Name : io.print.string Type : word
; ---------------------------------------------------------

__mzdefine_69_6f_2e_70_72_69_6e_74_2e_73_74_72_69_6e_67:
PrintString:
  push  hl
__IOASCIIZ:
  ld   a,(hl)
  or   a
  jr   z,__IOASCIIExit
  call PrintCharacter
  inc  hl
  jr   __IOASCIIZ
__IOASCIIExit:
  pop  hl
  ret

; ---------------------------------------------------------
; Name : inkey Type : word
; ---------------------------------------------------------

__mzdefine_69_6e_6b_65_79:
  ex   de,hl
  call  IOScanKeyboard
  ld   l,a
  ld   h,0
  ret

; ---------------------------------------------------------
; Name : screen.mode.48k Type : word
; ---------------------------------------------------------

__mzdefine_73_63_72_65_65_6e_2e_6d_6f_64_65_2e_34_38_6b:
SetScreenMode48kSpectrum:
  push  de
  push  hl
  call  SetMode_Spectrum48k
  ld  (SIScreenDriver),de
  ld   a,l
  ld   (SIScreenWidth),a
  ld   a,h
  ld   (SIScreenHeight),a
  ld   hl,0
  ld   (IOScreenPosition),hl
  pop  hl
  pop  de
  ret

; ---------------------------------------------------------
; Name : screen.mode.layer2 Type : word
; ---------------------------------------------------------

__mzdefine_73_63_72_65_65_6e_2e_6d_6f_64_65_2e_6c_61_79_65_72_32:
SetScreenModeLayer2:
  push  de
  push  hl
  call  SetMode_Layer2
  ld  (SIScreenDriver),de
  ld   a,l
  ld   (SIScreenWidth),a
  ld   a,h
  ld   (SIScreenHeight),a
  ld   hl,0
  ld   (IOScreenPosition),hl
  pop  hl
  pop  de
  ret

; ---------------------------------------------------------
; Name : screen.mode.lowres Type : word
; ---------------------------------------------------------

__mzdefine_73_63_72_65_65_6e_2e_6d_6f_64_65_2e_6c_6f_77_72_65_73:
SetScreenModeLowRes:
  push  de
  push  hl
  call  SetMode_LowRes
  ld  (SIScreenDriver),de
  ld   a,l
  ld   (SIScreenWidth),a
  ld   a,h
  ld   (SIScreenHeight),a
  ld   hl,0
  ld   (IOScreenPosition),hl
  pop  hl
  pop  de
  ret

; ---------------------------------------------------------
; Name : ; protected Type : macro
; ---------------------------------------------------------

__mzdefine_3b:
  nop
  ret
  ld a,end___mzdefine_3b-__mzdefine_3b-3
  ret
end___mzdefine_3b:
  ret

; ---------------------------------------------------------
; Name : sys.info Type : word
; ---------------------------------------------------------

__mzdefine_73_79_73_2e_69_6e_66_6f:
  ex   de,hl
  ld   hl,SystemInformation
  ret

; ---------------------------------------------------------
; Name : io.write.character Type : word
; ---------------------------------------------------------

__mzdefine_69_6f_2e_77_72_69_74_65_2e_63_68_61_72_61_63_74_65_72:
WriteCharacter:
  push  bc
  push  de
  push  hl
  ld   bc,__WCContinue
  push  bc
  ld   bc,(SIScreenDriver)
  push  bc
  ret
__WCContinue:
  pop  hl
  pop  de
  pop  bc
  ret

; ---------------------------------------------------------
; Name : abc>r protected Type : macro
; ---------------------------------------------------------

__mzdefine_61_62_63_3e_72:
  nop
  ret
  ld a,end___mzdefine_61_62_63_3e_72-__mzdefine_61_62_63_3e_72-3
 push  bc
 push  de
 push  hl
end___mzdefine_61_62_63_3e_72:
  ret

; ---------------------------------------------------------
; Name : ab>r protected Type : macro
; ---------------------------------------------------------

__mzdefine_61_62_3e_72:
  nop
  ret
  ld a,end___mzdefine_61_62_3e_72-__mzdefine_61_62_3e_72-3
 push  de
 push  hl
end___mzdefine_61_62_3e_72:
  ret

; ---------------------------------------------------------
; Name : a>b Type : macro
; ---------------------------------------------------------

__mzdefine_61_3e_62:
  nop
  ld a,end___mzdefine_61_3e_62-__mzdefine_61_3e_62-3
 ld   d,h
 ld   e,l
end___mzdefine_61_3e_62:
  ret

; ---------------------------------------------------------
; Name : a>c Type : macro
; ---------------------------------------------------------

__mzdefine_61_3e_63:
  nop
  ld a,end___mzdefine_61_3e_63-__mzdefine_61_3e_63-3
 ld   b,h
 ld   c,l
end___mzdefine_61_3e_63:
  ret

; ---------------------------------------------------------
; Name : a>r protected Type : macro
; ---------------------------------------------------------

__mzdefine_61_3e_72:
  nop
  ret
  ld a,end___mzdefine_61_3e_72-__mzdefine_61_3e_72-3
 push  hl
end___mzdefine_61_3e_72:
  ret

; ---------------------------------------------------------
; Name : b>a Type : macro
; ---------------------------------------------------------

__mzdefine_62_3e_61:
  nop
  ld a,end___mzdefine_62_3e_61-__mzdefine_62_3e_61-3
 ld   h,d
 ld   l,e
end___mzdefine_62_3e_61:
  ret

; ---------------------------------------------------------
; Name : b>c Type : macro
; ---------------------------------------------------------

__mzdefine_62_3e_63:
  nop
  ld a,end___mzdefine_62_3e_63-__mzdefine_62_3e_63-3
 ld   b,d
 ld   c,e
end___mzdefine_62_3e_63:
  ret

; ---------------------------------------------------------
; Name : b>r protected Type : macro
; ---------------------------------------------------------

__mzdefine_62_3e_72:
  nop
  ret
  ld a,end___mzdefine_62_3e_72-__mzdefine_62_3e_72-3
 push  de
end___mzdefine_62_3e_72:
  ret

; ---------------------------------------------------------
; Name : c>a Type : macro
; ---------------------------------------------------------

__mzdefine_63_3e_61:
  nop
  ld a,end___mzdefine_63_3e_61-__mzdefine_63_3e_61-3
 ld   h,b
 ld   l,c
end___mzdefine_63_3e_61:
  ret

; ---------------------------------------------------------
; Name : c>b Type : macro
; ---------------------------------------------------------

__mzdefine_63_3e_62:
  nop
  ld a,end___mzdefine_63_3e_62-__mzdefine_63_3e_62-3
 ld   d,b
 ld   e,c
end___mzdefine_63_3e_62:
  ret

; ---------------------------------------------------------
; Name : c>r protected Type : macro
; ---------------------------------------------------------

__mzdefine_63_3e_72:
  nop
  ret
  ld a,end___mzdefine_63_3e_72-__mzdefine_63_3e_72-3
 push  bc
end___mzdefine_63_3e_72:
  ret

; ---------------------------------------------------------
; Name : r>a protected Type : macro
; ---------------------------------------------------------

__mzdefine_72_3e_61:
  nop
  ret
  ld a,end___mzdefine_72_3e_61-__mzdefine_72_3e_61-3
 pop  hl
end___mzdefine_72_3e_61:
  ret

; ---------------------------------------------------------
; Name : r>ab protected Type : macro
; ---------------------------------------------------------

__mzdefine_72_3e_61_62:
  nop
  ret
  ld a,end___mzdefine_72_3e_61_62-__mzdefine_72_3e_61_62-3
 pop  hl
 pop  de
end___mzdefine_72_3e_61_62:
  ret

; ---------------------------------------------------------
; Name : r>abc protected Type : macro
; ---------------------------------------------------------

__mzdefine_72_3e_61_62_63:
  nop
  ret
  ld a,end___mzdefine_72_3e_61_62_63-__mzdefine_72_3e_61_62_63-3
 pop  hl
 pop  de
 pop  bc
end___mzdefine_72_3e_61_62_63:
  ret

; ---------------------------------------------------------
; Name : r>b protected Type : macro
; ---------------------------------------------------------

__mzdefine_72_3e_62:
  nop
  ret
  ld a,end___mzdefine_72_3e_62-__mzdefine_72_3e_62-3
 pop  de
end___mzdefine_72_3e_62:
  ret

; ---------------------------------------------------------
; Name : r>c protected Type : macro
; ---------------------------------------------------------

__mzdefine_72_3e_63:
  nop
  ret
  ld a,end___mzdefine_72_3e_63-__mzdefine_72_3e_63-3
 pop  bc
end___mzdefine_72_3e_63:
  ret

; ---------------------------------------------------------
; Name : swap Type : macro
; ---------------------------------------------------------

__mzdefine_73_77_61_70:
  nop
  ld a,end___mzdefine_73_77_61_70-__mzdefine_73_77_61_70-3
 ex   de,hl
end___mzdefine_73_77_61_70:
  ret

; ---------------------------------------------------------
; Name : 0= Type : word
; ---------------------------------------------------------

__mzdefine_30_3d:
  ld  a,h
  or  l
  ld  hl,$0000
  ret nz
  dec hl
  ret

; ---------------------------------------------------------
; Name : 0< Type : word
; ---------------------------------------------------------

__mzdefine_30_3c:
  bit 7,h
  ld  hl,$0000
  ret z
  dec hl
  ret

; ---------------------------------------------------------
; Name : 0- Type : word
; ---------------------------------------------------------

__mzdefine_30_2d:
  ld  a,h
  cpl
  ld  h,a
  ld  a,l
  cpl
  ld  l,a
  inc hl
  ret

; ---------------------------------------------------------
; Name : 16/ Type : word
; ---------------------------------------------------------

__mzdefine_31_36_2f:
  sra  h
  rr   l
  sra  h
  rr   l
  sra  h
  rr   l
  sra  h
  rr   l
  ret

; ---------------------------------------------------------
; Name : 16* Type : macro
; ---------------------------------------------------------

__mzdefine_31_36_2a:
  nop
  ld a,end___mzdefine_31_36_2a-__mzdefine_31_36_2a-3
  add  hl,hl
  add  hl,hl
  add  hl,hl
  add  hl,hl
end___mzdefine_31_36_2a:
  ret

; ---------------------------------------------------------
; Name : 1- Type : macro
; ---------------------------------------------------------

__mzdefine_31_2d:
  nop
  ld a,end___mzdefine_31_2d-__mzdefine_31_2d-3
  dec hl
end___mzdefine_31_2d:
  ret

; ---------------------------------------------------------
; Name : 1+ Type : macro
; ---------------------------------------------------------

__mzdefine_31_2b:
  nop
  ld a,end___mzdefine_31_2b-__mzdefine_31_2b-3
  inc hl
end___mzdefine_31_2b:
  ret

; ---------------------------------------------------------
; Name : 256/ Type : word
; ---------------------------------------------------------

__mzdefine_32_35_36_2f:
  ld   l,h
  ld   h,0
  bit  7,h
  ret  z
  dec  h
  ret

; ---------------------------------------------------------
; Name : 256* Type : macro
; ---------------------------------------------------------

__mzdefine_32_35_36_2a:
  nop
  ld a,end___mzdefine_32_35_36_2a-__mzdefine_32_35_36_2a-3
  ld   h,l
  ld   l,0
end___mzdefine_32_35_36_2a:
  ret

; ---------------------------------------------------------
; Name : 2/ Type : macro
; ---------------------------------------------------------

__mzdefine_32_2f:
  nop
  ld a,end___mzdefine_32_2f-__mzdefine_32_2f-3
  sra  h
  rr   l
end___mzdefine_32_2f:
  ret

; ---------------------------------------------------------
; Name : 2- Type : macro
; ---------------------------------------------------------

__mzdefine_32_2d:
  nop
  ld a,end___mzdefine_32_2d-__mzdefine_32_2d-3
  dec hl
  dec hl
end___mzdefine_32_2d:
  ret

; ---------------------------------------------------------
; Name : 2+ Type : macro
; ---------------------------------------------------------

__mzdefine_32_2b:
  nop
  ld a,end___mzdefine_32_2b-__mzdefine_32_2b-3
  inc hl
  inc hl
end___mzdefine_32_2b:
  ret

; ---------------------------------------------------------
; Name : 2* Type : macro
; ---------------------------------------------------------

__mzdefine_32_2a:
  nop
  ld a,end___mzdefine_32_2a-__mzdefine_32_2a-3
  add  hl,hl
end___mzdefine_32_2a:
  ret

; ---------------------------------------------------------
; Name : 4/ Type : macro
; ---------------------------------------------------------

__mzdefine_34_2f:
  nop
  ld a,end___mzdefine_34_2f-__mzdefine_34_2f-3
  sra  h
  rr   l
  sra  h
  rr   l
end___mzdefine_34_2f:
  ret

; ---------------------------------------------------------
; Name : 4* Type : macro
; ---------------------------------------------------------

__mzdefine_34_2a:
  nop
  ld a,end___mzdefine_34_2a-__mzdefine_34_2a-3
  add  hl,hl
  add  hl,hl
end___mzdefine_34_2a:
  ret

; ---------------------------------------------------------
; Name : 8* Type : macro
; ---------------------------------------------------------

__mzdefine_38_2a:
  nop
  ld a,end___mzdefine_38_2a-__mzdefine_38_2a-3
  add  hl,hl
  add  hl,hl
  add  hl,hl
end___mzdefine_38_2a:
  ret

; ---------------------------------------------------------
; Name : abs Type : word
; ---------------------------------------------------------

__mzdefine_61_62_73:
  bit 7,h
  ret z
  ld  a,h
  cpl
  ld  h,a
  ld  a,l
  cpl
  ld  l,a
  inc hl
  ret

; ---------------------------------------------------------
; Name : bswap Type : macro
; ---------------------------------------------------------

__mzdefine_62_73_77_61_70:
  nop
  ld a,end___mzdefine_62_73_77_61_70-__mzdefine_62_73_77_61_70-3
  ld   a,l
  ld   l,h
  ld   h,a
end___mzdefine_62_73_77_61_70:
  ret

; ---------------------------------------------------------
; Name : not Type : word
; ---------------------------------------------------------

__mzdefine_6e_6f_74:
  ld  a,h
  cpl
  ld  h,a
  ld  a,l
  cpl
  ld  l,a
  ret

