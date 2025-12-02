[int]$sum = 0
[int]$prod = 1

[int]$count = Read-Host "Please enter how many numbers you will input"
$i = 0

while($i -lt $count){
    [int]$num = Read-Host "Please enter number $i"
    if($num % 2 -eq 0){
        $sum = $sum + $num
    }
    else{
        $prod = $prod * $num
    }
    $i = $i + 1
}

Write-Host "Sum of even numbers is: $sum"
Write-Host "Product of odd numbers is: $prod"
