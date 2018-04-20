extensible-effects is based on the work
[Extensible Effects: An Alternative to Monad Transformers](http://okmij.org/ftp/Haskell/extensible/).
Please read the [paper](http://okmij.org/ftp/Haskell/extensible/exteff.pdf) and
the followup [freer paper](http://okmij.org/ftp/Haskell/extensible/more.pdf) for
details. Additional explanation behind the approach can be found on [Oleg's website](http://okmij.org/ftp/Haskell/extensible/).

[![Build Status](https://travis-ci.org/suhailshergill/extensible-effects.svg?branch=master)](https://travis-ci.org/suhailshergill/extensible-effects)
[![Join the chat at https://gitter.im/suhailshergill/extensible-effects](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/suhailshergill/extensible-effects?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Stories in Ready](https://badge.waffle.io/suhailshergill/extensible-effects.png?label=ready&title=Ready)](http://waffle.io/suhailshergill/extensible-effects)
[![Stories in progress](https://badge.waffle.io/suhailshergill/extensible-effects.png?label=in%20progress&title=In%20progress)](http://waffle.io/suhailshergill/extensible-effects)

## Advantages

  * Effects can be added, removed, and interwoven without changes to code not
    dealing with those effects.

## Limitations

### Current implementation only supports GHC version 7.8 and above
This is not a fundamental limitation of the design or the approach, but there is
an overhead with making the code compatible across a large number of GHC
versions. If this is needed, patches are welcome :)

### Ambiguity-Flexibility tradeoff

The extensibility of `Eff` comes at the cost of some ambiguity. A useful pattern
to mitigate the ambiguity is to specialize the call to the handler of effects
using [type application](https://ghc.haskell.org/trac/ghc/wiki/TypeApplication)
or type annotation. Examples of this pattern can be seen in
[Example/Test.hs](./test/Control/Eff/Example/Test.hs).

Note, however, that the extensibility can also be traded back, but that detracts
from some of the advantages. For details see section 4.1 in the
[paper](http://okmij.org/ftp/Haskell/extensible/exteff.pdf).

Some examples where the cost of extensibility is apparent:

  * Common functions can't be grouped using typeclasses, e.g.
    the `ask` and `getState` functions can't be grouped with some

    ```haskell
    class Get t a where
      ask :: Member (t a) r => Eff r a
    ```

    `ask` is inherently ambiguous, since the type signature only provides
    a constraint on `t`, and nothing more. To specify fully, a parameter
    involving the type `t` would need to be added, which would defeat the
    point of having the grouping in the first place.
  * Code requires greater number of type annotations. For details see
    [#31](https://github.com/suhailshergill/extensible-effects/issues/31).
