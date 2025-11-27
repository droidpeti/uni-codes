module Kilencedik where

data USTime = AM Int Int | PM Int Int deriving (Show, Eq)

showUSTime :: USTime -> String
showUSTime (AM h m) = (show h) ++ "." ++ (show m) ++ " am"
showUSTime (PM h m) = (show h) ++ "." ++ (show m) ++ " pm"

data CardinalPoint = North | West | South | East deriving (Show, Eq)

numOfDirection :: CardinalPoint -> [CardinalPoint] -> Integer
numOfDirection _ [] = 0
numOfDirection c (x:xs)
 | c == x = 1 + numOfDirection c xs 
 | otherwise = numOfDirection c xs

watering :: Integer -> Integer
watering n = ceiling (fromIntegral n * 0.25 / 1.8)

safehd :: [a] -> Maybe a
safehd [] = Nothing
safehd (x:xs) = Just x

fromMaybe :: Maybe a -> a
fromMaybe (Just x) = x

maybeAdd :: Num a => Maybe a -> Maybe a -> Maybe a
maybeAdd (Just x) (Just y) = Just(x+y)
maybeAdd _ _ = Nothing

elemIndex :: Eq a => a -> [a] -> Maybe Int
elemIndex _ [] = Nothing
elemIndex e (x:xs)
 | e == x = (Just 0)
 | otherwise = maybeAdd (Just 1) (elemIndex e xs)

maybeSum :: Num a => [Maybe a] -> a
maybeSum ((Just x):xs) = x + maybeSum xs
maybeSum (Nothing:xs) = maybeSum xs
maybeSum [] = 0
