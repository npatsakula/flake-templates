module Main (main) where

import Library qualified as Library (someFunc)

main :: IO ()
main = do
  putStrLn "Hello, Haskell!"
  Library.someFunc
