{-# LANGUAGE FlexibleContexts, NoMonomorphismRestriction #-}
{-# LANGUAGE TypeOperators, DataKinds #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell #-}

module Control.Eff.Trace.Test (testGroups) where

import Test.HUnit hiding (State)
import Control.Eff
import Control.Eff.Reader.Strict
import Control.Eff.Trace
import Utils

import Test.Framework.TH
import Test.Framework.Providers.HUnit

testGroups = [ $(testGroupGenerator) ]

case_Trace_tdup :: Assertion
case_Trace_tdup = do
  ((), actual) <- catchOutput tdup
  ((), actual') <- catchOutput tdup'
  assertEqual "Trace: duplicate layers" expected (lines actual)
  assertEqual "Trace: duplicate layers" expected (lines actual')
  where
    tdup = runTrace $ runReader (10::Int) m
    tdup' = runLift . runTrace' $ runReader (10::Int) m
    expected = ["Asked: 20", "Asked: 10"]
    m = do
        runReader (20::Int) tr
        tr
    tr = do
         v <- ask
         trace $ "Asked: " ++ show (v::Int)

case_Trace_tMd :: Assertion
case_Trace_tMd = do
  (actualResult, actualOutput) <- catchOutput tMd
  (actualResult', actualOutput') <- catchOutput tMd'
  assertEqual "Trace: higher-order effectful function"
    expected (actualResult, lines actualOutput)
  assertEqual "Trace: higher-order effectful function"
    expected (actualResult', lines actualOutput')
  where
    val = (10::Int)
    input = [1..5]
    expected = (map (+ val) input, map (("mapMdebug: " ++) . show) input)
    tMd = runTrace $ runReader val (mapMdebug f input)
    tMd' = runLift . runTrace' $ runReader val (mapMdebug f input)

    f x = ask `add` return x
    -- Higher-order effectful function
    -- The inferred type shows that the Trace affect is added to the effects
    -- of r
    mapMdebug:: (Show a, Member Trace r) =>
                (a -> Eff r b) -> [a] -> Eff r [b]
    mapMdebug _f [] = return []
    mapMdebug f (h:t) = do
      trace $ "mapMdebug: " ++ show h
      h' <- f h
      t' <- mapMdebug f t
      return (h':t')
