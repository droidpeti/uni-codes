module HF where

validTime :: Integer -> Integer -> Bool
validTime h m
 | (h <= 23 && h >= 0) && (m <=60 && m >= 0) = True
 | otherwise = False

sumBetween :: Integer -> Integer -> Integer
sumBetween n m
 | n > m = sumBetween m n
 | m > n = n + sumBetween (n+1) m
 | otherwise = n
