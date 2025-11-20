module Nyolcadik where

indexString :: [Char] -> [(Integer, Char)]
indexString str = zip [1..(toInteger(length str))] str

asteriskSeq :: String
asteriskSeq = unwords [ replicate i '*' | i <- [1..]]

-- data Bool = False | True

data Answer = No | Maybe | Yes
toString :: Answer -> String
toString No = "No"
toString Maybe = "Maybe"
toString Yes = "Yes"

data Pair = P Int Int

addElems :: Pair -> Int
addElems (P x y) = x + y

data Day = Mon | Tue | Wed | Thu | Fri | Sat | Sun deriving(Show, Eq, Enum)

isWeekend :: Day -> Bool
isWeekend Sat = True
isWeekend Sun = True
isWeekend _ = False

tomorrow :: Day -> Day
tomorrow Sun = Mon
tomorrow d = succ d