;hbfitb lib_screen.asm
;
;==============================================================================
; lib_screen.asm
;==============================================================================

;==============================================================================
; Data declarations and subroutine library code
; performing screen operations.

;==============================================================================
; For the sake of simplicity many of the library and supporting functions
; purposely imitate the C64 with its pre-designated locations and
; full screen layout for playfield graphics.
;
; Screen memory and the Display List is declared in Memory.asm.  In many
; game circumstances the screen creation is so variable on the Atari
; that it is usually sensible to put that information under the control
; of the main program, not the support library.  However, in keeping with
; the simple C64 model, this library assumes contiguous screen memory for
; a full screen of text.
;
; The default display is "normal" text, aka OS/BASIC mode 0 or ANTIC mode
; 2 text.  The library supports a function to switch the display to other
; text modes that use the same number of scan lines per mode line. (modes
; 4 and 6.)
;
; For best use of code and optimal execution the macro and library code
; expect the following variables declared in page 0:

;screenColumn       .byte 0
;screenScrollXValue .byte 0

;screenAddress1     .word 0
;screenAddress2     .word 0

; If these are not added to page 0 before including this file, then
; they should be declared here.

; Note that actual screen RAM, and the Display List are
; defined/declared in the Memory.asm file.


;===============================================================================
; Variables

; The 6502 can only multiply times 2.  Doing the math to
; multiply screen row coordinates by 40 takes several steps.
; Rather than doing the work in code, instead we can do the work
; in data and pre-calculate math to multiply row values by 40.

; Below are two tables to provide the starting address of each
; row of screen memory.  When a location is needed simply use the
; Y coordinate as the lookup index into the table  ( lda table,y ).
; Since addresses require two bytes, one table provides the low
; byte of the addres, and the other provides the high byte.

; The code to set up the table data would have looked like this:
;
;ScreenRAMRowStartLow ; SCREENRAM + 40*0, 40*1, 40*2 ... 40*26
;	byte <SCREENRAM,     <SCREENRAM+40,  <SCREENRAM+80
;	byte <SCREENRAM+120, <SCREENRAM+160, <SCREENRAM+200
;	byte <SCREENRAM+240, <SCREENRAM+280, <SCREENRAM+320
;	byte <SCREENRAM+360, <SCREENRAM+400, <SCREENRAM+440
;	byte <SCREENRAM+480, <SCREENRAM+520, <SCREENRAM+560
;	byte <SCREENRAM+600, <SCREENRAM+640, <SCREENRAM+680
;	byte <SCREENRAM+720, <SCREENRAM+760, <SCREENRAM+800
;	byte <SCREENRAM+840, <SCREENRAM+880, <SCREENRAM+920
;	byte <SCREENRAM+960, <SCREENRAM+1000, <SCREENRAM+1040

; This provides an opportunity to demonstrate the benefits of modern
; assemblers.  Here is the code to create a table of 27 entries
; containing the low byte of the addresses pointing to the first byte
; of screen memory for each row of text on screen.
;
; The first 25 lines are the game display.  The last two lines
; of data are for debug/diagnostic text.

ScreenRAMRowStartLow  ; SCREENRAM + 40*0, 40*1, 40*2 ... 40*26
	.rept 27,#        ; The # provides the current value of the loop
		.byte <[40*:1+vsScreenRam]  ; low byte 40 * loop + Screen mem base.
	.endr

ScreenRAMRowStartHigh  ; SCREENRAM + 40*0, 40*1, 40*2 ... 40*26
	.rept 27,#
		.byte >[40*:1+vsScreenRam] ; low byte 40 * loop + Screen mem base.
	.endr

; List of Target characters to redefine
;
TARGET_CHAR ; offsets for chars 3, 4, 5, 6, or +24, +32, +40, +48
	.word CSET1+$18,CSET1+$20,CSET1+$28,CSET1+$30
	.word CSET2+$18,CSET2+$20,CSET2+$28,CSET2+$30
	.word CSET3+$18,CSET3+$20,CSET3+$28,CSET3+$30

; List of Source bitmaps for chars
SOURCE_CHAR ; Address of bitmaps
	.word FLAME1,FLAME2,FLAME3,CANDLE
	.word FLAME2,FLAME1,FLAME3,CANDLE
	.word FLAME2,FLAME3,FLAME1,CANDLE

; List of fonts switched during vertical blank.
;
FLIP_FONT_LIST
	.byte >CSET1,>CSET2,>CSET3,>CSET2

; I feel better if a list of 256 values is on a page.
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
	.ds 64,0 ; 4 lines of ANTIC 7 text
	.byte $2C,$2C,$2C,$2C,$2C,$2A,$2A,$2A,$2A,$28,$28,$28,$26,$26,$24,$22 ; orange Happy
	.ds 48,0 ; 3 lines of ANTIC 7 text
	.byte $4C,$4C,$4C,$4C,$4C,$4A,$4A,$4A,$4A,$48,$48,$48,$46,$46,$44,$42 ; red Birthday
	.ds 48,0 ; 3 lines of ANTIC 7 text
	.byte $9C,$9C,$9C,$9C,$9C,$9A,$9A,$9A,$9A,$98,$98,$98,$96,$96,$94,$92 ; blue Fill In The Blank
	.ds 48,0 ; 3 lines of ANTIC 7 text


; Not very re-usable copy from ROM to the three
; character sets.
; Copies only the first two pages, since Mode 7
; character sets are 512 bytes.

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
; this is driven by a couple of lists that provide
; the source address and the target addresses.
; All the routine does is walk the tables and copy
; 8 bytes between each source/target pair.
; It works something like this:
; For x = 0 to 12
;     Get TargetAddress[x] ; RAM character
;     Get SourceAddress[x] ; custom image
;     For y = 7 to 0
;         Poke TargetAddress+y, Peek(Source+y)
;     Next y
; Next x

libCopyCustomChars
	ldx #0 ; The copy counter

blCCC_CopyChars
	; Read low bytes of addresses for source and destination
	; from the tables and put into page 0.
	ldx zbCopyCount
	lda TARGET_CHAR,x
	sta zwAddr1
	lda SOURCE_CHAR,x
	sta zwAddr2
	inx
	; Read high bytes of addresses for source and destination
	; from the tables and put into page 0.
	lda TARGET_CHAR,x
	sta zwAddr1+1
	lda SOURCE_CHAR,x
	sta zwAddr2+1
	inx

	lda #7
blCCC_CopyBytes     ; copy 8 bytes
	lda (zwAddr2),y ; from the source
	sta (zwAddr1),y ; to the target
	dey
	bpl blCCC_CopyBytes

	cpx #24 ; Reached the end?
	bne blCCC_CopyChars

	rts

;==============================================================================
;														SCREENFILLMEM  A  X
;==============================================================================
; Subroutine to set all the bytes of screen memory.
;
; It is like a generic routine to clear memory, but it specifically sets
; 1,000 sequential bytes, and it is only used to clear screen RAM.
;
; However, the total memory allocation accounts for 27 lines of text.
; Why 27?  The last two lines  of data are used for on-screen diagnostic
; information. One of these lines appears at the top of the screen, and
; the other appears at the bottom.  This allows the working 25 lines
; between the debug text lines to appear on screen at the same scan
; line positions as they do when the debug information is not included.
;
; ScreenFillMem expects  A  to contain the byte to put into all screen memory.
;
; ScreenFillMem uses  X
;
;==============================================================================

libScreenFillMem
	ldx #250              ; Set loop value

bLoopScreenFillMem
	sta vsScreenRam-1,x     ; Set +000 - +249
	sta vsScreenRam+249,x   ; Set +250 - +499
	sta vsScreenRam+499,x   ; Set +500 - +749
	sta vsScreenRam+749,x   ; Set +750 - +999

	dex
	bne bLoopScreenFillMem ; If x<>0, then loop again

	; The debug lines are always cleared to spaces.
.if DO_DIAG=1
	jsr libDiagClear
.endif

	rts


;==============================================================================
;													SCREENSETTEXTMODE  A  Y
;==============================================================================
; Subroutine to change the text mode of the entire display.
;
; The text/graphics modes on the Atari are determined by the
; instructions in the Display List.
;
; The library creates a Display List as a full screen of text to act similarly
; to the C64's screen treatment. (Done for the purpose of convenience - the
; least departure from the way the C64 works).  In this case "normal" text is
; a screen of ANTIC text mode 2.
;
; To change the entire "screen" all the instructions in the Display List must
; be changed.  The library supports rewriting all the instructions in the
; Display with ANTIC modes 2, 4, and 6 which all share the same number of
; scan lines per text line and so have nearly identical Display Lists.
;
; The code will not change the display if  A  does not contain 2, 4, or 6
;
; ScreenSetTextMode expects  A  to contain the new text mode.
;
; ScreenSetTextMode uses  Y
;
; ScreenSetTextMode uses zbTemp in Page 0.
;==============================================================================

libScreenSetTextMode
	cmp #2       ; Mode 2, "normal", 40 chars, 8 scan lines per mode line
	beq bDoScreenSetMode
	cmp #4       ; Mode 4, multi-color, 40 chars, 8 scan lines per mode line
	beq bDoScreenSetMode
	cmp #6       ; Mode 6, 5 color, 20 chars, 8 scan lines per mode line
	bne bExitScreenSetMode ; not 2, 4, 6, so exit.

bDoScreenSetMode
	sta zbTemp   ; Save mode.  We need it frequently.

	; First instruction has LMS and address. Special handling.
.if DO_DIAG=1
	; First debug line
	mScreenChangeModeInstruction_M vsDisplayList+2
	; First text line
	mScreenChangeModeInstruction_M vsDisplayList+5

	ldy #24     ; 0 to 24 is 25 more mode lines.
    DL_OFFSET=8 ; for next section.
.else
	; First text line without a debug line included
	mScreenChangeModeInstruction_M vsDisplayList+3

	ldy #23     ; 0 to 23 is 24 more mode lines.
    DL_OFFSET=6 ; for next section
.endif

	; Do similar update to the remainder of the display list.

bLoopScreenSetMode
	lda vsDisplayList+DL_OFFSET,y
	and #$F0              ; Remove the mode bits.  Keep current option bits.
	ora zbTemp            ; Replace the mode.
	sta vsDisplayList+DL_OFFSET,y ; Restore first instruction.

	dey
	bpl bLoopScreenSetMode ; Iterate through the sequential instructions.

bExitScreenSetMode
	rts


;==============================================================================
;														SCREENBANNER  A  X  Y
;==============================================================================
; Copy text block to the screen memeory.
;
; This copies a block of text describing the features of the Modifications
; into a fixed location in screen memory.
;
; ScreenBanner uses  A  X  and  Y
;==============================================================================

; The only bad thing about modern computers is how difficult it is to
; type those special graphics characters....

; This is intentionally done using internal screen codes, so the data
; can be copied directly without using Operating System print functions.

ScreenBannerBytes
	; top line of banner. (top of box and corners)
	.byte $51 ; ctrl-q, upper left box corner
	.rept 30
		.byte $52 ; ctrl-R, horizontal line
	.endr
	.byte $45 ; ctrl-e, upper right box corner

	; Text between the box border left and right sides.
	.byte $7C,"This modification of the      ",$7C ; $7C is vertical bar.
	.byte $7C,"Chapter 6 introductory program",$7C
	.byte $7C,"waits for 256 frames, which is",$7C
	.byte $7C,"about 4 seconds, and then it  ",$7C
	.byte $7C,"changes the screen colors.    ",$7C

	; bottom line of banner. (bottom of box and corners)
	.byte $5A ; ctrl-z, lower left box corner
	.rept 30
		.byte $52 ; ctrl-R, horizontal line
	.endr
	.byte $43 ; ctrl-c, lower right box corner

libScreenBanner
	; Setup zero page pointer to the banner
	mLoadInt_V screenAddress1,ScreenBannerBytes

	; Setup the Zero page pointer to the screen position
	mLoadInt_V screenAddress2,[vsScreenRam+84]

	ldx #7 ; count the lines

bLoopWriteScreenBannerLine
	ldy #31

bLoopWriteScreenBannerChars
	lda (screenAddress1),y ; Get character from banner buffer.
	sta (screenAddress2),y ; store into screen position

	dey                              ; Decrement. It is "writing" right to left.
	bpl  bLoopWriteScreenBannerChars ; if it did not become -1, do another character

	dex   ; decrement line counter..  At 0 we are done.
	beq bExitScreenBanner

	; Adjust starting positions for next line.

	; Add 32 to the banner pointer.
	mWord_M_Add_V screenAddress1,screenAddress1,32

	; Add 40 to the screen memory
	mWord_M_Add_V screenAddress2,screenAddress2,40

	jmp bLoopWriteScreenBannerLine ; next line.  no clever branch.  Just goto.

bExitScreenBanner

.if DO_DIAG=1
	; While we're here, let's write out the diagnostics labels
	jsr libDiagWriteLabels
.endif

	rts


;==============================================================================
;                                                       SCREENWAITSCANLINE  A
;==============================================================================
; Subroutine to wait for ANTIC to reach a specific scanline in the display.
;
; ScreenWaitScanLine expects  A  to contain the target scanline.
;==============================================================================

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

libScreenWaitFrame
    lda RTCLOK60  ; Read the jiffy clock incremented during vertical blank.

bLoopWaitFrame
    cmp RTCLOK60      ; Is it still the same?
    beq bLoopWaitFrame ; Yes.  Then the frame has not ended.

    rts ; No.  Clock changed means frame ended.  exit.


