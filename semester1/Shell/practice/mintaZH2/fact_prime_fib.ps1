function fact {
    param(
        [int]$num
    )
    if ($num -le 1) {
        return 1
    }
    return $num * (fact ($num - 1)) 
}

function is_prime {
    param(
        [int]$num
    )

    if ($num -le 1) {
        Write-Host "$num is not prime!"
        return
    }
    
    if ($num -eq 2) {
        Write-Host "$num is prime!"
        return
    }

    if ($num % 2 -eq 0) {
        Write-Host "$num is not prime!"
        return
    }

    [int]$i = 3
    [int]$sqrt_num = [math]::Sqrt($num)
    
    while ($i -le $sqrt_num) {
        if ($num % $i -eq 0) {
            Write-Host "$num is not a prime!"
            return
        }
        $i = $i + 2
    }
    
    Write-Host "$num is a prime!"
}

function fib {
    param(
        [int]$num
    )

    if ($num -le 1) {
        return $num
    }

    return (fib ($num - 1)) + (fib ($num - 2))
}

[int]$num = Read-Host "Please input a whole, positive number"

if ($num -lt 0) {
    Write-Host "$num is not positive, exiting..."
    return
}

[int]$fact = fact $num
[int]$fib = fib $num

Write-Host "The factorial of $num is $fact"

is_prime $num

Write-Host "The #$num fibonacci number is: $fib"
