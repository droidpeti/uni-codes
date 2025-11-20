#!/bin/bash

trap "killall speaker-test 2>/dev/null; exit" SIGINT SIGTERM

play_note() {
    freq=$1
    duration=$2
    speaker-test -t sine -f $freq -l 1 > /dev/null 2>&1 &
    pid=$!
    sleep $duration
    kill -9 $pid 2>/dev/null
    wait $pid 2>/dev/null
    sleep 0.02
}

C4=262
Cs4=277
D4=294
Ds4=311
E4=330
F4=349
Fs4=370
G4=392
Gs4=415
A4=440
As4=466
B4=494
C5=523
Cs5=554
D5=587
Ds5=622
E5=659

echo "Playing Hailfire Peaks"

play_note $C4 0.4
play_note $E4 0.2
play_note $G4 0.2
play_note $Gs4 0.4
play_note $G4 0.2

play_note $E4 0.1
play_note $E4 0.1
play_note $G4 0.4
play_note $Gs4 0.2
play_note $G4 0.2
play_note $E4 0.2

play_note $C4 0.5
play_note $B4 0.2
play_note $B4 0.2
play_note $B4 0.2
play_note $B4 0.2
play_note $C5 0.4
play_note $G4 0.2
play_note $G4 0.2

play_note $G4 0.1
play_note $Gs4 0.1
play_note $G4 0.1
play_note $Fs4 0.1
play_note $G4 0.4
play_note $E4 0.4

play_note $Ds4 0.2
play_note $E4 0.2
play_note $Ds4 0.2
play_note $D4 0.2
play_note $Ds4 0.4
play_note $E4 0.2

play_note $C4 0.4
play_note $E4 0.2
play_note $G4 0.2
play_note $Gs4 0.4
play_note $G4 0.2

play_note $E4 0.1
play_note $E4 0.1
play_note $G4 0.4
play_note $Gs4 0.2
play_note $G4 0.2
play_note $E4 0.2

play_note $C4 0.5
play_note $B4 0.2
play_note $B4 0.2
play_note $B4 0.2
play_note $B4 0.2
play_note $C5 0.4
play_note $G4 0.2
play_note $G4 0.2

play_note $As4 0.2
play_note $G4 0.2
play_note $As4 0.2
play_note $G4 0.2
play_note $As4 0.2
play_note $B4 0.4
play_note $C5 0.4
play_note $C4 0.4
play_note $C4 0.4

killall speaker-test 2>/dev/null