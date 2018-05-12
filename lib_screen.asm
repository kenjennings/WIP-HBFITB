;hbfitb lib_screen.asm
;
;==============================================================================
; lib_screen.asm
;==============================================================================

; This is cut down to mostly just the necessary functions.
; Screen writing/plotting is not needed, so those
; functions are removed.


;==============================================================================
; Data declarations and subroutine library code
; performing screen operations.


;===============================================================================
; Variables

; Images for the animated characters.
; These are "visual" items that one may think belongs in the 
; Memory file, but these are not accessed by ANTIC directly.  
; These are master bitmaps to copy to the displayed character 
; sets.  Therefore these are just "data".
 
 .byte "DDDDDDDDDDDDDDDDDDDD"

FLAME1
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %01110000
	.byte %01111000
	.byte %00111000
	.byte %00010000

FLAME2
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00010000
	.byte %00111000
	.byte %00111000
	.byte %00111000
	.byte %00010000

FLAME3
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00011100
	.byte %00111100
	.byte %00111000
	.byte %00010000

CANDLE
	.byte %00111000
	.byte %00111100
	.byte %00111100
	.byte %00111000
	.byte %00111000
	.byte %00111000
	.byte %00111000
	.byte %01111100

 .byte "CCCCCCCCCCCCCCCC"
 
; List of Source bitmaps for copying chars
SOURCE_CHAR ; Address of bitmaps
	.word FLAME1,FLAME2,FLAME2,CANDLE
	.word FLAME2,FLAME1,FLAME3,CANDLE
	.word FLAME3,FLAME3,FLAME1,CANDLE

 .byte "BBBBBBBBBBBBBBBB"

; List of the Target characters to redefine
TARGET_CHAR ; offsets for chars 3, 4, 5, 6, or +24, +32, +40, +48
	.word CSET1+$18,CSET1+$20,CSET1+$28,CSET1+$30
	.word CSET2+$18,CSET2+$20,CSET2+$28,CSET2+$30
	.word CSET3+$18,CSET3+$20,CSET3+$28,CSET3+$30

 .byte $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA

; List of fonts switched between frames for "animation".
FLIP_FONT_LIST
	.byte >CSET1,>CSET2,>CSET3,>CSET2

 .byte "9999999999999999"

; I irrationally feel better when a list of 
; 256 values is all inside one page.

	.align $100

	; List of colors by scan line for flames.
FLAME_COLORS
;16 1
	.byte $EE,$EC,$EA
	.byte $EE,$EC,$EA,$E8,$E6
	.byte $36,$38,$3A,$3C,$3E
	.byte $3A,$3C,$3E

;16 2
	.byte $FE,$FC,$FA
	.byte $FE,$FC,$FA,$F8,$F6
	.byte $16,$18,$1A,$1C,$1E
	.byte $1A,$1C,$1E

;16 3
	.byte $DE,$DC,$DA
	.byte $DE,$DC,$DA,$D8,$D6
	.byte $00,$00,$00,$00,$00
	.byte $00,$00,$00

;16 4
	.byte $EE,$EC,$EA,$E8,$E6
	.byte $EE,$EC,$EA
	.byte $FE,$FC,$FA
	.byte $FE,$FC,$FA,$F8,$F6

;16 5
	.byte $36,$38,$3A,$3C,$3E
	.byte $3A,$3C,$3E
	.byte $1A,$1C,$1E
	.byte $16,$18,$1A,$1C,$1E

;16 6
	.byte $DE,$DC,$DA
	.byte $DE,$DC,$DA,$D8,$D6
	.byte $26,$28,$2A,$2C,$2E
	.byte $2A,$2C,$2E

;16 7
	.byte $FE,$FC,$FA
	.byte $FE,$FC,$FA,$F8,$F6
	.byte $16,$18,$1A,$1C,$1E
	.byte $1A,$1C,$1E

;16 8
	.byte $EE,$EC,$EA,$E8,$E6
	.byte $EE,$EC,$EA
	.byte $FE,$FC,$FA
	.byte $FE,$FC,$FA,$F8,$F6

;16 9 ============================
	.byte $36,$38,$3A,$3C,$3E
	.byte $3A,$3C,$3E
	.byte $DE,$DC,$DA
	.byte $DE,$DC,$DA,$D8,$D6

;16 10
	.byte $16,$18,$1A,$1C,$1E
	.byte $1A,$1C,$1E
	.byte $8A,$8C,$8E
	.byte $86,$88,$8A,$8C,$8E

;16 11
	.byte $26,$28,$2A,$2C,$2E
	.byte $2A,$2C,$2E
	.byte $EE,$EC,$EA
	.byte $EE,$EC,$EA,$E8,$E6

;16 12
	.byte $FE,$FC,$FA
	.byte $FE,$FC,$FA,$F8,$F6
	.byte $DE,$DC,$DA
	.byte $DE,$DC,$DA,$D8,$D6

;16 13
	.byte $3A,$3C,$3E
	.byte $36,$38,$3A,$3C,$3E
	.byte $16,$18,$1A,$1C,$1E
	.byte $1A,$1C,$1E

;16 14
	.byte $EE,$EC,$EA,$E8,$E6
	.byte $EE,$EC,$EA
	.byte $2A,$2C,$2E
	.byte $26,$28,$2A,$2C,$2E

;16 15
	.byte $DE,$DC,$DA,$D8,$D6
	.byte $DE,$DC,$DA
	.byte $EE,$EC,$EA
	.byte $EE,$EC,$EA,$E8,$E6

;16 16
	.byte $16,$18,$1A,$1C,$1E
	.byte $1A,$1C,$1E
	.byte $FE,$FC,$FA
	.byte $FE,$FC,$FA,$F8,$F6

; List of colors by scan line for text.
TEXT_COLORS
	.rept 64 ; 4 lines of ANTIC 7 text
	.byte 0
	.endr
	.byte $2C,$2C,$2C,$2C,$2C,$2A,$2A,$2A,$2A,$28,$28,$28,$26,$26,$24,$22 ; orange Happy
	.rept 32 ; 2 lines of ANTIC 7 text
	.byte 0
	.endr
	.byte $4C,$4C,$4C,$4C,$4C,$4A,$4A,$4A,$4A,$48,$48,$48,$46,$46,$44,$42 ; red Birthday
	.rept 32 ; 2 lines of ANTIC 7 text
	.byte 0
	.endr
	.byte $9C,$9C,$9C,$9C,$9C,$9A,$9A,$9A,$9A,$98,$98,$98,$96,$96,$94,$92 ; blue Fill In The Blank
	.rept 48 ; 3 lines of ANTIC 7 text
	.byte 0
	.endr


 .align $0100

 .byte "8888888888888888"

 
; Not so re-usable copy from ROM to the three
; character sets in RAM.
; Copies only the first two pages, since Mode 7
; character sets are 512 bytes.

	.byte " libCopyMode7CSet ================ "

libCopyMode7CSet
	ldx #$00
blCM7C_LoopPage
	lda ROM_CSET,x ; From first page of ROM cset
	sta CSET1,x
	sta CSET2,x
	sta CSET3,x
	lda ROM_CSET+$100,x ; From second page of ROM cset
	sta CSET1+$100,x
	sta CSET2+$100,x
	sta CSET3+$100,x
	inx
	bne blCM7C_LoopPage

	rts


; Apply redefined custom character images.
; The flame shape is animated by switching
; between character sets.  This means a different
; image appears in each character set for the
; same character.  To simplify what image goes where
; this is driven by a couple of tables that provide
; the source and target addresses.
; All the routine does is walk the tables and copy
; 8 bytes between each source/target pair.
; It works something like this:
; For x = 0 to 11  (Actually from 0 to 23 bytes)
;     Get TargetAddress[x] ; RAM character
;     Get SourceAddress[x] ; custom image
;     For y = 7 to 0
;         Poke TargetAddress+y, Peek(Source+y)
;     Next y
; Next x

	.byte " libCopyCustomChars ================ "

libCopyCustomChars
	ldx #0 ; The copy counter 

blCCC_CopyChars
	; Read low bytes of addresses for source and target
	; from the tables and put into page 0.
	lda SOURCE_CHAR,x
	sta zwSource
	lda TARGET_CHAR,x
	sta zwTarget
	inx
	; Read high bytes of addresses for source and target
	; from the tables and put into page 0.
	lda SOURCE_CHAR,x
	sta zwSource+1
	lda TARGET_CHAR,x
	sta zwTarget+1
	inx  ; resulting inX value here2, 4, 6, 8, 10... 24 

	ldy #7
blCCC_CopyBytes      ; copy 8 bytes
	lda (zwSource),y ; from the source
	sta (zwTarget),y ; to the target
	dey
	bpl blCCC_CopyBytes

	cpx #24 ; Reached the end?
	bne blCCC_CopyChars

	rts





;==============================================================================
;                                                       SCREENWAITSCANLINE  A
;==============================================================================
; Subroutine to wait for ANTIC to reach a specific scanline in the display.
;
; ScreenWaitScanLine expects  A  to contain the target scanline.
;==============================================================================

	.byte " libScreenWaitScanLine ================ "

libScreenWaitScanLine

bLoopWaitScanLine
    cmp VCOUNT           ; Does A match the scanline?
    bne bLoopWaitScanLine ; No. Then have not reached the line.

    rts ; Yes.  We're there.  exit.


;==============================================================================
;                                                       SCREENWAITFRAMES  A  Y
;==============================================================================
; Subroutine to wait for a number of frames.
;
; FYI:
; Calling via macro  mScreenWaitFrames 1  is the same thing as
; directly calling ScreenWaitFrame.
;
; ScreenWaitFrames expects Y to contain the number of frames.
;
; ScreenWaitFrame uses  A
;==============================================================================

	.byte " libScreenWaitFrames ================ "
	
libScreenWaitFrames
    tay
    beq bExitWaitFrames

bLoopWaitFrames
    jsr libScreenWaitFrame

    dey
    bne bLoopWaitFrames

bExitWaitFrames
    rts ; No.  Clock changed means frame ended.  exit.


;==============================================================================
;                                                           SCREENWAITFRAME  A
;==============================================================================
; Subroutine to wait for the current frame to finish display.
;
; ScreenWaitFrame  uses A
;==============================================================================

	.byte " libScreenWaitFrame ================ "
	
libScreenWaitFrame
    lda RTCLOK60  ; Read the jiffy clock incremented during vertical blank.

bLoopWaitFrame
    cmp RTCLOK60      ; Is it still the same?
    beq bLoopWaitFrame ; Yes.  Then the frame has not ended.

    rts ; No.  Clock changed means frame ended.  exit.

