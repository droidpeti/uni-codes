module SecondVizsga where
import Data.Maybe (isNothing)

weirdoPow :: Integral a => [a] -> [a]
weirdoPow [] = []
weirdoPow [x] = [x]
weirdoPow (x:y:xs) = (x ^ y) : weirdoPow (y:xs)

replacePunctuation :: String -> Char -> String
replacePunctuation "" _ = ""
replacePunctuation (x:xs) c
 | elem x ",;?.!" = c : replacePunctuation xs c
 | otherwise = x : replacePunctuation xs c


avgWordLength :: String -> Int
avgWordLength "" = 0
avgWordLength w
 | length helperWords == 0 = 0
 | otherwise = sum helperLengths `div` length helperLengths
  where
   helperWords = words w
   helperLengths = map length helperWords

indicesOfNothings :: Integral b => [Maybe a] -> [b]
indicesOfNothings ls = helper ls 0
 where
  helper [] _ = []
  helper (x:xs) index
   | isNothing x = index : helper xs (index+1)
   | otherwise = helper xs (index + 1)

juxtapose :: Eq a => [a] -> [a] -> Maybe [a]
juxtapose [] _ = Nothing
juxtapose (x:xs) (y:ys)
 | x == y = juxtapose xs ys
 | otherwise = Just (x:xs)
juxtapose rest [] = Just rest

strictFilter :: [a -> Bool] -> [a] -> [a]
strictFilter _ [] = []
strictFilter [] ls = ls
strictFilter ps ls = [x | x <- ls, all (\p -> p x) ps]

type Age = Integer
data TreeType = Birch | Oak | Beech | Maple deriving (Eq, Show)
data Tree = Alive TreeType Age | Dead TreeType Age deriving (Eq, Show)

updateTreeAges :: [Tree] -> [Tree]
updateTreeAges [] = []
updateTreeAges (t:ts) = updateTree t : updateTreeAges ts
 where
  updateTree (Alive typ age) = Alive typ (age + 1)
  updateTree (Dead typ age) = Dead typ age

localMin :: Ord a => [a] -> Maybe a
localMin ls = maximumOf (helper ls)
 where
  helper (x:y:z:zs)
   | y < x && y < z = y : helper (y:z:zs)
   | otherwise = helper (y:z:zs)
  helper _ = []
  maximumOf [] = Nothing
  maximumOf xs = Just (maximum xs)
