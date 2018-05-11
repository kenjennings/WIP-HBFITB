# WIP-HBFITB
Work In Progress - Happy Birthday (fill in the blank) 

This is an upgrade from last year's retro birthday card.  It does the following:

* Create a custom dsplay list of 14 lines of ANTIC Mode 7 text (color text 16 scan lines tall).

* Defines screen memory containing text "Happy Birthday FillInTheBlank" with candles.

* Create three character sets in RAM and copies the ROM images to them.

* Updates the images in each character set to represent a candle and different shapes of flames.

* The main code is a display loop that reads colors from a table and updates the flame colors and the text colors for each scan line.

* At the end of the TV frame it updates index and pointers to scroll the flame colors, and to animate the flame shapes by switching between the different custom character sets.

* No music.  Maybe next year.

Building depends on the MADS include library here: https://github.com/kenjennings/Atari-Mads-Includes.   The includes are related to the AGD (Atari Game Development) project https://github.com/kenjennings/AGD-MADS, but nothing in that project should be required here.

The lib_screen.asm here is a version of the library in the game repositories referenced above, but has been reduced to only the base, minimal fucntions needed for this program.  So, do not look to it as an example of anything worthwhile.  Do not ask it any questions.  Do not give it food, water, or matches.
