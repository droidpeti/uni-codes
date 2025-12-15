module FourthVizsga where

parosOsszeg :: [Int] -> Int
parosOsszeg [] = 0
parosOsszeg (x:xs)
 | even x = x + parosOsszeg xs
 | otherwise = parosOsszeg xs

monogram :: String -> [Char]
monogram str = go (words str)
    where 
        go :: [String] -> String
        go [] = []
        go (w:ws) = head w : '.' : go ws

safeDiv :: Int -> Int -> Maybe Int
safeDiv _ 0 = Nothing
safeDiv x y = Just (x `div` y)

compress :: Eq a => [a] -> [a]
compress [] = []
compress [x] = [x]
compress (x:y:ys)
 | x == y = compress (y:ys)
 | otherwise = x : compress (y:ys)

rank :: String -> [(String, Int)] -> Maybe Int
rank _ [] = Nothing
rank target ls = helper target ls 1
    where
        helper :: String -> [(String, Int)] -> Int -> Maybe Int
        helper _ [] _ = Nothing
        helper target ((name,score):xs) id
         | target == name = Just id
         | otherwise = helper target xs (id+1)

transform :: [(a -> Bool, a -> a)] -> [a] -> [a]
transform [] ls = ls
transform _ [] = []
transform fs (x:xs)
 | helper fs x 0 /= -1 = (snd (fs !! (helper fs x 0)) x) : transform fs xs
 | otherwise = x : transform fs xs
    where
        helper :: [(a -> Bool, a -> a)] -> a -> Int -> Int
        helper [] x _ = -1
        helper ((p,f):fs) x index
         | p x = index
         | otherwise = helper fs x (index+1)

common :: Eq a => [a] -> [a] -> [a]
common _ [] = []
common [] _ = []
common (x:xs) ls
 | contains x ls = compress (x : common xs ls)
 | otherwise = common xs ls
    where
        contains ::  Eq a => a -> [a] -> Bool
        contains needle [] = False
        contains needle (h:hs)
         | needle == h = True
         | otherwise = contains needle hs
