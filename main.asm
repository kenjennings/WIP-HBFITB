; hbfitb_main.asm
;
; --------------------------------------------------------------------
; 6502 assembly on Atari.
; Built with eclipse/wudsn/mads.

; Happy Birthday Fill In The Blank

; Hack up a display list with Mode 7 text.
; Display Text.
; Define candles as character set graphics.
; Display "candles" with animated flames
; Run a VBI to flip character sets, and scroll colors.
; Run a display kernal to update colors.
; COLPF0 = text
; COLPF1 = Candle
; COLPF2 = Candle Flame
; This should work on all configurations of 8-bit Atari.
;
; ==========================================================================
; System Includes

	icl "ANTIC.asm"
	icl "GTIA.asm"
	icl "POKEY.asm"
	icl "PIA.asm"
	icl "OS.asm"
	icl "DOS.asm" ; This provides the LOMEM, start, and run addresses.


; ==========================================================================
; Macros (No code/data declared)

	icl "macros.asm"
	icl "macros_screen.asm"
	icl "macros_math.asm"

; ==========================================================================
; Game Specific, Page 0 Declarations, etc.

	icl "Memory.asm"


; ==========================================================================
; This is not a complicated program, so need not be careful about RAM.
; Just set code at a convenient place after DOS, DUP, etc.

	ORG LOMEM_DOS_DUP; $3308  From DOS.asm.  First memory after DOS and DUP


;===============================================================================

 .byte "7777777777777777"

PRG_START


;===============================================================================
; Initialize

	; Turn off screen
	lda #0
	sta SDMCTL ; OS Shadow for DMA control

	; Wait for frame update before touching other display configuration
	mScreenWaitFrames_V 1

	; point ANTIC to the new display.
	mLoadInt_V SDLSTL,vsDisplayList

;	jsr libCopyMode7CSet ; Copy ROM charset to RAM

;	jsr libCopyCustomChars ; redefine the custom characters

;	lda #>CSET1 ; point to custom character set
;	sta CHBAS

	lda #$58 
	sta COLOR1  ; wax candle body (not the burning part)


	; Turn the display back on.
	lda #ENABLE_DL_DMA|PLAYFIELD_WIDTH_NORMAL
	sta SDMCTL

	lda #0  ; reset jiffy clock
	sta RTCLOK60



;===============================================================================
; Update

gMainLoop

	; Wait for the top of the displayed screen.
	mScreenWaitScanLine_V 8

	ldx #17; ("8" above should mean 16 for scan lines. Plus 1 for next line is 17.) 
	ldy zbFlameIndex ; Variable index for flame colors.

bColorLoop
	lda FLAME_COLORS,y
	sta WSYNC
	sta COLPF2
	lda TEXT_COLORS,x
	sta COLPF0
	inx
	iny

	lda VCOUNT       ; Reached the bottom of the screen?
	cmp #90
	bne bColorLoop   ; No, go back and make more color.

	; "End of Frame" activities to manage the cycling colors 
	; and flame animation.  This should be done as part of 
	; a VBI.  I'm just too lazy.
	
	inc zbFlameIndex ; Change the flame starting point for
	inc zbFlameIndex ; the next frame.  INC twice is faster.

	lda #$00         ; Turn off the OS color cycling/anti-screen burn-in
	sta ATRACT

	; "Animation."  flip to the next character set every 3rd TV frame
	lda RTCLOK60  ; jiffy clock, one tick per frame. approx 1/60th/sec NTSC
	cmp #3
	bne bSkipAnim ; Only do the animation every Nth frame

	lda #0       ; Force the jiffy/frame counter back to 0.
	sta RTCLOK60

	; Flip to the next character set
	ldx zbTextIndex
	lda FLIP_FONT_LIST,x
;	sta CHBAS
	; Update counter for next time.
	inx
	txa
	and #$03 ; 0, 1, 2, 3, 0, 1, ...
	sta zbTextIndex

bSkipAnim

	jmp gMainLoop ; Do while More Electricity

	rts

 .byte "6666666666666666"

; ==========================================================================
; Library code and data.

 	icl "lib_screen.asm"


; ==========================================================================
; Inform DOS of the program's Auto-Run address...

	mDiskDPoke DOS_RUN_ADDR, PRG_START


	END


