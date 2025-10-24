#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 <filename>"
    echo "Example: $0 numbers.txt"
    exit 1
fi

FILE=$1

if [ ! -f "$FILE" ]; then
    echo "Error: File not found: '$FILE'"
    exit 1
fi

is_valid_number() {
    local number=$1
    local base=$2

    case $base in
        2)
            if [[ "$number" =~ [^01] ]]; then
                return 1
            fi
            ;;
        8)
            if [[ "$number" =~ [^0-7] ]]; then
                return 1
            fi
            ;;
        10)
            if [[ "$number" =~ [^0-9] ]]; then
                return 1
            fi
            ;;
        16)
            if [[ "$number" =~ [^0-9a-fA-F] ]]; then
                return 1
            fi
            ;;
        *)
            echo "Error: Unsupported base '$base'" >&2
            return 1
            ;;
    esac

    return 0
}

while IFS= read -r line; do
    
    if [[ -z "$line" || "$line" == \#* ]]; then
        continue
    fi

    IFS=',' read -ra parts <<< "$line"

    from_base=${parts[0]}
    to_base=${parts[1]}
    
    numbers_to_convert=("${parts[@]:2}")

    line_is_valid=true
    invalid_num=""

    for num in "${numbers_to_convert[@]}"; do
        if ! is_valid_number "$num" "$from_base"; then
            line_is_valid=false
            invalid_num=$num
            break
        fi
    done

    if [ "$line_is_valid" = true ]; then
        converted_results=()

        for num in "${numbers_to_convert[@]}"; do
            num_upper=$(echo "$num" | tr 'a-f' 'A-F')
            
            converted=$(echo "ibase=$from_base; obase=$to_base; $num_upper" | bc)
            converted_results+=("$converted")
        done

        echo "OK:    $line  ->  (Base $to_base): ${converted_results[*]}"
    
    else
        echo "ERROR: $line  ->  Invalid number '$invalid_num' for base $from_base." >&2
    fi

done < "$FILE"

echo "Script finished."
