module Hetedik where

powersOf2 :: Int -> [Integer]
powersOf2 n = [ 2^i | i <- [0..n]]

oddEven :: Int -> [Bool]
oddEven n = [ i `mod` 2 == 0 | i <- [1..n] ]

myReplicate :: Int -> a -> [a]
myReplicate n x = [ x | i <- [1..n]]

powerOfTwo :: Integer -> Integer
powerOfTwo n = head [ 2 ^ i | i<-[n..]]

exponentOf2 :: Integer -> Integer
exponentOf2 n = head [ i | i <- [0..], 2^i > n]

divisors :: Integer -> [Integer]
divisors n = [ i | i <- [1..n], n `mod` i == 0 ]

isPrime :: Integer -> Bool
isPrime n = length (divisors n) == 2

primesToN :: Integer -> [Integer]
primesToN n = [ i | i <- [1..n], isPrime i]

first :: (a,b) -> a
first (a,b) = a

second :: (a,b) -> b
second (a,b) = b

swap :: (a,b) -> (b,a)
swap (a,b) = (b,a)

scale' :: Integer -> (Integer, Integer) -> (Integer, Integer)
scale' n (a,b) = (a*n, b*n)

time :: [(Int, Int)]
time = [(h,m) | h <- [0..23], m <- [0..59]]

dominoes :: Integer -> [(Integer, Integer)]
dominoes n = [(l,r) | l <- [0..n], r <- [l..n]]
