module FifthVizsga where

import Data.Char

vowelCount :: String -> Int
vowelCount [] = 0
vowelCount (x:xs)
 | elem (toLower x) "aeiou" = 1 + (vowelCount xs)
 | otherwise = vowelCount xs

endsWithChar :: Char -> [String] -> [String]
endsWithChar _ [] = []
endsWithChar c (x:xs)
 | c == head (reverse x) = x : endsWithChar c xs
 | otherwise = endsWithChar c xs

hasZero :: [Int] -> Bool
hasZero [] = False
hasZero (x:xs)
 | x == 0 = True
 | otherwise = hasZero xs

insertAt :: Int -> a -> [a] -> [a]
insertAt 0 x [] = [x]
insertAt _ _ [] = []
insertAt id c ls
 | length ls <= id = ls ++ [c]
insertAt id c ls = helper id 0 c ls
    where
        helper :: Int -> Int -> a -> [a] -> [a]
        helper _ _ _ [] = []
        helper id i c (x:xs)
         | id == i = c : x : helper id (i+1) c xs
         | otherwise = x : helper id (i+1) c xs 

mergeSorted :: Ord a => [a] -> [a] -> [a]
mergeSorted [] ys = ys
mergeSorted xs [] = xs
mergeSorted (x:xs) (y:ys)
    | x <= y    = x : mergeSorted xs (y:ys)
    | otherwise = y : mergeSorted (x:xs) ys

