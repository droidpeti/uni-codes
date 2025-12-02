function Show-Menu {
    function Palindrome { 
        [string]$word = Read-Host "Please enter a word"
        $reverse = $word -split ""
        [array]::Reverse($reverse)
        $reverse = $reverse -join ''

        if($word -eq $reverse){
            Write-Host "$word is a palindrome!"
        }
        else{
            Write-Host "$word is not a palindrome!"
        }
        
    }
    function Cube {
          [float]$num = Read-Host "Please enter a number"
          [float]$cube = $num * $num * $num
          Write-Host "$num^3 = $cube"
          return $cube
    }
    function File_Exists { 
        [string]$path = Read-Host "Please enter the file's name you are looking for"
        if([System.IO.File]::Exists($path)){
            Write-Host "$path file exists!"
        }
        else{
            Write-Host "Couldn't find $path"
        }
    }

    do {
        Write-Host "`n--- MENU ---"
        Write-Host "1) Palindrome"
        Write-Host "2) Cube"
        Write-Host "3) File Exists"
        Write-Host "4) Quit"
        $choice = Read-Host "Choose"

        switch ($choice) {
            '1' { Palindrome }
            '2' { Cube }
            '3' { File_Exists }
            '4' { 
                Write-Host "Bye" 
                return
            }
            default { Write-Host "Invalid option" }
        }
    } until ($false)
}

Show-Menu
