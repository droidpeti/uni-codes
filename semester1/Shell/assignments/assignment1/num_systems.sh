#!/bin/bash

if [ "$#" -eq 0 ]; then
    echo "Please provide a filename to read."
    echo "Usage: $0 numbers.txt"
    exit 1
fi

FILE=$1

if [ ! -f "$FILE" ]; then
    echo "Error: The file '$FILE' does not exist."
    exit 1
fi

echo "--- Processing file: $FILE ---"

while read line; do

    if [ -z "$line" ] || [[ "$line" == \#* ]]; then
        continue
    fi

    from_base=$(echo "$line" | cut -d',' -f1)
    to_base=$(echo "$line" | cut -d',' -f2)
    
    line_is_valid=true
    invalid_num_found=""
    total_fields=$(echo "$line" | tr ',' '\n' | wc -l)

    for i in $(seq 3 $total_fields); do
        num=$(echo "$line" | cut -d',' -f$i)

        invalid_chars=""

        if [ "$from_base" -eq 2 ]; then
            invalid_chars=$(echo "$num" | tr -d '01')
        elif [ "$from_base" -eq 8 ]; then
            invalid_chars=$(echo "$num" | tr -d '0-7')
        elif [ "$from_base" -eq 10 ]; then
            invalid_chars=$(echo "$num" | tr -d '0-9')
        elif [ "$from_base" -eq 16 ]; then
            invalid_chars=$(echo "$num" | tr -d '0-9a-fA-F')
        else
            echo "ERROR: Line '$line' has unknown base '$from_base'"
            line_is_valid=false
            break
        fi

        if [ -n "$invalid_chars" ]; then
            line_is_valid=false
            invalid_num_found=$num
            break
        fi
    done

    if [ "$line_is_valid" = true ]; then
        
        result_string=""

        for i in $(seq 3 $total_fields); do
            num=$(echo "$line" | cut -d',' -f$i)

            num_upper=$(echo "$num" | tr 'a-f' 'A-F')
            
            converted=$(echo "ibase=$from_base; obase=$to_base; $num_upper" | bc)

            result_string="$result_string $converted"
        done
        
        echo "OK:    $line -> (Base $to_base):$result_string"

    else
        echo "ERROR: $line -> Invalid number '$invalid_num_found' for base $from_base."
    fi

done < "$FILE"

echo "--- Script finished ---"
