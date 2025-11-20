#!/bin/bash

trap "killall speaker-test 2>/dev/null; exit" SIGINT SIGTERM

echo "Playing Imperial March on speaker-test..."
echo "Press Ctrl+C to stop the madness."

play_note() {
    freq=$1
    duration=$2
    
    speaker-test -t sine -f $freq -l 1 > /dev/null 2>&1 &
    
    pid=$!
    
    sleep $duration
    
    kill -9 $pid 2>/dev/null
    wait $pid 2>/dev/null
    
    sleep 0.05
}

play_note 440 0.4
play_note 440 0.4
play_note 440 0.4

play_note 349 0.3

play_note 523 0.1

play_note 440 0.4

play_note 349 0.3

play_note 523 0.1

play_note 440 0.8

play_note 659 0.4
play_note 659 0.4
play_note 659 0.4
play_note 698 0.3
play_note 523 0.1

play_note 415 0.4
play_note 349 0.3
play_note 523 0.1
play_note 440 0.8

killall speaker-test 2>/dev/null
