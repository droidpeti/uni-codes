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

data Line = Tram Integer [String]
          | Bus Integer [String]
          deriving (Eq, Show)

whichBusStop :: String -> [Line] -> [Integer]
whichBusStop _ [] = []
whichBusStop station (l:ls)
 | elem station (getStops l) && getVehicleType l == "Bus" = getNumber l : whichBusStop station ls
 | otherwise = whichBusStop station ls

getStops :: Line -> [String]
getStops (Tram _ stops) = stops
getStops (Bus _ stops)  = stops

getNumber :: Line -> Integer
getNumber (Tram number _) = number
getNumber (Bus number _) = number

getVehicleType :: Line -> String
getVehicleType (Tram _ _) = "Tram"
getVehicleType (Bus _ _)  = "Bus"

isReservable :: Int -> String -> Bool
isReservable 0 _ = True
isReservable _ "" = False
isReservable count seats = isReservable' 0 count seats
   where
     isReservable' :: Int -> Int -> String -> Bool
     isReservable' counter target _ 
      | counter == target = True
     isReservable' _ _ "" = False
     isReservable' counter target (s:ls)
      | s == 'x'  = isReservable' (counter + 1) target ls
      | otherwise = isReservable' 0 target ls
