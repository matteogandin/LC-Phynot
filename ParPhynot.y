-- -*- haskell -*- File generated by the BNF Converter (bnfc 2.9.5).

-- Parser definition for use with Happy
{
{-# OPTIONS_GHC -fno-warn-incomplete-patterns -fno-warn-overlapping-patterns #-}
{-# LANGUAGE PatternSynonyms #-}

module ParPhynot
  ( happyError
  , myLexer
  , pProgram
  , pListStm
  , pBasicType
  , pBoolean
  , pStm
  , pListParam
  , pParam
  , pLExp
  , pDim
  , pListDim
  , pRExp
  , pRExp2
  , pRExp3
  , pRExp4
  , pRExp5
  , pListRExp
  , pRExp1
  ) where

import Prelude

import qualified AbsPhynot
import LexPhynot

}

%name pProgram Program
%name pListStm ListStm
%name pBasicType BasicType
%name pBoolean Boolean
%name pStm Stm
%name pListParam ListParam
%name pParam Param
%name pLExp LExp
%name pDim Dim
%name pListDim ListDim
%name pRExp RExp
%name pRExp2 RExp2
%name pRExp3 RExp3
%name pRExp4 RExp4
%name pRExp5 RExp5
%name pListRExp ListRExp
%name pRExp1 RExp1
-- no lexer declaration
%monad { Err } { (>>=) } { return }
%tokentype {Token}
%token
  '!='          { PT _ (TS _ 1)  }
  '%'           { PT _ (TS _ 2)  }
  '&'           { PT _ (TS _ 3)  }
  '('           { PT _ (TS _ 4)  }
  '()'          { PT _ (TS _ 5)  }
  ')'           { PT _ (TS _ 6)  }
  '*'           { PT _ (TS _ 7)  }
  '+'           { PT _ (TS _ 8)  }
  ','           { PT _ (TS _ 9)  }
  '-'           { PT _ (TS _ 10) }
  '/'           { PT _ (TS _ 11) }
  ';'           { PT _ (TS _ 12) }
  '<'           { PT _ (TS _ 13) }
  '<='          { PT _ (TS _ 14) }
  '='           { PT _ (TS _ 15) }
  '=='          { PT _ (TS _ 16) }
  '>'           { PT _ (TS _ 17) }
  '>='          { PT _ (TS _ 18) }
  'False'       { PT _ (TS _ 19) }
  'None'        { PT _ (TS _ 20) }
  'String'      { PT _ (TS _ 21) }
  'True'        { PT _ (TS _ 22) }
  '['           { PT _ (TS _ 23) }
  ']'           { PT _ (TS _ 24) }
  'and'         { PT _ (TS _ 25) }
  'bool'        { PT _ (TS _ 26) }
  'break'       { PT _ (TS _ 27) }
  'char'        { PT _ (TS _ 28) }
  'continue'    { PT _ (TS _ 29) }
  'def'         { PT _ (TS _ 30) }
  'else'        { PT _ (TS _ 31) }
  'float'       { PT _ (TS _ 32) }
  'if'          { PT _ (TS _ 33) }
  'int'         { PT _ (TS _ 34) }
  'not'         { PT _ (TS _ 35) }
  'or'          { PT _ (TS _ 36) }
  'pass'        { PT _ (TS _ 37) }
  'readChar'    { PT _ (TS _ 38) }
  'readFloat'   { PT _ (TS _ 39) }
  'readInt'     { PT _ (TS _ 40) }
  'readString'  { PT _ (TS _ 41) }
  'return'      { PT _ (TS _ 42) }
  'while'       { PT _ (TS _ 43) }
  'writeChar'   { PT _ (TS _ 44) }
  'writeFloat'  { PT _ (TS _ 45) }
  'writeInt'    { PT _ (TS _ 46) }
  'writeString' { PT _ (TS _ 47) }
  '{'           { PT _ (TS _ 48) }
  '}'           { PT _ (TS _ 49) }
  L_Ident       { PT _ (TV $$)   }
  L_charac      { PT _ (TC $$)   }
  L_doubl       { PT _ (TD $$)   }
  L_integ       { PT _ (TI $$)   }
  L_quoted      { PT _ (TL $$)   }

%%

Ident :: { AbsPhynot.Ident }
Ident  : L_Ident { AbsPhynot.Ident $1 }

Char    :: { Char }
Char     : L_charac { (read $1) :: Char }

Double  :: { Double }
Double   : L_doubl  { (read $1) :: Double }

Integer :: { Integer }
Integer  : L_integ  { (read $1) :: Integer }

String  :: { String }
String   : L_quoted { $1 }

Program :: { AbsPhynot.Program }
Program : ListStm { AbsPhynot.ProgramStart $1 }

ListStm :: { [AbsPhynot.Stm] }
ListStm : Stm ';' { (:[]) $1 } | Stm ';' ListStm { (:) $1 $3 }

BasicType :: { AbsPhynot.BasicType }
BasicType
  : 'int' { AbsPhynot.BasicType_int }
  | 'float' { AbsPhynot.BasicType_float }
  | 'char' { AbsPhynot.BasicType_char }
  | 'String' { AbsPhynot.BasicType_String }
  | 'bool' { AbsPhynot.BasicType_bool }

Boolean :: { AbsPhynot.Boolean }
Boolean
  : 'True' { AbsPhynot.Boolean_True }
  | 'False' { AbsPhynot.Boolean_False }

Stm :: { AbsPhynot.Stm }
Stm
  : BasicType Ident { AbsPhynot.VarDeclaration $1 $2 }
  | BasicType Ident '=' RExp { AbsPhynot.VarDeclarationInit $1 $2 $4 }
  | BasicType Ident ListDim { AbsPhynot.ArrayDeclaration $1 $2 $3 }
  | BasicType '*' Ident { AbsPhynot.PointerDeclaration $1 $3 }
  | BasicType '*' Ident '=' RExp { AbsPhynot.PointerDeclarationInit $1 $3 $5 }
  | 'def' BasicType Ident '(' ListParam ')' '{' ListStm '}' { AbsPhynot.FunctionDeclaration $2 $3 $5 $8 }
  | 'def' 'None' Ident '(' ListParam ')' '{' ListStm '}' { AbsPhynot.ProcedureDeclaration $3 $5 $8 }
  | 'return' RExp { AbsPhynot.Return $2 }
  | LExp '=' RExp { AbsPhynot.Assignment $1 $3 }
  | 'writeInt' '(' ')' { AbsPhynot.WriteInt }
  | 'writeFloat' '(' ')' { AbsPhynot.WriteFloat }
  | 'writeChar' '(' ')' { AbsPhynot.WriteChar }
  | 'writeString' '(' ')' { AbsPhynot.WriteString }
  | 'readInt' '()' { AbsPhynot.ReadInt }
  | 'readFloat' '()' { AbsPhynot.ReadFloat }
  | 'readChar' '()' { AbsPhynot.ReadChar }
  | 'readString' '()' { AbsPhynot.ReadString }
  | 'if' RExp '{' ListStm '}' { AbsPhynot.IfThen $2 $4 }
  | 'if' RExp '{' ListStm '}' 'else' '{' ListStm '}' { AbsPhynot.IfThenElse $2 $4 $8 }
  | 'while' RExp '{' ListStm '}' { AbsPhynot.WhileDo $2 $4 }
  | 'break' { AbsPhynot.Break }
  | 'continue' { AbsPhynot.Continue }
  | 'pass' { AbsPhynot.Pass }

ListParam :: { [AbsPhynot.Param] }
ListParam
  : {- empty -} { [] }
  | Param { (:[]) $1 }
  | Param ',' ListParam { (:) $1 $3 }

Param :: { AbsPhynot.Param }
Param : BasicType Ident { AbsPhynot.Parameter $1 $2 }

LExp :: { AbsPhynot.LExp }
LExp
  : Ident { AbsPhynot.LIdent $1 }
  | Ident ListDim { AbsPhynot.LArray $1 $2 }

Dim :: { AbsPhynot.Dim }
Dim : '[' RExp ']' { AbsPhynot.ArrayDimension $2 }

ListDim :: { [AbsPhynot.Dim] }
ListDim : Dim { (:[]) $1 } | Dim ListDim { (:) $1 $2 }

RExp :: { AbsPhynot.RExp }
RExp
  : RExp 'or' RExp2 { AbsPhynot.Or $1 $3 }
  | RExp 'and' RExp2 { AbsPhynot.And $1 $3 }
  | 'not' RExp2 { AbsPhynot.Not $2 }
  | RExp1 { $1 }

RExp2 :: { AbsPhynot.RExp }
RExp2
  : RExp2 '==' RExp3 { AbsPhynot.Eq $1 $3 }
  | RExp2 '!=' RExp3 { AbsPhynot.Neq $1 $3 }
  | RExp2 '<' RExp3 { AbsPhynot.Lt $1 $3 }
  | RExp2 '>' RExp3 { AbsPhynot.Gt $1 $3 }
  | RExp2 '<=' RExp3 { AbsPhynot.Le $1 $3 }
  | RExp2 '>=' RExp3 { AbsPhynot.Ge $1 $3 }
  | RExp3 { $1 }

RExp3 :: { AbsPhynot.RExp }
RExp3
  : RExp3 '+' RExp4 { AbsPhynot.Add $1 $3 }
  | RExp3 '-' RExp4 { AbsPhynot.Sub $1 $3 }
  | RExp3 '*' RExp4 { AbsPhynot.Mul $1 $3 }
  | RExp3 '/' RExp4 { AbsPhynot.Div $1 $3 }
  | RExp3 '%' RExp4 { AbsPhynot.Mod $1 $3 }
  | RExp4 { $1 }

RExp4 :: { AbsPhynot.RExp }
RExp4 : '&' RExp5 { AbsPhynot.PointerRef $2 } | RExp5 { $1 }

RExp5 :: { AbsPhynot.RExp }
RExp5
  : Integer { AbsPhynot.IntValue $1 }
  | Double { AbsPhynot.FloatValue $1 }
  | String { AbsPhynot.StringValue $1 }
  | Char { AbsPhynot.CharValue $1 }
  | Boolean { AbsPhynot.BooleanValue $1 }
  | Ident { AbsPhynot.VarValue $1 }
  | Ident '(' ListRExp ')' { AbsPhynot.FuncCall $1 $3 }
  | '(' RExp ')' { $2 }

ListRExp :: { [AbsPhynot.RExp] }
ListRExp
  : {- empty -} { [] }
  | RExp { (:[]) $1 }
  | RExp ',' ListRExp { (:) $1 $3 }

RExp1 :: { AbsPhynot.RExp }
RExp1 : RExp2 { $1 }

{

type Err = Either String

happyError :: [Token] -> Err a
happyError ts = Left $
  "syntax error at " ++ tokenPos ts ++
  case ts of
    []      -> []
    [Err _] -> " due to lexer error"
    t:_     -> " before `" ++ (prToken t) ++ "'"

myLexer :: String -> [Token]
myLexer = tokens

}

