module Tape exposing
    ( Tape
    , forward
    , fromList
    , goLeft
    , goRight
    , hasLeft
    , hasRight
    , mapHead
    , popLeft
    , popRight
    , read
    , rewind
    , single
    , toList
    , write
    )


type Tape a
    = Tape (List a) a (List a)


single : a -> Tape a
single x =
    Tape [] x []


fromList : a -> List a -> Tape a
fromList x lst =
    case lst of
        [] ->
            single x

        y :: ys ->
            Tape [] y ys


toList : Tape a -> List a
toList (Tape left a right) =
    List.reverse left ++ (a :: right)


goRight : Tape a -> Tape a
goRight (Tape left x right) =
    case right of
        [] ->
            Tape left x right

        y :: ys ->
            Tape (x :: left) y ys


goLeft : Tape a -> Tape a
goLeft (Tape left x right) =
    case left of
        [] ->
            Tape left x right

        y :: ys ->
            Tape ys y (x :: right)


hasRight : Tape a -> Bool
hasRight (Tape left x right) =
    not (List.isEmpty right)


hasLeft : Tape a -> Bool
hasLeft (Tape left x right) =
    not (List.isEmpty left)


popRight : Tape a -> ( Maybe a, Tape a )
popRight (Tape left x right) =
    case right of
        [] ->
            ( Nothing, Tape left x right )

        y :: ys ->
            ( Just y, Tape (x :: left) y ys )


popLeft : Tape a -> ( Maybe a, Tape a )
popLeft (Tape left x right) =
    case left of
        [] ->
            ( Nothing, Tape left x right )

        y :: ys ->
            ( Just y, Tape ys y (x :: right) )


rewind : Tape a -> Tape a
rewind (Tape left x right) =
    case left of
        [] ->
            Tape left x right

        y :: ys ->
            rewind (Tape ys y (x :: right))


forward : Tape a -> Tape a
forward (Tape left x right) =
    case right of
        [] ->
            Tape left x right

        y :: ys ->
            rewind (Tape (x :: left) y ys)


read : Tape a -> a
read (Tape left x right) =
    x


write : a -> Tape a -> Tape a
write y (Tape left x right) =
    Tape left y right


mapHead : (a -> a) -> Tape a -> Tape a
mapHead f (Tape left x right) =
    Tape left (f x) right
