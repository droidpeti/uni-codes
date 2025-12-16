module Vizsga where

import Data.Char

doubleLow :: String -> Bool
doubleLow [] = False
doubleLow [x] = False
doubleLow (x:y:ys)
 | isLower x && isLower y = True
 | otherwise = doubleLow (y:ys)

vowelEcho :: String -> String
vowelEcho [] = []
vowelEcho (x:xs)
 | elem x "aeiou" = [x,x] ++ vowelEcho xs
 | otherwise = x : vowelEcho xs

swapFirst2 :: [[a]] -> [[a]]
swapFirst2 [] = []
swapFirst2 (x:xs) = helper x : swapFirst2 xs
    where
        helper :: [a] -> [a]
        helper [] = []
        helper [x] = [x]
        helper (x:y:ys) = y : x : ys

addMaybeTuple :: Num a => [(Maybe a, Maybe a)] -> [Maybe a]
addMaybeTuple [] = []
addMaybeTuple (x:xs) = helper x : addMaybeTuple xs
    where
        helper :: Num a => (Maybe a, Maybe a) -> Maybe a
        helper (Nothing, _) = Nothing
        helper (_,Nothing) = Nothing
        helper (Just x, Just y) = Just (x + y)

jointFilter :: (a -> Bool) -> [a] -> [a] -> [(a,a)]
jointFilter _ [] _ = []
jointFilter _ _ [] = []
jointFilter p (x:xs) (y:ys)
 | p x && p y = (x,y) : jointFilter p xs ys
 | otherwise = jointFilter p xs ys

applyIfIncreases :: Ord a => (a -> a) -> [a] -> [a]
applyIfIncreases p [] = []
applyIfIncreases p (x:xs)
 | p x > x = (p x) : applyIfIncreases p xs
 | otherwise = x : applyIfIncreases p xs

data Temperature = Night Double | Daytime Double deriving (Show,Eq,Ord)

temp :: Temperature -> Double
temp (Night x) = x
temp (Daytime x) = x

time :: Temperature -> String
time (Night _) = "Night"
time (Daytime _) = "Daytime"

lowestDaytimeTemp :: [Temperature] -> Maybe Double
lowestDaytimeTemp [] = Nothing
lowestDaytimeTemp xs
 | time (getFirstDaytime xs) == "Night" = Nothing
lowestDaytimeTemp xs = helper xs (temp (getFirstDaytime xs))
    where
        helper :: [Temperature] -> Double -> Maybe Double
        helper [] min = Just min
        helper (x:xs) min
         | (temp x) <= min && (time x) == "Daytime" = helper xs (temp x)
         | otherwise = helper xs min

getFirstDaytime :: [Temperature] -> Temperature
getFirstDaytime [] = Night 0
getFirstDaytime (x:xs)
 | (time x) == "Daytime" = x
 | otherwise = getFirstDaytime xs

