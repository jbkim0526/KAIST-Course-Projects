-- | Assignment 2: CPU core actions
module A02
  ( Reg
  , UnaryOp
  , BinaryOp
  , Operand
  , Instr
  , encodeReg
  , encodeUnaryOp
  , encodeBinaryOp
  , encodeOperand
  , encodeInstr
  , decodeReg
  , decodeUnaryOp
  , decodeBinaryOp
  , decodeOperand
  , decodeInstr
  ) where

import           GHC.Generics                   ( Generic )
import           Generic.Random
import           Test.Tasty.QuickCheck         as QC
                                         hiding ( (.&.) )

import           Data.Bits
import           Data.Word

import           A02_Defs

-- | TODO marker.
todo :: t
todo = error "todo"

decodeReg :: Word32 -> Maybe Reg
decodeReg w = if w < 32 then Just (Reg w) else Nothing

decodeUnaryOp :: Word32 -> Maybe UnaryOp
decodeUnaryOp 0 = Just Move
decodeUnaryOp 1 = Just Negate
decodeUnaryOp 2 = Just Complement
decodeUnaryOp 3 = Just Not
decodeUnaryOp _ = Nothing

decodeBinaryOp :: Word32 -> Maybe BinaryOp
decodeBinaryOp 0 = Just Add
decodeBinaryOp 1 = Just Sub
decodeBinaryOp 2 = Just Mul
decodeBinaryOp 3 = Just Or
decodeBinaryOp 4 = Just And
decodeBinaryOp 5 = Just Xor
decodeBinaryOp 6 = Just Lt
decodeBinaryOp 7 = Just Gt
decodeBinaryOp 8 = Just Eq
decodeBinaryOp _ = Nothing

decodeOperand :: Word32 -> Maybe Operand
decodeOperand w | w `rem` 2 == 0 && w < 64 = Just (OperandReg (Reg (w `div` 2)))
decodeOperand w | w `rem` 2 /= 0 && w < 1024 = Just (OperandVal (Val ((w-1) `div` 2)))
decodeOperand _ = Nothing

-- | Get 'size'bit chunk from 'w' starting from 'index' and moving left.  
get :: Word32 -> Int -> Int -> Word32
get w index size = (shiftR w index) .&. (shiftL 1 size - 1)

-- | Decode instruction. The 3 LSB bits are op-codes.
decodeInstr :: Word32 -> Maybe Instr
decodeInstr w = do
    
    let _opcode = get w 0 3 
    let _reg = get w 3 5
    let _op = get w 8 4
    let _src1 = get w 12 10
    let _src2 = get w 22 10

    case _opcode of
      0 -> do
        reg <- decodeReg _reg 
        op <- decodeUnaryOp _op
        src1 <- decodeOperand _src1
        return ( Unary(reg,op,src1))

      1 -> do
        reg <- decodeReg _reg 
        op <- decodeBinaryOp _op
        src1 <- decodeOperand _src1
        src2 <- decodeOperand _src2
        return ( Binary(reg,op,src1,src2))

      2 -> do
        reg <- decodeReg _reg 
        src1 <- decodeOperand _src1
        return ( Load(reg,src1))

      3 -> do
        src1 <- decodeOperand _src1
        src2 <- decodeOperand _src2
        return ( Store(src1,src2))

      4 -> do
        reg <- decodeReg _reg
        src1 <- decodeOperand _src1
        src2 <- decodeOperand _src2
        return ( Cas(reg, src1, src2))

      5 -> do
        src1 <- decodeOperand _src1
        return ( Jump(src1))
      
      6 -> do
        reg <- decodeReg _reg 
        src1 <- decodeOperand _src1
        src2 <- decodeOperand _src2
        return ( CondJump(reg,src1,src2))
      
      _ -> Nothing