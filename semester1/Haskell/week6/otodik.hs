module Otodik where

import Data.Char (toUpper)

isEmpty :: [a] -> Bool
isEmpty [] = True
isEmpty _ = False

isSingleton :: [a] -> Bool
isSingleton [x] = True
isSingleton _ = False

startsWithOne :: [Integer] -> Bool
startsWithOne (1:_) = True
startsWithOne _ = False

hd :: [a] -> a
hd (x:_) = x

toUpperFirst :: String -> String
toUpperFirst [] = []
toUpperFirst (x:xs) = toUpper x : xs 

len :: [a] -> Int
len [] = 0
len (x:xs) = 1 + len xs

sum2 :: Num a => [a] -> a
sum2 [] = 0
sum2 (x:xs) = x + sum2 xs

myLast :: [a] -> a
myLast [x] = x
myLast (x:xs) = myLast xs

myMinimum :: [Integer] -> Integer
myMinimum [x] = x
myMinimum (x:xs)
 | x < min = x
 | otherwise = min
 where
 min = myMinimum xs

myDrop :: Int -> [a] -> [a]
myDrop i arr@(_:xs)
 | i <= 0 = arr
 | otherwise = myDrop (i-1) xs
