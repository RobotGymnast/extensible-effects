{-# OPTIONS_GHC -Werror #-}
{-# LANGUAGE TypeOperators, GADTs, DataKinds #-}
{-# LANGUAGE FlexibleContexts #-}

-- | Example usage of "Control.Eff1"
module Control.Eff.Example where

import Control.Eff
import Data.OpenUnion51
import Data.FTCQueue1

import Control.Eff.State.Lazy
import Control.Eff.Writer.Lazy


-- | Write the elements of a list of numbers, in order.
writeAll :: (Member (Writer a) e)
         => [a]
         -> Eff e ()
writeAll = mapM_ tell

-- | Add a list of numbers to the current state.
sumAll :: (Num a, Member (State a) e)
       => [a]
       -> Eff e ()
sumAll = mapM_ (modify . (+))

-- | Write a list of numbers and add them to the current state.
writeAndAdd :: (Member (Writer a) e, Member (State a) e, Num a)
            => [a]
            -> Eff e ()
writeAndAdd l = do
    writeAll l
    sumAll l

-- | Sum a list of numbers.
sumEff :: (Num a) => [a] -> a
sumEff l = let ((), s) = run $ runState (sumAll l) 0
           in s

-- | Safely get the last element of a list.
-- Nothing for empty lists; Just the last element otherwise.
lastEff :: [a] -> Maybe a
lastEff l = let ((), a) = run $ runLastWriter $ writeAll l
            in a


-- | Get the last element and sum of a list
lastAndSum :: (Num a) => [a] -> (Maybe a, a)
lastAndSum l = let (((), total), lst) = run $ runLastWriter $ runState (writeAndAdd l) 0
               in (lst, total)


-- Example by Oscar Key
data Move x where
  Move :: Move ()

handUp :: Eff (Move ': r) a -> Eff r a
handUp (Val x) = return x
handUp (E u q) = case decomp u of
  Right Move -> handDown $ qApp q ()
  -- Relay other requests
  Left u0     -> E u0 (tsingleton Val) >>= handUp . qApp q

handDown :: Eff (Move ': r) a -> Eff r a
handDown (Val x) = return x
handDown (E u q) = case decomp u of
  Right Move -> handUp $ qApp q ()
  -- Relay other requests
  Left u0     -> E u0 (tsingleton Val) >>= handDown . qApp q
