module Negyedik where

div6 :: Int -> Int
div6 a
 | (a `mod` 7 == 0) = a
 | otherwise = div6 (a+6)

test :: Int -> Int
test x = x

descending :: Integer -> [Integer]
descending x = [min x (-x).. max x (-x)]

divByN :: Integer -> [Integer]
divByN n
 | n > 0 = [0, n..]
 | otherwise = []

ithInSeq :: Integer -> Integer -> Int -> Integer
ithInSeq first second i
 | i < 0 = 0
 | otherwise = [first, second..] !! (i-1)

nthLetter :: Int -> Bool -> Char
nthLetter i isCapital 
 | isCapital = ['A' .. 'Z'] !! (i-1)
 | otherwise = ['a' .. 'z'] !! (i-1)

-- [Int] szám lista
-- [Char] = String
-- [Bool]
-- [1,2,3] jó lista
-- [1,2,'c',True] nem jó lista
-- [] üres lista
