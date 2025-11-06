module Hatodik where

import Data.Char

myRepeat :: a -> [a]
myRepeat a = a : myRepeat a

infixr 5 +:+
(+:+) :: [a] -> [a] -> [a]
(+:+) [] t = t
(+:+) (x:xs) t = x : (+:+) xs t

myEnumFrom :: Integer -> [Integer]
myEnumFrom n = n : myEnumFrom (n+1)

myEnumFromTo :: Integer -> Integer -> [Integer]
myEnumFromTo n m
 | n > m = []
 | otherwise = n : myEnumFromTo (n+1) m

myEnumFromThen :: Integer -> Integer -> [Integer]
myEnumFromThen n m = n : myEnumFromThen m (m+m-n)

myEnumFromThenTo :: Integer -> Integer -> Integer -> [Integer]
myEnumFromThenTo n d m
 | n > m = []
 | otherwise = n : myEnumFromThenTo d (d+d-n) m

elimElem :: Eq a => a -> [a] -> [a]
elimElem _ [] = []
elimElem n (x:xs)
 | x == n = elimElem n xs
 | otherwise = x : elimElem n xs

runs :: Int -> [a] -> [[a]]
runs _ [] = []
runs n arr = take n arr : runs n (drop n arr)
