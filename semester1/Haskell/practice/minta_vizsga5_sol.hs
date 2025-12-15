module TrainExam where

import Data.Char (toLower)

-- 1. vowelCount (2p)
-- TIPP: elem vizsgálat egy listában.
vowelCount :: String -> Int
vowelCount str = length (filter (\c -> toLower c `elem` "aeiou") str)

-- 2. endsWithChar (2p)
-- TIPP: A string egy lista, a 'last' adja az utolsót. Vigyázz az üres stringre!
endsWithChar :: Char -> [String] -> [String]
endsWithChar c wordsList = filter checkEnd wordsList
  where
    checkEnd [] = False
    checkEnd w  = last w == c

-- 3. hasZero (2p)
-- TIPP: Az elem függvény pont erre való.
hasZero :: [Int] -> Bool
hasZero list = 0 `elem` list
-- Vagy: any (==0) list

-- 4. insertAt (3p)
-- TIPP: splitAt használata a legelegánsabb, vagy rekurzió.
insertAt :: Int -> a -> [a] -> [a]
insertAt i val list
    | i <= 0    = val : list
    | otherwise = let (prefix, suffix) = splitAt i list
                  in prefix ++ [val] ++ suffix

-- 5. mergeSorted (3p)
-- TIPP: Klasszikus rekurzió két fejelemmel.
mergeSorted :: Ord a => [a] -> [a] -> [a]
mergeSorted [] ys = ys
mergeSorted xs [] = xs
mergeSorted (x:xs) (y:ys)
    | x <= y    = x : mergeSorted xs (y:ys)
    | otherwise = y : mergeSorted (x:xs) ys

-- 6. LogMessage (3p)
-- TIPP: Data definíció és mintaillesztés.

-- 1. Definíció
data LogMessage 
    = Info String 
    | Warning String 
    | Error Int String
    deriving (Show, Eq)

-- 2. isCritical
isCritical :: LogMessage -> Bool
isCritical (Error code _) = code > 500
isCritical _              = False

-- 3. getMessages
getMessages :: [LogMessage] -> [String]
getMessages logs = map extract logs
  where
    extract (Info msg)      = msg
    extract (Warning msg)   = msg
    extract (Error _ msg)   = msg