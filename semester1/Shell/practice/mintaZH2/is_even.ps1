[int]$Num = Read-Host "Please input a whole, negative number"
if($Num -gt 0){
    Write-Host "$Num is not negative, exiting..."
    return
}
[int]$Sqr = $Num * $Num
if($Sqr % 2 -eq 0){
    Write-Host "$Sqr is even!"
}
else{
    Write-Host "$Sqr is odd!"
}
