# WIP-HBFITB
Atari Retro Happy Birthday (fill in the blank) 

Build with eclipse/wudsn and MADS assembler.

This is an Atari 8-bit computer assembly program that displays a birthday greeting with burning candles, and animates the candle flames.   No music. 

[![AtariHBFITBScreen](https://github.com/kenjennings/WIP-HBFITB/raw/master/HappyBdayYourNameHere.png)](#features)

Video of the animation on YouTube: https://youtu.be/WLELDFDT3uM

---

This is an upgrade from last year's Atari retro birthday card which was just a lame Atari BASIC program using a GRAPHICS 2 display for text.  This assembly language program does the following:

* Create a custom dsplay list of 14 lines of ANTIC Mode 7 text (color text 16 scan lines tall).

* Defines screen memory containing text "Happy Birthday FillInTheBlank" with candles.

* Allocates three character sets in RAM and copies the Operating System ROM character set images to them.

* Updates the images in each character set to represent a candle and different shapes of flames.

* The main code is a display loop that reads colors from a table and updates the flame colors and the text colors for each scan line.

* At the end of the TV frame it updates index and pointers to scroll the flame colors, and to animate the flame shapes by switching between the different custom character sets.

* No music.  Maybe next year.

Building depends on the MADS include library here: https://github.com/kenjennings/Atari-Mads-Includes.   The includes are related to the AGD (Atari Game Development) project https://github.com/kenjennings/AGD-MADS, but nothing in that project should be required here.

The lib_screen.asm here is a version of the library in the game repositories referenced above, but has been reduced to only the base, minimal functions needed for this program.  So, do not look to it as an example of anything worthwhile.  Do not ask it any questions.  Do not give it food, water, or matches.
 
