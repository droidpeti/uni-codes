module Harmadik where
import Data.Char (isUpper, isLower, toUpper, toLower)

sphereVolume :: Double -> Double
sphereVolume r = 4*r^3*pi/3

f :: Integer -> Integer -> Integer
f 0 x = x
f x 0 = x
f _ _ = 0

min :: Int -> Int -> Int
min x y
 | x >= y = y
 | otherwise = x

myabs :: Integer -> Integer
myabs x
 | x < 0 = negate x
 | otherwise = x

sign :: Integer -> Integer
sign x
 | x > 0 = 1
 | x < 0 = -1
 | otherwise = 0

swapUpperLower :: Char -> Char
swapUpperLower c
 | isLower c = toUpper c
 | otherwise = toLower c

fact :: Integer -> Integer
fact 0 = 1
fact n
 | n > 0 = n * fact(n-1)

sumTo :: Integer -> Integer
sumTo n
 | n > 0 = n + sumTo(n-1)
 | otherwise = 0
