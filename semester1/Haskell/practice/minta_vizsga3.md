# Nehezített "Hard Mode" Gyakorló Vizsga

## Előzetes tudnivalók

**Szabályok:**
- A megoldásban legalább az egyik (tetszőleges) függvényt **rekurzívan** kell megadni.
- A feladatokat a kiírásnak megfelelően, az ott megadott típusszignatúrával kell megoldani.
- Beépített függvények (`map`, `filter`, `fold`, `zip`, stb.) használhatók.
- `import` csak a `Data.Char`, `Data.List`, `Data.Maybe` modulokból megengedett.

---

## 1. Csúcsok keresése (2 pont)

Adott egy egész számokból álló lista. Keressük meg azoknak az elemeknek az **indexét** (0-tól indexelve), amelyek szigorúan nagyobbak mindkét közvetlen szomszédjuknál!
(Az első és utolsó elemnek nincs két szomszédja, így ők sosem lehetnek csúcsok).

~~~haskell
mountainPeaks :: [Int] -> [Int]
~~~

**Tesztek:**
~~~haskell
mountainPeaks [] == []
mountainPeaks [1, 2, 1] == [1]
mountainPeaks [1, 5, 2, 8, 3] == [1, 3]
mountainPeaks [1, 2, 3, 4, 5] == []
mountainPeaks [5, 4, 3, 2, 1] == []
mountainPeaks [1, 10, 10, 1] == []
mountainPeaks [0, 10, 2, 5, 20, 3] == [1, 4]
~~~

---

## 2. RLE Tömörítés (Run-Length Encoding) (3 pont)

Írj egy függvényt, ami "tömöríti" a listát úgy, hogy az egymás után következő azonos elemeket egy párban ábrázolja: `(darabszám, elem)`.

~~~haskell
rleEncode :: Eq a => [a] -> [(Int, a)]
~~~

**Tesztek:**
~~~haskell
rleEncode "" == []
rleEncode "a" == [(1,'a')]
rleEncode "aaabbbaaa" == [(3,'a'), (3,'b'), (3,'a')]
rleEncode "abc" == [(1,'a'), (1,'b'), (1,'c')]
rleEncode [1, 1, 1, 2, 3, 3] == [(3,1), (1,2), (2,3)]
rleEncode [True, True, False, True] == [(2,True), (1,False), (1,True)]
~~~

---

## 3. Biztonságos láncolt osztás (2 pont)

Adott egy egész számokból álló lista. Az első elemet osszuk el a másodikkal, az eredményt a harmadikkal, és így tovább (`div` használatával).
- Ha a lista üres, legyen `Nothing`.
- Ha a láncban bármikor nullával osztanánk, az eredmény legyen `Nothing`.
- Egyébként az utolsó osztás eredménye `Just`-ba csomagolva.

~~~haskell
chainDiv :: [Int] -> Maybe Int
~~~

**Tesztek:**
~~~haskell
chainDiv [] == Nothing
chainDiv [10] == Just 10
chainDiv [100, 2, 5] == Just 10  -- (100 / 2) / 5 = 10
chainDiv [100, 0, 5] == Nothing  -- Hiba: nullával osztás
chainDiv [100, 2, 0] == Nothing  -- Hiba: a második lépésben osztanánk nullával
chainDiv [20, 2, 2, 0, 5] == Nothing
chainDiv [120, 2, 3, 4, 5] == Just 1 -- (((120/2)/3)/4)/5 = 1
~~~

---

## 4. Ritka Mátrix Szűrés (2 pont)

Adott egy mátrix (listák listája). A feladat két lépésből áll:
1. Csak azokat a sorokat tartsuk meg, ahol a sor összege **pozitív** (> 0).
2. A megmaradt sorokban minden **negatív** számot cseréljünk le `0`-ra.

~~~haskell
processMatrix :: [[Int]] -> [[Int]]
~~~

**Tesztek:**
~~~haskell
processMatrix [] == []
processMatrix [[1, 2], [-5, 0], [3, -1]] == [[1, 2], [3, 0]]
processMatrix [[-1, -2], [-3, 4]] == [[0, 4]]
processMatrix [[0, 0, 0]] == []
processMatrix [[10, -2], [-10, 20]] == [[10, 0], [0, 20]]
~~~

---

## 5. Leghosszabb csupa-pozitív szakasz (3 pont)

Keresd meg egy listában a leghosszabb olyan összefüggő részsorozat hosszát, amely csak szigorúan pozitív (>0) számokból áll.

~~~haskell
longestPositiveChain :: [Int] -> Int
~~~

**Tesztek:**
~~~haskell
longestPositiveChain [] == 0
longestPositiveChain [1, 2, 3] == 3
longestPositiveChain [-1, -2] == 0
longestPositiveChain [1, 2, -1, 3, 4, 5, -2] == 3
longestPositiveChain [1, -1, 2, 2, -2, 3, 3, 3] == 3
longestPositiveChain [0, 1, 2, 0, 1] == 2
longestPositiveChain [10, 20, 30, -5, 1, 2] == 3
~~~

---

## 6. Robot Navigáció (3 pont)

Egy robotot irányítunk egy 2D síkon. A robotnak van egy pozíciója `(x, y)` és egy iránya, amerre néz.

**Adattípusok (ADT):**
Definiáld a `Direction` típust: `North, East, South, West`. (Eq, Show)
Definiáld a `Command` típust: `TurnLeft, TurnRight, Forward Integer`. (Eq, Show)

A robot a `(0,0)` pontból indul és Észak (`North`) felé néz. Írj egy függvényt, ami parancsok listáját kapja, és visszaadja a robot **végpozícióját** `(x, y)` párként!
*(Észak = Y nő, Dél = Y csökken, Kelet = X nő, Nyugat = X csökken)*.

~~~haskell
robotEndPos :: [Command] -> (Integer, Integer)
~~~

**Tesztek:**
~~~haskell
robotEndPos [] == (0,0)
robotEndPos [Forward 10] == (0, 10)
robotEndPos [TurnRight, Forward 5] == (5, 0)
robotEndPos [Forward 10, TurnLeft, Forward 10] == (-10, 10)
robotEndPos [TurnRight, TurnRight, Forward 5] == (0, -5)
robotEndPos [Forward 5, TurnRight, Forward 5, TurnRight, Forward 5, TurnRight, Forward 5] == (0,0)
~~~
