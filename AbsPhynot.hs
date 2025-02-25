-- File generated by the BNF Converter (bnfc 2.9.5).

{-# LANGUAGE GeneralizedNewtypeDeriving #-}

-- | The abstract syntax of language phynot.

module AbsPhynot where

import Prelude (Char, Double, Integer, String)
import qualified Prelude as C (Eq, Ord, Show, Read)
import qualified Data.String

data Program = ProgramStart [Stm]
  deriving (C.Eq, C.Ord, C.Show, C.Read)

data BasicType
    = BasicType_int
    | BasicType_float
    | BasicType_char
    | BasicType_String
    | BasicType_bool
  deriving (C.Eq, C.Ord, C.Show, C.Read)

data Boolean = Boolean_True | Boolean_False
  deriving (C.Eq, C.Ord, C.Show, C.Read)

data Stm
    = VarDeclaration BasicType Ident
    | VarDeclarationInit BasicType Ident RExp
    | ArrayDeclaration BasicType Ident [Dim]
    | PointerDeclaration BasicType Ident
    | PointerDeclarationInit BasicType Ident RExp
    | FunctionDeclaration BasicType Ident [Param] [Stm]
    | FunctionNoParamDeclaration BasicType Ident [Stm]
    | ProcedureDeclaration Ident [Param] [Stm]
    | ProcedureNoParamDeclaration Ident [Stm]
    | ProcedureCall Ident [RExp]
    | ProcedureCallNoParam Ident
    | Return RExp
    | Assignment LExp RExp
    | WriteInt RExp
    | WriteFloat RExp
    | WriteChar RExp
    | WriteString RExp
    | ReadInt
    | ReadFloat
    | ReadChar
    | ReadString
    | IfThen RExp [Stm]
    | IfThenElse RExp [Stm] [Stm]
    | WhileDo RExp [Stm]
    | Break
    | Continue
    | Pass
  deriving (C.Eq, C.Ord, C.Show, C.Read)

data Param = Parameter BasicType Ident
  deriving (C.Eq, C.Ord, C.Show, C.Read)

data LExp = LIdent Ident | LArray Ident [Dim]
  deriving (C.Eq, C.Ord, C.Show, C.Read)

data Dim = ArrayDimension RExp
  deriving (C.Eq, C.Ord, C.Show, C.Read)

data RExp
    = Or RExp RExp
    | And RExp RExp
    | Not RExp
    | Eq RExp RExp
    | Neq RExp RExp
    | Lt RExp RExp
    | Gt RExp RExp
    | Le RExp RExp
    | Ge RExp RExp
    | Add RExp RExp
    | Sub RExp RExp
    | Mul RExp RExp
    | Div RExp RExp
    | Mod RExp RExp
    | PointerRef RExp
    | IntValue Integer
    | FloatValue Double
    | StringValue String
    | CharValue Char
    | BooleanValue Boolean
    | VarValue Ident
    | FuncCall Ident [RExp]
    | FuncCallNoParam Ident
  deriving (C.Eq, C.Ord, C.Show, C.Read)

newtype Ident = Ident String
  deriving (C.Eq, C.Ord, C.Show, C.Read, Data.String.IsString)

