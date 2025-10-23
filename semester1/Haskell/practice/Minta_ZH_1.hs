module ZH where

import Data.Char

doubleTriple :: [a] -> [a]
doubleTriple list
 | length list == 1 = [list !! 0] ++ [list !! 0] ++ [list !! 0]
 | length list == 2 = [list !! 0] ++ [list !! 0] ++ [list !! 1] ++ [list !! 1]
 | otherwise = list

lengthOfShorter :: [a] -> [b] -> Integer
lengthOfShorter [] _ = 0
lengthOfShorter _ [] = 0
lengthOfShorter (_:xs) (_:ys) = 1 + lengthOfShorter xs ys

compressLetters :: String -> String
compressLetters "" = ""
compressLetters [x] = [x]
compressLetters (x:y:xs)
 | isLower x && x == y = compressLetters ((toUpper x ):xs)
 | otherwise = x : compressLetters (y:xs)

