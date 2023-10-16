-- | Assignment 1: implementing various small functions
module A01
  ( Day(..)
  , nextWeekday
  , addTuple
  , productDot
  , maybeMap
  , maybeThen
  , Tree(..)
  , sumTree
  , rightRotateTree
  , listSum
  , productSeq
  , setMem
  , setEquiv
  , setUnion
  , setIntersection
  , setDiff
  , setSymDiff
  , relMem
  , relEquiv
  , relComp
  , relTrans
  , relFull
  , fibs
  , primes
  , fuzzySeq
  , funComp
  , curry2
  , uncurry2
  , myFilter
  , myFilterMap
  , myFoldL
  , myRev
  ) where

-- | TODO marker.
todo :: t
todo = error "todo"

-- | Days of week.
data Day = Sunday | Monday | Tuesday | Wednesday | Thursday | Friday | Saturday deriving (Eq, Show)

-- | Returns the next weekday (excluding weekend, namely Saturday and Sunday).
nextWeekday :: Day -> Day
nextWeekday Monday = Tuesday 
nextWeekday Tuesday  = Wednesday
nextWeekday Wednesday  = Thursday
nextWeekday Thursday  = Friday 
nextWeekday Friday = Monday
nextWeekday Saturday = Monday
nextWeekday Sunday  = Monday

-- | Add tuples of the 2-dimensional plane.
addTuple :: (Integer, Integer) -> (Integer, Integer) -> (Integer, Integer)
addTuple t1 t2 = (fst(t1)+fst(t2),snd(t1)+snd(t2))

-- | Dot-products two integer (list) vectors: https://en.wikipedia.org/wiki/Dot_product
-- |
-- | If the two vectors have different number of elements, you can return anything.
productDot :: [Integer] -> [Integer] -> Integer
productDot t1 t2 | (length t1) /= (length t2) = 0
productDot [] [] = 0
productDot (h1:t1) (h2:t2) = h1*h2 + productDot t1 t2

-- | Maps the given value if it's Just.
maybeMap :: (Integer -> Integer) -> Maybe Integer -> Maybe Integer
maybeMap f (Just v) = Just (f v) 
maybeMap f Nothing = Nothing

-- | If the given value is Just, map it with the given function; otherwise, the result is Nothing.
maybeThen :: Maybe Integer -> (Integer -> Maybe Integer) -> Maybe Integer
maybeThen (Just v) cont = cont v
maybeThen Nothing cont = Nothing

-- | Trees of integers.
data Tree = Leaf Integer | Branch Integer Tree Tree deriving (Eq, Show) -- Integer is value, Trees are left/right subtrees.

-- | Sums all the integers in the given tree.
sumTree :: Tree -> Integer
sumTree (Leaf leaf) = leaf
sumTree (Branch br t1 t2) = br + sumTree(t1) + sumTree(t2) 

-- | Right-rotate the given tree. See https://en.wikipedia.org/wiki/Tree_rotation for more detail.
-- |
-- | Returns Nothing if there are not enough nodes.
rightRotateTree :: Tree -> Maybe Tree
rightRotateTree (Branch b1 (Branch b2 lt2 rt2) t) = Just (Branch b2 lt2 (Branch b1 rt2 t))
rightRotateTree t = Nothing

-- | Maps the given list.
listMap = map

-- | Sums all the integers in the given list.
listSum :: [Integer] -> Integer
listSum [] = 0
listSum (hd:tl) = hd + listSum(tl)

-- | More compositional construction of sigma.
sumSeq :: (Integer -> Integer) -> Integer -> Integer -> Integer
sumSeq f from to = listSum (listMap f [from .. to])

listMult :: [Integer] -> Integer
listMult [] = 1
listMult (hd:tl) = hd * listMult(tl)

-- | product of a sequence. See https://en.wikipedia.org/wiki/Multiplication#Product_of_a_sequence for more detail.
productSeq :: (Integer -> Integer) -> Integer -> Integer -> Integer
productSeq f from to = listMult (listMap f [from .. to])

-- | Returns if the given value is in the (list) set.
setMem :: Integer -> [Integer] -> Bool
setMem value [] = False
setMem value (hd:tl) = (value == hd) || (setMem value tl)

-- | Returns the two sets contain the same elements.
setEquiv :: [Integer] -> [Integer] -> Bool
setEquiv [] [] = True
setEquiv s1 [] = False
setEquiv [] s2 = False
setEquiv s1 s2 = (setEq s1 s2) && (setEq s2 s1)
  where 
    setEq [] [] = True
    setEq (h1:t1) [] = True
    setEq [] (h2:t2) = True
    setEq s1@(h1:t1) s2 = (setMem h1 s2) && (setEq t1 s2)
 
-- | Returns the set union.
setUnion :: [Integer] -> [Integer] -> [Integer]
setUnion s1 s2 = s1 ++ s2

-- | Returns the set intersection
setIntersection :: [Integer] -> [Integer] -> [Integer]
setIntersection s1 s2 = (setInt s1 s2)
  where 
      setInt [] [] = []
      setInt (h1:t1) [] = []
      setInt [] (h2:t2) = []
      setInt s1@(h1:t1) s2 = if (setMem h1 s2) then [h1] ++ (setInt t1 s2) else (setInt t1 s2)

-- | Returns the set diff, i.e., setDiff a b = $a - b$.
setDiff :: [Integer] -> [Integer] -> [Integer]
setDiff s1 s2 = (setDif s1 (setIntersection s1 s2))
  where 
      setDif [] [] = []
      setDif s1 [] = s1
      setDif [] s2 = []
      setDif s1@(h1:t1) s2 = if (setMem h1 s2) then [] ++ (setDif t1 s2) else [h1] ++ (setDif t1 s2)

-- | Returns the set symmetric diff.
setSymDiff :: [Integer] -> [Integer] -> [Integer]
setSymDiff s1 s2 = setUnion (setDiff s1 s2) (setDiff s2 s1)

-- | Returns if the given pair is in the (list) relation.
relMem :: [(Integer, Integer)] -> Integer -> Integer -> Bool
relMem [] v1 v2 = False
relMem (hd:tl) v1 v2 = (fst(hd) == v1) && (snd(hd) == v2) || (relMem tl v1 v2)

-- | Returns the two relations contain the same elements.
relEquiv :: [(Integer, Integer)] -> [(Integer, Integer)] -> Bool
relEquiv [] [] = True
relEquiv [] r2 = False 
relEquiv r1 [] = False
relEquiv r1 r2 = (relEq r1 r2) && (relEq r2 r1)
  where 
    relEq :: [(Integer, Integer)] -> [(Integer, Integer)] -> Bool
    relEq [] [] = True
    relEq (h1:t1) [] = True
    relEq [] (h2:t2) = True
    relEq r1@((hf,hs):t1) r2= (relMem r2 hf hs) && (relEq t1 r2)

-- | Composes two relations, i.e., {(a,c) | exists b, (a,b) in r1 and (b,c) in r2}.
relComp :: [(Integer, Integer)] -> [(Integer, Integer)] -> [(Integer, Integer)]
relComp [] [] = []
relComp r1 [] = []
relComp [] r2 = []
relComp r1@(h1:t1) r2 = (find h1 r2) ++ (relComp t1 r2)
  where
    find :: (Integer, Integer) -> [(Integer, Integer)] -> [(Integer, Integer)]
    find v [] = []
    find v r2@(h:t) = if (fst(h) == snd(v)) then [(fst(v),snd(h))] ++ (find v t) else [] ++ (find v t)

relUnion :: [(Integer, Integer)] -> [(Integer, Integer)] -> [(Integer, Integer)]
relUnion r1 r2 = r1 ++ r2

-- | Returns the transitive closure of the given relation: https://en.wikipedia.org/wiki/Transitive_closure
relTrans :: [(Integer, Integer)] -> [(Integer, Integer)]
relTrans rel = getTrans rel rel
  where
    getTrans :: [(Integer, Integer)] -> [(Integer, Integer)] -> [(Integer, Integer)]
    getTrans rsum ri = if (relEquiv (relUnion rsum (relComp ri rel)) rsum) then rsum else (getTrans (relUnion rsum (relComp ri rel)) (relComp ri rel))
    
-- | Returns the relation [0..n] * [0..n] = {(0,0), (0,1), ..., (0,n), (1,0), (1,1), ..., (1,n), ..., (n,n)}.
relFull :: Integer -> [(Integer, Integer)]
relFull n = relTrans(go 0 [])
  where 
    go i s | i > n = s
    go i s = go (i + 1) (s ++ (go2 0 i []) )
    go2 j k s | j > n = s
    go2 j k s = go2 (j + 1) k (s ++ [(k,j)])

-- | The Fibonacci sequence, starting with 0, 1, 1, 2, 3, ...
fibs :: [Integer]
fibs = fib 0 1
  where 
    fib :: Integer->Integer->[Integer]
    fib n m = [n] ++ (fib m (n+m)) 

isPrime :: Integer->Integer-> Bool
isPrime n i | n > i = if (rem n i == 0) then False else (isPrime n (i+1))  
isPrime n i | n == i = True

-- | The primes, starting with 2, 3, 5, 7, ...
primes :: [Integer]
primes = getPrimes 2
  where 
    getPrimes :: Integer->[Integer]
    getPrimes n = if (isPrime n 2) then [n]++ getPrimes(n+1) else [] ++ getPrimes(n+1)

-- | The sequence of 1, 2, 1, 3, 2, 1, 4, 3, 2, 1, 5, 4, 3, 2, 1, ...
fuzzySeq :: [Integer]
fuzzySeq = f2 1
  where 
    f2 :: Integer->[Integer]
    f2 n = f1 n ++ f2 (n+1)
    f1 :: Integer->[Integer]
    f1 n | n == 1 = [1]
    f1 n = [n] ++ f1 (n-1)

-- | Composes two functions, i.e., applies f1 and then f2 to the given argument
funComp :: (Integer -> Integer) -> (Integer -> Integer) -> (Integer -> Integer)
funComp f1 f2 = f
  where
    f :: (Integer -> Integer)
    f v = f2 (f1 v) 

-- | Transforms a function that gets single pair into a function that gets two arguments, i.e., curry2 f a1 a2 = f (a1, a2)
curry2 :: ((Integer, Integer) -> Integer) -> Integer -> Integer -> Integer
curry2 f a1 a2 = f (a1,a2)

-- | Transforms a function that gets two arguments into a function that gets single pair, i.e., uncurry2 f (a1, a2) = f a1 a2
uncurry2 :: (Integer -> Integer -> Integer) -> (Integer, Integer) -> Integer
uncurry2 f (a1, a2) = f a1 a2

-- | Filters the given list so that the the filter function returns True for the remaining elements.
myFilter :: (Integer -> Bool) -> [Integer] -> [Integer]
myFilter f [] = []
myFilter f (hd:tl) = if (f hd) == True then [hd] ++ (myFilter f tl) else [] ++ (myFilter f tl)

-- | Maps the given list. If the map function returns Nothing, just drop it.
myFilterMap :: (Integer -> Maybe Integer) -> [Integer] -> [Integer]
myFilterMap f [] = []
myFilterMap f (hd:tl) = (f2 (f hd)) ++ (myFilterMap f tl) 
  where 
    f2 :: Maybe Integer -> [Integer]
    f2 (Just v) = [v]
    f2 Nothing = []

-- | Folds the list from the left, i.e., myFoldL init f [l1, l2, ..., ln] = (f (f (f (f init l1) l2) ...) ln).
myFoldL :: Integer -> (Integer -> Integer -> Integer) -> [Integer] -> Integer
myFoldL init f (hd:tl) = recf init hd tl
  where
    recf :: Integer -> Integer -> [Integer] -> Integer
    recf a b [] = f a b
    recf a b (h:t) = recf (f a b) h t 

-- | Reverses the given list.
myRev :: [Integer] -> [Integer]
myRev [] = []
myRev (hd:tl) = (myRev tl) ++ [hd]
