module Masodik where

secondsInLeapYear :: Integer
secondsInLeapYear = 366*3600*24

double :: Integer -> Integer
double a = a*2

isEven :: Integer -> Bool
isEven a = (a `mod` 2 == 0)

isOdd :: Integer -> Bool
isOdd a = not (isEven a)

divides :: Integer -> Integer -> Bool
divides a b = b `mod` a == 0

triangleSides :: Integer -> Integer -> Integer -> Bool
triangleSides a b c = (a + b > c) && (a + c > b) && (c + b > a)

isLeapYear :: Integer -> Bool
isLeapYear year = ((year `mod` 4 == 0) && year `mod` 100 /= 0) || (year `mod` 400 == 0)

oneIfZero :: Int -> Int
oneIfZero 0 = 1
oneIfZero n = n

isZero :: Int -> Bool
isZero x = x == 0

mul3 :: Int -> Int -> Int
mul3 x y = (x*y) `mod` 3

nextDay :: Integer -> Integer
nextDay day = (day+1) `mod` 7

fact :: Int -> Integer
fact n
 | n > 0 = toInteger n*fact(n-1)
 | otherwise = 1

oneIfLessThanFour :: Int -> Int
oneIfLessThanFour x 
 | x < 4 = 1
 | otherwise = x