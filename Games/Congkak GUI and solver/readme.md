# Congkak GUI with depth-first-search algorithm

Inspired by a NTUSU booth on cultural games, I created an algorithm to find best solutions for Congkak.

## Modules in the repo

- A Flash GUI and an algorithm in C were included. 
- The C algorithm executable generates an "output.txt", the GUI can then read from "Best moves.txt". (reaname required)
- The GUI and C script are not integrated.

## Objective

✔ Get as many beads into your "master bowl" as possible (on player's left).  
✔ When it is your turn, select a cell on your side. Beads will be dropped one by one into subsequent cells. The GUI will demostrate the exact sequence.  
✔ If a bead lands into your "master bowl", you get an extra turn.  
✔ Once all beads are in the master bowl, the one with the most wins.  

## Controls

🖱 Click on a highlighted red small cell to execute a turn.  
🖱 Click on the arrows to switch AI. Currently there are 3 types: random-choice (in-game: Dummy / Human), single-depth search (in-game: Mathematician), full-depth search (in-game: Seer).  
▶ Press the enter key to start the AI once it is selected via clicking arrows.  

## Trying this out on Windows PC

Open flashplayer.exe in parent directory and browse to open "C_KAK_X.swf" in this folder.  
Variations available with different number of starting beads X.

## Issues

The game will hang for first 10s to load the default solution txt file. It is used when full-depth search is required at the very start of the game. A random best solution is picked rather than generated.

## Conclusion
- Congkak, being a game with perfect information, can be instantly won by the starting player through brute-force calculation.
- Many "best solution"s exist but search time for all of them do not scale well. 14-cell, 7 beads per cell setup already took few hours for the C program.
- A "good enough" solution (> half of all beads in your own bowl which enables you to win) should not be hard to find.

> Built with Actionscript 3 in Adobe Flash