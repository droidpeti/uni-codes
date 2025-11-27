module Tizedik where

data Pair a b = P a b deriving (Eq)

instance (Show a, Show b) => Show (Pair a b) where
 show (P a b) = "(" ++ (show a) ++ "," ++ (show b) ++ ")"

data List a = Nil | Cons a (List a) deriving (Eq) 
infixr 5 `Cons`

instance (Show a) => Show (List a) where
 show Nil = "<>"
 show l = myShowList l 

myShowList :: (Show a) => List a -> String
myShowList ls = '<' : showListH ls
 where
  showListH Nil = ">"
  showListH (Cons x Nil) = (show x) ++ ">"
  showListH (Cons x xs) = (show x) ++ (';' : showListH xs) 


consLength :: (List a) -> Int
consLength Nil = 0
consLength (Cons x xs) = 1 + consLength xs

myReverse :: [a] -> [a]
myReverse ls = myReverseH ls []
 where 
  myReverseH :: [a] -> [a] -> [a]
  myReverseH [] acc = acc
  myReverseH (x:xs) acc = myReverseH xs (x:acc)

consSum :: Num a => List a -> a
consSum ls = consSumH ls 0
 where
  consSumH :: Num a => List a -> a -> a
  consSumH Nil acc = acc
  consSumH (Cons x xs) acc = consSumH xs (acc+x)