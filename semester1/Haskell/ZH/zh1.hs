module Zh where

sumFirst3 :: [Integer] -> Integer
sumFirst3 [] = 0
sumFirst3 [x] = 0
sumFirst3 [x,y] = 0
sumFirst3 (x:y:z:_) = x+y+z

doubleIfEven :: [Integer] -> [Integer]
doubleIfEven [] = []
doubleIfEven (x:xs)
 | x `mod` 2 == 0 = (x*2) : doubleIfEven xs
 | otherwise = x : doubleIfEven xs 

oddNeighbourProd :: [Integer] -> [Integer]
oddNeighbourProd [] = []
oddNeighbourProd [x] = []
oddNeighbourProd (x:y:xs)
 | x `mod` 2 == 1 && y `mod` 2 == 1 = (x*y) : oddNeighbourProd (y:xs)
 | otherwise = oddNeighbourProd (y:xs)
