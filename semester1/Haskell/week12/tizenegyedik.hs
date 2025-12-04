module Tizenegyedik where

myAny :: (a -> Bool) -> [a] -> Bool
myAny _ [] = False
myAny p (x:xs)
 | p x       = True
 | otherwise = myAny p xs

myElem :: Eq a => a -> [a] -> Bool
myElem a xs = myAny (\x -> x == a) xs

myZipWith :: (a -> b -> c) -> [a] -> [b] -> [c]
myZipWith _ [] _ = []
myZipWith _ _ [] = []
myZipWith f (x:xs) (y:ys) = (f x y) : myZipWith f xs ys

filterEvens :: Integral a => [a] -> [a]
filterEvens = filter even

myGroup :: Eq a => [a] -> [[a]]
myGroup [] = []
myGroup ls = xs : myGroup ys
 where
  (xs,ys) = span (==(head ls)) ls

notNull :: [a] -> Bool
notNull = not . null
