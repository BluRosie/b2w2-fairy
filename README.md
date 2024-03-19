# Fairy Type in Black 2/White 2
A repository housing the code and simple insertion steps for Fairy type in B2W2.  There are more in-depth directions [here](https://kingdom-of-ds-hacking.github.io/gen5/guides/misc/b2w2-fairy.html).  This repository only inserts the code!  Graphics and such are up to the user following [MeroMero's tutorial](https://www.pokecommunity.com/showthread.php?t=349000) or [my tutorial linked here](https://kingdom-of-ds-hacking.github.io/docs/generation-v/guides/b2w2-fairy/), which is a bit more modern.

## Directions
- Download the code
- Place your White 2/Black 2 ROM in the base folder (`b2w2-fairy-main`) as `base.nds`
- Read and modify the configs at the beginning of `asm\fairy.s`.  The only one that should really be changed is `BLACK2` being `1` if you are applying to Black 2, and `0` if applying to White 2.
- Double click on the `applyfairytype.bat` batch file
  - A script will run that applies all the Fairy type code changes to copied overlay files and recompresses them in the base folder for ROM insertion
- Open `base.nds` in Tinke
- "Change file" all of overlays 167, 168, 207, 255, 265, 296, 298, the overlay table (y9.bin), and the arm9
- Save your ROM as some other named file

## Credits
Sunk for going through and fixing all of the bugs that this had initially (hall of fame, PC box tag overwrite, and getting it loaded in the Dex).
