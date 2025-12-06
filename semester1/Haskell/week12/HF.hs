module HF where

mySpan :: (a -> Bool) -> [a] -> ([a],[a])
mySpan p []     = ([],[])
mySpan p (x:xs)
  | p x       = (x:ys1,ys2)
  | otherwise = ([],x:xs)
  where
    (ys1,ys2) = mySpan p xs

myGroup :: Eq a => [a] -> [[a]]
myGroup [] = []
myGroup ls = xs : myGroup ys
 where
  (xs,ys) = mySpan (==(head ls)) ls

compress :: Eq a => [a] -> [(a, Int)]
compress ls = countGroups (myGroup ls)
  where
    countGroups [] = []
    countGroups (x:xs) = (head x, length x) : countGroups xs

applyOnNeighbours :: (a -> a -> b) -> [a] -> [b]
applyOnNeighbours f (x:y:xs) = f x y : applyOnNeighbours f (y:xs)
applyOnNeighbours _ _        = []

applyOnceOrTwice :: [a] -> (a -> Bool) -> (a -> a) -> [a]
applyOnceOrTwice [] _ _ = []
applyOnceOrTwice (x:xs) p f
  | p x       = f (f x) : applyOnceOrTwice xs p f
  | otherwise = f x     : applyOnceOrTwice xs p f
