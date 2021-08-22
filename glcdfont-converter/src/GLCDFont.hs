module GLCDFont
    ( decode
    , encode
    ) where

import Data.List
import Data.Char
import Text.Printf

decode :: IO ()
decode = do
    contents <- getContents
    putStrLn $ unlines $ decode' $ lines contents
    return ()

decode' :: [String] -> [String]
decode' = printProgmem . parseProgmem . extractProgmem

extractProgmem = let progmemStart = isInfixOf "char font[] PROGMEM"
                     dropWhileNot predicate = dropWhile (not . predicate)
                     dropLast = reverse . (drop 1) . reverse in
              dropLast . (drop 1) . (dropWhileNot progmemStart)

parseProgmem = let removeTrailingComma = dropWhileEnd (\c -> c == ',') in
                (map readInt) . (map removeTrailingComma) . words . unlines

printProgmem = map (printf "%08b")

readInt :: String -> Int
readInt = read

encode :: IO ()
encode = putStrLn "encode"
