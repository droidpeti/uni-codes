module HF where

evenSum :: Integer -> Integer -> Integer -> Bool
evenSum x y z = ((x+y+z) `mod` 2 == 0)

indexOfArg :: Integer -> Integer -> Integer -> Integer
indexOfArg x y z
 | x == 0 = 1
 | y == 0 = 2
 | z == 0 = 3
 | otherwise = -1
