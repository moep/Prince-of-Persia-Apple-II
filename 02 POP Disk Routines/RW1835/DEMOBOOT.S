 lst off

org = $1000
 org org

*-------------------------------------------------
*
* 08/01/85
* 07/02/87 mod for 3.5
*
* Demo using the 18 sector routines.
*
* Loads in a double hires picture
* from tracks 2,3,4 and 5.
*
*  by Roland Gustafsson
*

temp0 = $3A
temp1 = $3B

RW18temp = $2100
RW18 = $D000

slot = $FD
track = $FE

*-------------------------------------------------
*
* Move to actual run address
*

start ldy #0
:0 lda $2000,y
 sta org,y
 iny
 bne :0
 jmp :1

* Tell RW18 which slot to use

:1 lda $43
 sta slot

 jsr check64k

* Turn on the disk drive (It is
* already on, but this call is
* necessary to initialize the
* RW18 routine)

LOOP jsr RW18
 hex 000100

* Clear hires page

 jsr hgr

* Now seek to track two since that
* is where the data starts.

 jsr RW18
 hex 020002

* Display double hires page one

 sta $C050
 sta $C052
 sta $C054
 sta $C057
 sta $C00D
 sta $C05E
 sta $C001

* Load in the picture

 bit $C055
 jsr LOADBANK
 bit $C054
 jsr LOADBANK
 sta $C000

* Turn off the drive

 jsr RW18
 hex 01

* Wait for keypress

waitkey lda $C000
 bpl waitkey
 sta $C010
 bmi LOOP

*-------------------------------------------------
*
* Load in two tracks
*
* The C in C3 and C4 means
* bit7:sound speaker on error
* bit6:auto inc track
*
* Read sequence
*

LOADBANK jsr RW18
 hex C320

* Read group

 jsr RW18
 hex 84
 hex 32333435363738393A
 hex 3B3C3D3E0000000000
* ^^^^^^^^
* Note that the last five sectors
* are ignored.
*
* Read last page by itself to
* test RW18.35.

 jsr RW18
 hex C4
 hex 000000000000000000
 hex 000000003F00000000

 rts

*-------------------------------------------------
*
* Clear double hires page
*

hgr sta $C005
 jsr :0
 sta $C004

:0 ldy #0
 ldx #$20
 sty temp0
 stx temp1
 tya
:1 sta (temp0),y
 iny
 bne :1
 inc temp1
 dex
 bne :1
 rts

*-------------------------------------------------
*
* Check for 64k and move RW18 to its home.
*

check64k bit $C08B
 bit $C08B
 ldy #0
:0 sty $E000
 cpy $E000
 bne NOT64K
 iny
 bne :0

* Move RW18 to $D000

 ldx #5
:1 lda RW18temp,y
:2 sta RW18,y
 iny
 bne :1
 inc :1+2
 inc :2+2
 dex
 bne :1
 rts

NOT64K sta $C081
 ldy #0
:0 lda :errtext,y
 beq *
 sta $628,y
 iny
 bne :0

:errtext ASC "REQUIRES 64K MEMORY",00

*------------------------------------------------- EOF

 sav demoboot
