module Elso where

inc :: Int -> Int
inc x = x + 1

multAdd :: Int -> Int -> Int
multAdd n m  = n * m + n + m

not2 :: Bool -> Bool
not2 b = 
    if b == True
    then False
    else True

(|:|) :: Bool -> Bool -> Bool
(|:|) b c =
    if (b == False) && (c == False)
    then False
    else True

xor :: Bool -> Bool -> Bool
xor b c =
    not (b == c)

(-->) :: Bool -> Bool -> Bool
(-->) True False = False
(-->) _ _ = True

isA :: Char -> Bool
isA c =
    c == 'A' || c == 'a'

replaceNewline :: Char -> Char
replaceNewline c =
    if c == '\n' then ' '
    else c

isDig :: Char -> Bool
isDig '0' = True
isDig '1' = True
isDig '2' = True
isDig '3' = True
isDig '4' = True
isDig '5' = True
isDig '6' = True
isDig '7' = True
isDig '8' = True
isDig '9' = True
isDig _ = False
