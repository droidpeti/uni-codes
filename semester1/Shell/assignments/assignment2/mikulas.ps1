param (
    [Parameter(Mandatory=$true)]
    [string]$SablonFajl,

    [Parameter(Mandatory=$true)]
    [string]$AdatbazisFajl
)

if (-not (Test-Path $SablonFajl) -or -not (Test-Path $AdatbazisFajl)) {
    Write-Host "Hiba: Az egyik megadott fájl nem található!" -ForegroundColor Red
    exit
}

$sablonSzoveg = Get-Content -Path $SablonFajl -Raw -Encoding UTF8

$adatok = Get-Content -Path $AdatbazisFajl -Encoding UTF8

foreach ($sor in $adatok) {
    
    $mezok = $sor -split ';'
    
    if ($mezok.Count -lt 3) {
        Write-Warning "Hibás sor formátum: $sor"
        continue
    }

    $nev = $mezok[0].Trim()
    $cim = $mezok[1].Trim()
    $ido = $mezok[2].Trim()

    $keszLevel = $sablonSzoveg -replace "<nev>", $nev `
                               -replace "<cim>", $cim `
                               -replace "<időpont>", $ido

    Write-Output $keszLevel
}
