-- File generated by the BNF Converter (bnfc 2.9.5).

-- | Program to test parser.

module Main where

import Prelude
  ( ($), (.)
  , Either(..)
  , Int, (>)
  , String, (++), concat, unlines
  , Show, show
  , IO, (>>), (>>=), mapM_, putStrLn
  , FilePath
  , getContents, readFile
  )
import System.Environment ( getArgs )
import System.Exit        ( exitFailure )
import Control.Monad      ( when )

--import TAC
import AbsPhynot   
import LexPhynot 
import ParPhynot
import PrintPhynot 
import SkelPhynot

import ErrM

type ParseFun a = [Token] -> ErrM.Err a
type Verbosity  = Int

putStrV :: Verbosity -> String -> IO ()
putStrV v s = when (v > 1) $ putStrLn s

runFile ::  Verbosity -> ParseFun ParPhynot.Result -> FilePath -> IO ()
runFile v p f = putStrLn f >> readFile f >>= run v p

run :: Verbosity -> ParseFun ParPhynot.Result -> String -> IO ()
run v p s =
  case p ts of
    Left err -> do
      putStrLn "\nParse              Failed...\n"
      putStrV v "Tokens:"
      mapM_ (putStrV v . showPosToken . mkPosToken) ts
      putStrLn err
      exitFailure
    --Right (Result prog errs tac) -> do
    Right (Result prog errs) -> do
      putStrLn "\nParse Successful!"
      showTree v prog
      showErrors v errs
      --showTAC v tac
  where
  ts = myLexer s
  showPosToken ((l,c),t) = concat [ show l, ":", show c, "\t", show t ]

showTree :: (Show a, Print a) => Int -> a -> IO ()
showTree v tree = do
  putStrV v $ "\n[Abstract Syntax]\n\n" ++ show tree
  putStrV v $ "\n[Linearized tree]\n\n" ++ printTree tree

showErrors :: (Show a, Print a) => Int -> a -> IO ()
showErrors v tree = do
  putStrV v $ "\n[Errors]\n\n" ++ show tree

--showTAC :: Int -> [TACInstruction] -> IO ()
--showTAC v tac = do
  --putStrV v $ "\n[TAC]\n\n"
  --mapM_ (putStrV v . show) tac

usage :: IO ()
usage = do
  putStrLn $ unlines
    [ "usage: Call with one of the following argument combinations:"
    , "  --help          Display this help message."
    , "  (no arguments)  Parse stdin verbosely."
    , "  (files)         Parse content of files verbosely."
    , "  -s (files)      Silent mode. Parse content of files silently."
    ]

main :: IO ()
main = do
  args <- getArgs
  case args of
    ["--help"] -> usage
    []         -> getContents >>= run 2 pProgram
    "-s":fs    -> mapM_ (runFile 0 pProgram) fs
    fs         -> mapM_ (runFile 2 pProgram) fs