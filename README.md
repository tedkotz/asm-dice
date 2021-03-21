Dice Roller Boot
================

Dice roller for your bootloader. This simple assembly language program can be
invoked directly by the BIOS boot loader.

The actual program is just a simple dice roller with accumulator functionality.

This is a cleanup version of an assembly program I wrote a long time ago for DOS.

If you look in the git log you can see the original. It can fairly easily be
modified back to generate the dos compatible .com file.

A walk through of this code and the porting process is here.
https://www.youtube.com/watch?v=tF2bwIxY2UI

## Files
|File         |Description                                               |
|-------------|----------------------------------------------------------|
|bochsrc.txt  |Setup to test with the bochs emulator                     |
|dice.asm     |The actual program source                                 |
|Makefile     |Makefile to build and run the program                     |

