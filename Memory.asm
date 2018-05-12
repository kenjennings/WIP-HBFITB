; hbfitb Memory.asm
;
;===============================================================================
; $00-$FF  PAGE ZERO (256 bytes)
; $00-$7F  OS variables.
; $80-$FF  Free memory if floating point functions are not used.

	ORG $80

zbTemp   .byte 0
zbParam1 .byte 0
zbParam2 .byte 0
zbParam3 .byte 0
zbParam4 .byte 0
zbParam5 .byte 0
zbParam6 .byte 0
zbParam7 .byte 0
zbParam8 .byte 0
zbParam9 .byte 0
zbLow    .byte 0
zbHigh   .byte 0
zbLow2   .byte 0
zbHigh2  .byte 0

zwAddr1 = zbLow
zwAddr2 = zbLow2

zwTarget = zwAddr1
zwSource = zwAddr2

zbFlameIndex .byte 0
zbTextIndex  .byte 0




;===============================================================================
; The complete lib_screen.asm wants these values below.
; Declare here in page 0 for better performance.
; Otherwise, remember to declare elsewhere.

;screenColumn       .byte 0
;screenScrollXValue .byte 0

;screenAddress1     .word 0
;screenAddress2     .word 0


;===============================================================================
; $100-$1FF  The 6502 stack.


;===============================================================================
; $200-$4FF  OS variables, and Central I/O device control control and buffers.


;===============================================================================
; $480-$4FF  Free memory.


;===============================================================================
; $500-$57D  Free memory.


;===============================================================================
; $57E-$5FF  Free memory IF floating point library functions are not used.


;===============================================================================
; $600-$6FF  Free memory.


;===============================================================================
; $700-$153F  DOS 2.0 FMS when loaded into memory


;===============================================================================
; $1540-$3306  DUP (DOS user interface menus) when loaded into memory.


;===============================================================================
; Part of DUP may be overlapped by a program when MEMSAVE file is present to
; allow the swapping.  However, the game programs are fairly simple.  There
; is no reason to do anything clever in low memory/DOS memory outside of
; Page 0.  Thus program start addresses should use the LOMEM_DOS_DUP symbol
; and then do alignment as needed from there.

; LOMEM_DOS =     $2000 ; First available memory after DOS
; LOMEM_DOS_DUP = $3308 ; First available memory after DOS and DUP


;===============================================================================
; $3308-$BFFF  Minimum free memory for the program use. (35.24K (worst case))
;              See notes below about possible cartridges.


; ==========================================================================
; Create the custom game screen
;
; mDL_LMS macro requires ANTIC.asm.  That should have already been included,
; since the program is working on a screen display..

; This is a simple program and the main code and libraries should 
; easily fit between $3308 and $4000.
; 
	ORG $4000

SCREENRAM 
; TEXT = COLPF0
; $83  = # (flame  COLPF2)
; $84  = $ (flame  COLPF2)
; $85  = % (flame  COLPF2)
; $46  = & (candle COLPF1)
; Charname bits
; $00 = 00xx.xxxx = COLPF0
; $40 = 01xx.xxxx = COLPF1
; $80 = 10xx.xxxx = COLPF2
; $C0 = 11xx.xxxx = COLPF3

vsScreenRam ; 14 lines of Mode 7 text is 224 scan lines.
	.byte "     ",$83,"              "
	.byte "     ",$46,"        ",$84,"     "
	.byte "  ",$85,"           ",$46,"     "
	.byte "  ",$46,"    HAPPY    ",$83,"   "
	.byte "    ",$84,"           ",$46,"   "
	.byte "    ",$46,"              ",$85
	.byte " ",$83,"    BIRTHDAY     ",$46
	.byte " ",$46,"             ",$84,"    "
	.byte "     ",$85,"         ",$46,"    "
	.byte "     ",$46," STEVE!     ",$83," " ; Fill In The Blank
	.byte "  ",$84,"               ",$46," "
	.byte "  ",$46,"      ",$85,"          "
	.byte "         ",$46,"    ",$84,"     "
	.byte "              ",$46,"     "

; Go to 1K boundary  to make sure display list
; doesn't cross the 1K boundary.
	.align $0400

vsDisplayList ; 14*16 = 224 scan lines of ANTIC goodness
	.byte DL_BLANK_8   ; 8 blank to center 14 Mode 7 text lines

	mDL_LMS DL_TEXT_7, vsScreenRam ; mode 7 text and initial memory scan address
	.rept 13
	.byte DL_TEXT_7   ; 13 more lines of mode 7 text (memory scan is automatic)
	.endr

	.byte DL_JUMP_VB    ; End.  Wait for Vertical Blank.
	.word vsDisplayList ; Restart the Display List

.byte "FFFFFFFFFFFFFFFF"

; Align to next nearest 1/2 K boundary for Mode 7 character set
	.align $0200

CSET1 .ds 512
CSET2 .ds 512
CSET3 .ds 512

 .byte "EEEEEEEEEEEEEEEE"


;===============================================================================
; $3308-$7FFF  Free memory.


;===============================================================================
; $8000-$9FFF  Cartridge B (right cartridge) (8K).
;              A right cart is only possible (and rarely so) on Atari 800.
;              16K cart in the A or left slot also occupies this space.
;              Free memory if no cartridge is installed.


;===============================================================================
; $A000-$BFFF  Cartridge A (left cartridge) or BASIC ROM (8K)
;              Free memory if no cartridge is installed or BASIC is disabled.


;===============================================================================
; $C000-$CFFF  On some machines, unused.  On others, OS ROM or RAM. (4K)


;===============================================================================
; $D000-$D7FF  Custom Chip I/O registers (2K)


;===============================================================================
; $D800-$FFFF  Operating System (10K)
;       $D800-$DFFF  OS Floating Point Math Package (2K)
;       $E000-$E3FF  Default OS Screen Font (1K)
;       $E400-$FFFF  General OS functions (7K)


