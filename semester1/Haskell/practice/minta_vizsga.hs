module Vizsga where

first :: (a,b,c) -> a
first (a,_,_) = a

second :: (a,b,c) -> b
second (_,b,_) = b

third :: (a,b,c) -> c
third (_,_,c) = c

points :: Integral a => [(String, a, a)] -> [(String, a)]
points []  = []
points (x:xs)
 | 100 - (second x `div` 2 + third x) > 0 && third x < 100 = (first x, 100 - (second x `div` 2 + third x)) : points xs
 | otherwise = points xs

type Apple = (Bool, Int)
type Tree = [Apple]
type Garden = [Tree]

ryuksApples :: Garden -> Int
ryuksApples [] = 0
ryuksApples (x:xs) = validApples x + ryuksApples xs

validApples :: Tree -> Int
validApples [] = 0
validApples (x:xs)
 | fst x && snd x <= 3 = 1 + validApples xs
 | otherwise = validApples xs

doesContain :: String -> String -> Bool
doesContain [] _ = True
doesContain _ [] = False
doesContain (n:ns) (h:hs)
  | n == h = doesContain ns hs
  | otherwise = doesContain (n:ns) hs

barbie :: [String] -> String
barbie list = helper 1 list
  where
    helper :: Int -> [String] -> String
    helper _ [] = "farmer"
    helper index (c:cs)
      | c == "rozsaszin" = c
      | c /= "fekete" && index `mod` 2 == 0 = c 
      | otherwise = helper (index + 1) cs

firstValid :: [a -> Bool] -> a -> Maybe Int
firstValid p par = helper 0 p par
  where
    helper :: Int -> [a -> Bool] -> a -> Maybe Int
    helper _ [] _ = Nothing
    helper index (p:ps) par
     | p par = Just index
     | otherwise = helper (index + 1) ps par

combineListsIf :: (a -> b -> Bool) -> (a -> b -> c) -> [a] -> [b] -> [c]
combineListsIf _ _ [] _ = []
combineListsIf _ _ _ [] = []
combineListsIf pred func (x:xs) (y:ys)
 | pred x y = func x y : combineListsIf pred func xs ys
 | otherwise = combineListsIf pred func xs ys
