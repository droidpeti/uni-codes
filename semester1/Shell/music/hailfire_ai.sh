#!/bin/bash

trap "killall speaker-test 2>/dev/null; exit" SIGINT SIGTERM

# --- THE ENGINE (PURE BASH INTEGER MATH) ---

# We work in MILLISECONDS (Integers) to avoid using 'bc'
# 102 BPM = approx 588 ms per beat
TEMPO_MS=588

# Rhythm Library (Calculated using standard integer math)
q=$TEMPO_MS                     # Quarter Note
e=$(( TEMPO_MS / 2 ))           # Eighth Note
s=$(( TEMPO_MS / 4 ))           # Sixteenth Note
dq=$(( TEMPO_MS * 3 / 2 ))      # Dotted Quarter (1.5x)

play_note() {
    freq=$1
    duration_ms=$2
    
    # STACCATO CALCULATION (Integer Math)
    # Play sound for 85% of the time
    audible_ms=$(( duration_ms * 85 / 100 ))
    
    # Silence for the remaining 15%
    rest_ms=$(( duration_ms - audible_ms ))
    
    # CONVERSION HACK
    # We need to turn '500' ms into '0.500' seconds for the sleep command.
    # We use printf to handle the formatting.
    
    # 1. Calculate seconds and fractional milliseconds separately
    aud_sec=$(( audible_ms / 1000 ))
    aud_frac=$(( audible_ms % 1000 ))
    
    rest_sec=$(( rest_ms / 1000 ))
    rest_frac=$(( rest_ms % 1000 ))
    
    # 2. Format them into strings like "0.499"
    audible_str=$(printf "%d.%03d" $aud_sec $aud_frac)
    rest_str=$(printf "%d.%03d" $rest_sec $rest_frac)

    # 3. Execute
    speaker-test -t sine -f $freq -l 1 > /dev/null 2>&1 &
    pid=$!
    
    sleep $audible_str
    
    kill -9 $pid 2>/dev/null
    wait $pid 2>/dev/null
    
    sleep $rest_str
}

# --- FREQUENCIES ---
C4=262; Cs4=277; D4=294; Ds4=311; E4=330; F4=349; Fs4=370; G4=392; Gs4=415; A4=440; As4=466; B4=494
C5=523; Cs5=554; D5=587; Ds5=622; E5=659

echo "Playing: Hailfire Peaks (Lava Side)"
echo "Mode: Pure Bash (No 'bc')"

# --- MAIN RIFF ---
play_note $C4 $q
play_note $E4 $e
play_note $G4 $e
play_note $Gs4 $q
play_note $G4 $e

# --- MEASURE 2 ---
play_note $E4 $s
play_note $E4 $s
play_note $G4 $q
play_note $Gs4 $e
play_note $G4 $e
play_note $E4 $e

# --- MEASURE 3 (High Part) ---
play_note $C4 $dq
play_note $B4 $s
play_note $B4 $s
play_note $B4 $s
play_note $B4 $s
play_note $C5 $q
play_note $G4 $e
play_note $G4 $e

# --- MEASURE 4 (The Chromatic Trill) ---
play_note $G4 $s
play_note $Gs4 $s
play_note $G4 $s
play_note $Fs4 $s
play_note $G4 $q
play_note $E4 $q

# --- MEASURE 5 ---
play_note $Ds4 $e
play_note $E4 $e
play_note $Ds4 $e
play_note $D4 $e
play_note $Ds4 $q
play_note $E4 $e

# --- REPEAT THEME ---
play_note $C4 $q
play_note $E4 $e
play_note $G4 $e
play_note $Gs4 $q
play_note $G4 $e

play_note $E4 $s
play_note $E4 $s
play_note $G4 $q
play_note $Gs4 $e
play_note $G4 $e
play_note $E4 $e

play_note $C4 $dq
play_note $B4 $s
play_note $B4 $s
play_note $B4 $s
play_note $B4 $s
play_note $C5 $q
play_note $G4 $e
play_note $G4 $e

# --- OUTRO STOMP ---
play_note $As4 $e
play_note $G4 $e
play_note $As4 $e
play_note $G4 $e
play_note $As4 $e
play_note $B4 $q
play_note $C5 $q
play_note $C4 $q
play_note $C4 $q

killall speaker-test 2>/dev/null