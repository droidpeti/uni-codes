module Gyak where

insertSecond :: a -> [a] -> [a]
insertSecond _ [] = []
insertSecond _ [x] = [x]
insertSecond n (x:xs) = x:n:xs

getIfDiv :: Integer -> [Integer] -> [Integer]
getIfDiv _ [] = []
getIfDiv n (x:xs)
 | x `mod` n == 0 = x : getIfDiv n xs
 | otherwise = getIfDiv n xs

smile :: [Char] -> [Char]
smile "" = ""
smile (x:y:xs)
 | x == ':' && y == '(' = ' ' : smile xs
 | otherwise = x : smile (y:xs) 
