module HF where

data List a = Nil | Cons a (List a) deriving (Show, Eq)
infixr 5 `Cons`

maybeContains :: Eq a => [Maybe a] -> a -> Bool
maybeContains [] _ = False
maybeContains (x:xs) nail
 | Just nail == x = True
 | otherwise = maybeContains xs nail

myTakeWhile :: (a -> Bool) -> [a] -> [a]
myTakeWhile _ [] = []
myTakeWhile cond (x:xs)
 | cond x =  x : myTakeWhile cond xs
 | otherwise = []

consTakeWhile :: (a -> Bool) -> List a -> List a
consTakeWhile _ Nil = Nil
consTakeWhile cond (Cons x xs)
 | cond x = Cons x (consTakeWhile cond xs)
 | otherwise = Nil

myAny :: (a -> Bool) -> [a] -> Bool
myAny _ [] = False
myAny cond (x:xs)
 | cond x = True
 | otherwise = myAny cond xs

consAny :: (a -> Bool) -> List a -> Bool
consAny _ Nil = False
consAny cond (Cons x xs)
 | cond x = True
 | otherwise = consAny cond xs
