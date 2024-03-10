module A05
  ( ShrMem (..)
  , newShrMem
  , loadShrMem
  , storeShrMem
  , casShrMem
  ) where

import           Control.Concurrent.MVar
import           Data.Map                      as Map

import           A02_Defs
import           A03_Defs
import           A05_Defs

-- | TODO marker.
todo :: t
todo = error "todo"

newShrMem :: IO ShrMem
newShrMem = do
  m <- newMVar Map.empty
  return (ShrMem m)

loadShrMem :: Loc -> ShrMem -> IO (Maybe Val)
loadShrMem loc (ShrMem mem) = do
  shmap <- readMVar mem
  let v = (Map.lookup loc shmap)
  case v of
    Nothing -> do
      return (Nothing)
    Just(v) -> do
      v2 <- takeMVar v
      putMVar v v2
      return (Just v2)
  
storeShrMem :: Loc -> Val -> ShrMem -> IO ()
storeShrMem loc val (ShrMem mem) = do
  shmap <- takeMVar mem
  m <- newMVar val
  putMVar mem (Map.insert loc m shmap)
  
casShrMem :: Loc -> Val -> Val -> ShrMem -> IO (Maybe (Bool, Val))
casShrMem loc val1 val2 (ShrMem mem) = do
  shmap <- readMVar mem
  let v = (Map.lookup loc shmap)
  case v of
    Nothing -> do
      return (Nothing)
    Just(v) -> do
      v2 <- takeMVar v
      if v2 /= val1
        then do
          putMVar v v2
          return $ Just (False, v2)
        else do
          putMVar v val2 
          return $ Just (True, v2)
