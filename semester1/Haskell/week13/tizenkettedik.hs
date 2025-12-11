module Hajtogatas where

-- sum ls = fold (+) 0 ls
-- product ls = fold (*) 1 ls

length2 :: [a] -> Int
length2 = foldr (\x acc -> 1 + acc) 0

myAnd :: [Bool] -> Bool
myAnd ls = foldl (&&) True ls

myMaximum :: Ord a => [a] -> a
myMaximum (x:xs) = foldl max x xs


