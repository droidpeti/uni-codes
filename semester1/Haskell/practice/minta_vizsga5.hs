module FifthVizsga where

vowelCount :: String -> Int
vowelCount _ = 0
-- Pl: vowelCount "Apple" == 2
-- Pl: vowelCount "Haskell" == 2

endsWithChar :: Char -> [String] -> [String]
endsWithChar _ _ = []
-- Pl: endsWithChar 'k' ["ablak", "korte", "szek"] == ["ablak", "szek"]

hasZero :: [Int] -> Bool
hasZero _ = True
-- Pl: hasZero [1, 2, 3] == False
-- Pl: hasZero [1, 0, 5] == True

insertAt :: Int -> a -> [a] -> [a]
insertAt _ _ _ = []
-- Pl: insertAt 1 'X' "abc" == "aXbc"
-- Pl: insertAt 100 'X' "abc" == "abcX"

mergeSorted :: Ord a => [a] -> [a] -> [a]
mergeSorted _ _ = []
-- Pl: mergeSorted [1, 3, 5] [2, 4, 6] == [1, 2, 3, 4, 5, 6]
