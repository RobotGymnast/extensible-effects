module Utils where

import Control.Exception (ErrorCall, catch)
import Control.Monad
import Control.Monad.Trans.Control

import System.IO.Silently
import Data.Tuple (swap)

import Test.HUnit hiding (State)

-- | capture stdout
-- [[https://stackoverflow.com/a/11128420][source]]
catchOutput :: IO a -> IO (a, String)
catchOutput f = swap `fmap` capture f

withError :: a -> ErrorCall -> a
withError a _ = a

assertUndefined :: a -> Assertion
assertUndefined a = catch (seq a $ assertFailure "") (withError $ return ())

assertNoUndefined :: a -> Assertion
assertNoUndefined a = catch (seq a $ return ()) (withError $ assertFailure "")

assertOutput :: String -> [String] -> String -> Assertion
assertOutput msg expected actual = assertEqual msg expected (lines actual)

runAsserts :: (String -> a -> e -> Assertion) -> [(String, e, a)] -> Assertion
runAsserts run cases = forM_ cases $ \(prop, test, res) -> run prop res test

allEqual :: Eq a => [a] -> Bool
allEqual = all (uncurry (==)) . pairs
  where
    pairs l = zip l $ tail l

safeLast :: [a] -> Maybe a
safeLast [] = Nothing
safeLast l = Just $ last l

add :: Monad m => m Int -> m Int -> m Int
add = liftM2 (+)

doThing :: MonadBaseControl b m => m a -> m a
doThing = liftBaseOp_ go
  where
    go :: Monad m => m a -> m a
    go a = return () >> a
