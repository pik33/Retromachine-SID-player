This is a nostalgic (not only) .sid file player for Raspberry Pi 2/3 
written in Pascal/asm. 
The project is in working alpha stage

Lazarus 1.4 or newer with SDL headers installed is needed 
for build this project from the source. 

Executable binary project1 included. 
To run executable, unpack the project files 
in any directory on the Raspberry Pi, 
do chmod +x project1 and run it from there

Can be run from console mode or X

When in console use -f parameter to start in 1920x1200 fullscerrn mode

Controls: F1..F3 - switch SID channel 1..3 on/off

f - toggle fullscreen, p - pause

1..5 - playing speed: 1 - 100 Hz, 2 - 200 Hz, 3 - 150 Hz. 4 - 400 Hz, 5 - 50 Hz

Esc - exit

Cursor up/down - delect file, Enter - play/chage dir

To build this from the source when in X, 
open the project1.lpi with Lazarus and build.
When in command line mode, use make. 

Needs SDL 1.2


