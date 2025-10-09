module HF where

myLast :: [a] -> a
myLast list = list !! (length list -1)

addCertainNumbers :: Int -> Int -> Int -> Int
addCertainNumbers start end step = sum [start, start+step .. end]
