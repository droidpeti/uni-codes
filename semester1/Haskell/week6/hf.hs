module HF where

myTake :: Int -> [a] -> [a]
myTake 0 _ = []
myTake _ [] = []
myTake n (x:xs) = x : myTake (n - 1) xs

myElem :: Eq a => a -> [a] -> Bool
myElem _ [] = False
myElem needle (x:xs)
 | needle == x = True
 | otherwise = myElem needle xs

myReplicate :: Int -> a -> [a]
myReplicate n e
 | n <= 0 = []
 | n == 1 = [e]
 | otherwise = e : myReplicate (n-1) e
