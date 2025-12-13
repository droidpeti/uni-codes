module ThirdVizsga where

mountainPeaks :: [Int] -> [Int]
mountainPeaks xs = helper xs 0
    where
        helper :: [Int] -> Int -> [Int]
        helper (x:y:z:zs) index
         | y > x && y > z = (index+1) : helper (y:z:zs) (index + 1)
         | otherwise = helper (y:z:zs) (index + 1)
        helper _ _ = []

rleEncode :: Eq a => [a] -> [(Int, a)]
rleEncode [] = []
rleEncode (l:ls) = (helper (l:ls) l 0,l) : rleEncode (drop (helper (l:ls) l 0) (l:ls))
    where
        helper :: Eq a => [a] -> a -> Int -> Int
        helper (x:xs) target streak
         | x == target = helper xs target streak + 1
         | otherwise = 0
        helper _ _ _ = 0

chainDiv :: [Int] -> Maybe Int
chainDiv [] = Nothing
chainDiv (x:xs) = helper xs x
 where
    helper :: [Int] -> Int -> Maybe Int
    helper [] val = Just val
    helper (y:ys) val
     | y == 0 = Nothing
     | otherwise = helper ys (val `div` y)

processMatrix :: [[Int]] -> [[Int]]
processMatrix [] = []
processMatrix (l:ls)
 | sum l > 0 = replaceNegative l : processMatrix ls
 | otherwise = processMatrix ls
 where
    replaceNegative :: [Int] -> [Int]
    replaceNegative [] = []
    replaceNegative (x:xs)
     | x < 0 = 0 : replaceNegative xs
     | otherwise = x : replaceNegative xs

longestPositiveChain :: [Int] -> Int
longestPositiveChain [] = 0
longestPositiveChain xs = maximum (positiveStreaks xs 0)
    where 
        positiveStreaks :: [Int] -> Int -> [Int]
        positiveStreaks [] streak = [streak]
        positiveStreaks (x:xs) streak
         | x <= 0 = streak : positiveStreaks xs 0
         | otherwise = positiveStreaks xs (streak+1)

data Direction = North | East | South | West deriving (Eq, Show)
data Command = TurnLeft | TurnRight | Forward Integer

robotEndPos :: [Command] -> (Integer, Integer)
robotEndPos [] = (0,0)
robotEndPos cmds = processSteps cmds North (0,0)
    where
        processSteps :: [Command] -> Direction -> (Integer, Integer) -> (Integer, Integer)
        processSteps [] _ pos = pos
        processSteps (c:cs) d (x,y) = processSteps cs (fst (step c d (x,y))) (snd (step c d (x,y)))

        step :: Command -> Direction -> (Integer, Integer) -> (Direction, (Integer, Integer))
        step TurnLeft d (x,y) = (dirToLeft d, (x,y))
        step TurnRight d (x,y) = (dirToRight d, (x,y))
        step (Forward dist) d p = (d, moveForward dist d p)
        
        dirToLeft :: Direction -> Direction
        dirToLeft North = West
        dirToLeft West = South
        dirToLeft South = East
        dirToLeft East = North

        dirToRight :: Direction -> Direction
        dirToRight North = East
        dirToRight East = South
        dirToRight South = West
        dirToRight West = North

        moveForward :: Integer -> Direction -> (Integer, Integer) -> (Integer, Integer)
        moveForward dist North (x, y) = (x, y + dist)
        moveForward dist East (x, y) = (x + dist, y)
        moveForward dist South (x, y) = (x, y - dist)
        moveForward dist West (x, y) = (x - dist, y)
