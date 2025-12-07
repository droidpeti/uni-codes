module Vizsga where

first :: (a,b,c) -> a
first (a,_,_) = a

second :: (a,b,c) -> b
second (_,b,_) = b

third :: (a,b,c) -> c
third (_,_,c) = c

points :: Integral a => [(String, a, a)] -> [(String, a)]
points []  = []
points (x:xs)
 | 100 - (second x `div` 2 + third x) > 0 && third x < 100 = (first x, 100 - (second x `div` 2 + third x)) : points xs
 | otherwise = points xs

type Apple = (Bool, Int)
type Tree = [Apple]
type Garden = [Tree]

ryuksApples :: Garden -> Int
ryuksApples [] = 0
ryuksApples (x:xs) = validApples x + ryuksApples xs

validApples :: Tree -> Int
validApples [] = 0
validApples (x:xs)
 | fst x && snd x <= 3 = 1 + validApples xs
 | otherwise = validApples xs


