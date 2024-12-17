# Hangman Game in x86 Assembly

## Overview
A simple Hangman game written in 16-bit x86 Assembly, playable in DOSBox.

## Features
- Randomly selects a city name.  
- 6 wrong guesses allowed.  
- Displays the correct city if you lose.

## Requirements
- **NASM** (assembler)  
- **DOSBox** (emulator)

## How to Play
### Assemble the code:
```bash
nasm -f bin hangman.asm -o hangman.com

### Run with dosbox:
dosbox hangman.com
