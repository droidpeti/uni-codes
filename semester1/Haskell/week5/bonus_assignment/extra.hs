module Extra where

closeSection :: Int -> Int -> (Int, Int)
closeSection x y
 | x == y || ((max x y) -1) == (min x y)
 | otherwise closeSection 
