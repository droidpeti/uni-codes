module HF where

xor3 :: Bool -> Bool -> Bool -> Bool
xor3 b1 b2 b3 = length(filter (== True) [b1,b2,b3]) == 1

multifunction :: String -> Double -> Double -> Double
multifunction operation num1 num2 =
    case operation of
        "add"  -> num1 + num2
        "sub"  -> num1 - num2
        "mult" -> num1 * num2
        _      -> 0