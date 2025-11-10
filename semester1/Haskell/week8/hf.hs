module HF where

slice :: [Int] -> [a] -> [[a]]
slice [] _ = []
slice (n:ns) xs = (take n xs) : (slice ns (drop n xs))

every :: Int -> [a] -> [a]
every _ [] = []
every n (x:xs)
 | n <= 0 = x:xs
 | n == 1 = x:xs
 | otherwise = x : (every n (drop (n-1) xs))