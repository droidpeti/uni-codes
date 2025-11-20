module HF where

distantPairs :: [(Integer,Integer)] -> Int
distantPairs [] = 0
distantPairs arr = length [ (i,j) | (i,j) <- arr, abs (i-j) >= 2 ]

excludeSquares :: [Integer]
excludeSquares = [ i | i <- [1..],  round (sqrt (fromIntegral i)) ^ 2 /= i ]

data Month = Jan | Feb | Mar | Apr | May | Jun | Jul | Aug | Sep | Okt | Nov | Dec deriving(Show, Eq, Enum)

nextMonth :: Month -> Month
nextMonth Dec = Jan
nextMonth m = succ m

isWinter :: Month -> Bool
isWinter Dec = True
isWinter Jan = True
isWinter Feb = True
isWinter _ = False
