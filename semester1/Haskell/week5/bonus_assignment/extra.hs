module Extra where

closeSection :: Int -> Int -> (Int, Int)
closeSection x y
 | x == y || ((max x y) -1) == (min x y) = (x,y)
 | otherwise = closeSection ((min x y) + 1) ((max x y) -1)

multiply :: Integer -> Integer -> Integer
multiply x y
 | y <= 0 = 0
 | otherwise = x + multiply x (y -1)

mountain :: Integer -> [Integer]
mountain x
 | x <= 0 = []
 | otherwise = [1..x] ++ (reverse [1..(x-1)])
