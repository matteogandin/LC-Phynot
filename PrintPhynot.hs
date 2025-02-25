-- File generated by the BNF Converter (bnfc 2.9.5).

{-# LANGUAGE CPP #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE LambdaCase #-}
#if __GLASGOW_HASKELL__ <= 708
{-# LANGUAGE OverlappingInstances #-}
#endif

-- | Pretty-printer for PrintPhynot.

module PrintPhynot where

import Prelude
  ( ($), (.)
  , Bool(..), (==), (<)
  , Int, Integer, Double, (+), (-), (*)
  , String, (++)
  , ShowS, showChar, showString
  , all, elem, foldr, id, map, null, replicate, shows, span
  )
import Data.Char ( Char, isSpace )
import qualified AbsPhynot

-- | The top-level printing method.

printTree :: Print a => a -> String
printTree = render . prt 0

type Doc = [ShowS] -> [ShowS]

doc :: ShowS -> Doc
doc = (:)

render :: Doc -> String
render d = rend 0 False (map ($ "") $ d []) ""
  where
  rend
    :: Int        -- ^ Indentation level.
    -> Bool       -- ^ Pending indentation to be output before next character?
    -> [String]
    -> ShowS
  rend i p = \case
      "["      :ts -> char '[' . rend i False ts
      "("      :ts -> char '(' . rend i False ts
      "{"      :ts -> onNewLine i     p . showChar   '{'  . new (i+1) ts
      "}" : ";":ts -> onNewLine (i-1) p . showString "};" . new (i-1) ts
      "}"      :ts -> onNewLine (i-1) p . showChar   '}'  . new (i-1) ts
      [";"]        -> char ';'
      ";"      :ts -> char ';' . new i ts
      t  : ts@(s:_) | closingOrPunctuation s
                   -> pending . showString t . rend i False ts
      t        :ts -> pending . space t      . rend i False ts
      []           -> id
    where
    -- Output character after pending indentation.
    char :: Char -> ShowS
    char c = pending . showChar c

    -- Output pending indentation.
    pending :: ShowS
    pending = if p then indent i else id

  -- Indentation (spaces) for given indentation level.
  indent :: Int -> ShowS
  indent i = replicateS (2*i) (showChar ' ')

  -- Continue rendering in new line with new indentation.
  new :: Int -> [String] -> ShowS
  new j ts = showChar '\n' . rend j True ts

  -- Make sure we are on a fresh line.
  onNewLine :: Int -> Bool -> ShowS
  onNewLine i p = (if p then id else showChar '\n') . indent i

  -- Separate given string from following text by a space (if needed).
  space :: String -> ShowS
  space t s =
    case (all isSpace t, null spc, null rest) of
      (True , _   , True ) -> []             -- remove trailing space
      (False, _   , True ) -> t              -- remove trailing space
      (False, True, False) -> t ++ ' ' : s   -- add space if none
      _                    -> t ++ s
    where
      (spc, rest) = span isSpace s

  closingOrPunctuation :: String -> Bool
  closingOrPunctuation [c] = c `elem` closerOrPunct
  closingOrPunctuation _   = False

  closerOrPunct :: String
  closerOrPunct = ")],;"

parenth :: Doc -> Doc
parenth ss = doc (showChar '(') . ss . doc (showChar ')')

concatS :: [ShowS] -> ShowS
concatS = foldr (.) id

concatD :: [Doc] -> Doc
concatD = foldr (.) id

replicateS :: Int -> ShowS -> ShowS
replicateS n f = concatS (replicate n f)

-- | The printer class does the job.

class Print a where
  prt :: Int -> a -> Doc

instance {-# OVERLAPPABLE #-} Print a => Print [a] where
  prt i = concatD . map (prt i)

instance Print Char where
  prt _ c = doc (showChar '\'' . mkEsc '\'' c . showChar '\'')

instance Print String where
  prt _ = printString

printString :: String -> Doc
printString s = doc (showChar '"' . concatS (map (mkEsc '"') s) . showChar '"')

mkEsc :: Char -> Char -> ShowS
mkEsc q = \case
  s | s == q -> showChar '\\' . showChar s
  '\\' -> showString "\\\\"
  '\n' -> showString "\\n"
  '\t' -> showString "\\t"
  s -> showChar s

prPrec :: Int -> Int -> Doc -> Doc
prPrec i j = if j < i then parenth else id

instance Print Integer where
  prt _ x = doc (shows x)

instance Print Double where
  prt _ x = doc (shows x)

instance Print AbsPhynot.Ident where
  prt _ (AbsPhynot.Ident i) = doc $ showString i
instance Print AbsPhynot.Program where
  prt i = \case
    AbsPhynot.ProgramStart stms -> prPrec i 0 (concatD [prt 0 stms])

instance Print [AbsPhynot.Stm] where
  prt _ [] = concatD []
  prt _ [x] = concatD [prt 0 x, doc (showString ";")]
  prt _ (x:xs) = concatD [prt 0 x, doc (showString ";"), prt 0 xs]

instance Print AbsPhynot.BasicType where
  prt i = \case
    AbsPhynot.BasicType_int -> prPrec i 0 (concatD [doc (showString "int")])
    AbsPhynot.BasicType_float -> prPrec i 0 (concatD [doc (showString "float")])
    AbsPhynot.BasicType_char -> prPrec i 0 (concatD [doc (showString "char")])
    AbsPhynot.BasicType_String -> prPrec i 0 (concatD [doc (showString "String")])
    AbsPhynot.BasicType_bool -> prPrec i 0 (concatD [doc (showString "bool")])

instance Print AbsPhynot.Boolean where
  prt i = \case
    AbsPhynot.Boolean_True -> prPrec i 0 (concatD [doc (showString "True")])
    AbsPhynot.Boolean_False -> prPrec i 0 (concatD [doc (showString "False")])

instance Print AbsPhynot.Stm where
  prt i = \case
    AbsPhynot.VarDeclaration basictype id_ -> prPrec i 0 (concatD [prt 0 basictype, prt 0 id_])
    AbsPhynot.VarDeclarationInit basictype id_ rexp -> prPrec i 0 (concatD [prt 0 basictype, prt 0 id_, doc (showString "="), prt 0 rexp])
    AbsPhynot.ArrayDeclaration basictype id_ dims -> prPrec i 0 (concatD [prt 0 basictype, prt 0 id_, prt 0 dims])
    AbsPhynot.PointerDeclaration basictype id_ -> prPrec i 0 (concatD [prt 0 basictype, doc (showString "*"), prt 0 id_])
    AbsPhynot.PointerDeclarationInit basictype id_ rexp -> prPrec i 0 (concatD [prt 0 basictype, doc (showString "*"), prt 0 id_, doc (showString "="), prt 0 rexp])
    AbsPhynot.FunctionDeclaration basictype id_ params stms -> prPrec i 0 (concatD [doc (showString "def"), prt 0 basictype, prt 0 id_, doc (showString "("), prt 0 params, doc (showString ")"), doc (showString "{"), prt 0 stms, doc (showString "}")])
    AbsPhynot.FunctionNoParamDeclaration basictype id_ stms -> prPrec i 0 (concatD [doc (showString "def"), prt 0 basictype, prt 0 id_, doc (showString "()"), doc (showString "{"), prt 0 stms, doc (showString "}")])
    AbsPhynot.ProcedureDeclaration id_ params stms -> prPrec i 0 (concatD [doc (showString "def"), doc (showString "None"), prt 0 id_, doc (showString "("), prt 0 params, doc (showString ")"), doc (showString "{"), prt 0 stms, doc (showString "}")])
    AbsPhynot.ProcedureNoParamDeclaration id_ stms -> prPrec i 0 (concatD [doc (showString "def"), doc (showString "None"), prt 0 id_, doc (showString "()"), doc (showString "{"), prt 0 stms, doc (showString "}")])
    AbsPhynot.ProcedureCall id_ rexps -> prPrec i 0 (concatD [prt 0 id_, doc (showString "("), prt 0 rexps, doc (showString ")")])
    AbsPhynot.ProcedureCallNoParam id_ -> prPrec i 0 (concatD [prt 0 id_, doc (showString "()")])
    AbsPhynot.Return rexp -> prPrec i 0 (concatD [doc (showString "return"), prt 0 rexp])
    AbsPhynot.Assignment lexp rexp -> prPrec i 0 (concatD [prt 0 lexp, doc (showString "="), prt 0 rexp])
    AbsPhynot.WriteInt rexp -> prPrec i 0 (concatD [doc (showString "writeInt"), doc (showString "("), prt 0 rexp, doc (showString ")")])
    AbsPhynot.WriteFloat rexp -> prPrec i 0 (concatD [doc (showString "writeFloat"), doc (showString "("), prt 0 rexp, doc (showString ")")])
    AbsPhynot.WriteChar rexp -> prPrec i 0 (concatD [doc (showString "writeChar"), doc (showString "("), prt 0 rexp, doc (showString ")")])
    AbsPhynot.WriteString rexp -> prPrec i 0 (concatD [doc (showString "writeString"), doc (showString "("), prt 0 rexp, doc (showString ")")])
    AbsPhynot.ReadInt -> prPrec i 0 (concatD [doc (showString "readInt"), doc (showString "()")])
    AbsPhynot.ReadFloat -> prPrec i 0 (concatD [doc (showString "readFloat"), doc (showString "()")])
    AbsPhynot.ReadChar -> prPrec i 0 (concatD [doc (showString "readChar"), doc (showString "()")])
    AbsPhynot.ReadString -> prPrec i 0 (concatD [doc (showString "readString"), doc (showString "()")])
    AbsPhynot.IfThen rexp stms -> prPrec i 0 (concatD [doc (showString "if"), prt 0 rexp, doc (showString "{"), prt 0 stms, doc (showString "}")])
    AbsPhynot.IfThenElse rexp stms1 stms2 -> prPrec i 0 (concatD [doc (showString "if"), prt 0 rexp, doc (showString "{"), prt 0 stms1, doc (showString "}"), doc (showString "else"), doc (showString "{"), prt 0 stms2, doc (showString "}")])
    AbsPhynot.WhileDo rexp stms -> prPrec i 0 (concatD [doc (showString "while"), prt 0 rexp, doc (showString "{"), prt 0 stms, doc (showString "}")])
    AbsPhynot.Break -> prPrec i 0 (concatD [doc (showString "break")])
    AbsPhynot.Continue -> prPrec i 0 (concatD [doc (showString "continue")])
    AbsPhynot.Pass -> prPrec i 0 (concatD [doc (showString "pass")])

instance Print [AbsPhynot.Param] where
  prt _ [] = concatD []
  prt _ [x] = concatD [prt 0 x]
  prt _ (x:xs) = concatD [prt 0 x, doc (showString ","), prt 0 xs]

instance Print AbsPhynot.Param where
  prt i = \case
    AbsPhynot.Parameter basictype id_ -> prPrec i 0 (concatD [prt 0 basictype, prt 0 id_])

instance Print AbsPhynot.LExp where
  prt i = \case
    AbsPhynot.LIdent id_ -> prPrec i 0 (concatD [prt 0 id_])
    AbsPhynot.LArray id_ dims -> prPrec i 0 (concatD [prt 0 id_, prt 0 dims])

instance Print AbsPhynot.Dim where
  prt i = \case
    AbsPhynot.ArrayDimension rexp -> prPrec i 0 (concatD [doc (showString "["), prt 0 rexp, doc (showString "]")])

instance Print [AbsPhynot.Dim] where
  prt _ [] = concatD []
  prt _ [x] = concatD [prt 0 x]
  prt _ (x:xs) = concatD [prt 0 x, prt 0 xs]

instance Print AbsPhynot.RExp where
  prt i = \case
    AbsPhynot.Or rexp1 rexp2 -> prPrec i 0 (concatD [prt 0 rexp1, doc (showString "or"), prt 2 rexp2])
    AbsPhynot.And rexp1 rexp2 -> prPrec i 0 (concatD [prt 0 rexp1, doc (showString "and"), prt 2 rexp2])
    AbsPhynot.Not rexp -> prPrec i 0 (concatD [doc (showString "not"), prt 2 rexp])
    AbsPhynot.Eq rexp1 rexp2 -> prPrec i 2 (concatD [prt 2 rexp1, doc (showString "=="), prt 3 rexp2])
    AbsPhynot.Neq rexp1 rexp2 -> prPrec i 2 (concatD [prt 2 rexp1, doc (showString "!="), prt 3 rexp2])
    AbsPhynot.Lt rexp1 rexp2 -> prPrec i 2 (concatD [prt 2 rexp1, doc (showString "<"), prt 3 rexp2])
    AbsPhynot.Gt rexp1 rexp2 -> prPrec i 2 (concatD [prt 2 rexp1, doc (showString ">"), prt 3 rexp2])
    AbsPhynot.Le rexp1 rexp2 -> prPrec i 2 (concatD [prt 2 rexp1, doc (showString "<="), prt 3 rexp2])
    AbsPhynot.Ge rexp1 rexp2 -> prPrec i 2 (concatD [prt 2 rexp1, doc (showString ">="), prt 3 rexp2])
    AbsPhynot.Add rexp1 rexp2 -> prPrec i 3 (concatD [prt 3 rexp1, doc (showString "+"), prt 4 rexp2])
    AbsPhynot.Sub rexp1 rexp2 -> prPrec i 3 (concatD [prt 3 rexp1, doc (showString "-"), prt 4 rexp2])
    AbsPhynot.Mul rexp1 rexp2 -> prPrec i 3 (concatD [prt 3 rexp1, doc (showString "*"), prt 4 rexp2])
    AbsPhynot.Div rexp1 rexp2 -> prPrec i 3 (concatD [prt 3 rexp1, doc (showString "/"), prt 4 rexp2])
    AbsPhynot.Mod rexp1 rexp2 -> prPrec i 3 (concatD [prt 3 rexp1, doc (showString "%"), prt 4 rexp2])
    AbsPhynot.PointerRef rexp -> prPrec i 4 (concatD [doc (showString "&"), prt 5 rexp])
    AbsPhynot.IntValue n -> prPrec i 5 (concatD [prt 0 n])
    AbsPhynot.FloatValue d -> prPrec i 5 (concatD [prt 0 d])
    AbsPhynot.StringValue str -> prPrec i 5 (concatD [printString str])
    AbsPhynot.CharValue c -> prPrec i 5 (concatD [prt 0 c])
    AbsPhynot.BooleanValue boolean -> prPrec i 5 (concatD [prt 0 boolean])
    AbsPhynot.VarValue id_ -> prPrec i 5 (concatD [prt 0 id_])
    AbsPhynot.FuncCall id_ rexps -> prPrec i 5 (concatD [prt 0 id_, doc (showString "("), prt 0 rexps, doc (showString ")")])
    AbsPhynot.FuncCallNoParam id_ -> prPrec i 5 (concatD [prt 0 id_, doc (showString "()")])

instance Print [AbsPhynot.RExp] where
  prt _ [] = concatD []
  prt _ [x] = concatD [prt 0 x]
  prt _ (x:xs) = concatD [prt 0 x, doc (showString ","), prt 0 xs]
