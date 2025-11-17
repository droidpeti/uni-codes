module HF where

monotonousSeq :: Int -> [Int]
monotonousSeq num
 | num <= 0 = []
 | otherwise = monotonousSeq (num-1) ++ [ num | i <- [1..num] ]

zip2 :: [a] -> [b] -> [(a, b)]
zip2 (x:xs) (y:ys) = (x, y) : zip2 xs ys
zip2 _ _ = []
