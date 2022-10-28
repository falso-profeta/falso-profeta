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


searchRight : (a -> Bool) -> Tape a -> Maybe (Tape a)
searchRight pred (Tape left x right) =
    if pred x then
        Just (Tape left x right)

    else
        case right of
            [] ->
                Nothing

            y :: ys ->
                searchRight pred (Tape (x :: left) y ys)


searchLeft : (a -> Bool) -> Tape a -> Maybe (Tape a)
searchLeft pred (Tape left x right) =
    if pred x then
        Just (Tape left x right)

    else
        case left of
            [] ->
                Nothing

            y :: ys ->
                searchRight pred (Tape ys y (x :: right))


search : (a -> Bool) -> Tape a -> Maybe (Tape a)
search pred tape =
    case searchRight pred tape of
        Just t ->
            Just t

        Nothing ->
            searchLeft pred tape


hasRight : Tape a -> Bool
hasRight (Tape _ _ right) =
    not (List.isEmpty right)


hasLeft : Tape a -> Bool
hasLeft (Tape left _ _) =
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
            forward (Tape (x :: left) y ys)


read : Tape a -> a
read (Tape _ x _) =
    x


write : a -> Tape a -> Tape a
write y (Tape left _ right) =
    Tape left y right


mapHead : (a -> a) -> Tape a -> Tape a
mapHead f (Tape left x right) =
    Tape left (f x) right
