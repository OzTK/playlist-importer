module SelectableList exposing
    ( ListWithSelection
    , SelectableList
    , clear
    , filterMap
    , find
    , fromList
    , hasSelection
    , isSelected
    , map
    , mapBoth
    , mapSelected
    , mapWithStatus
    , rest
    , select
    , selectFirst
    , selected
    , toList
    , upSelect
    )


type ListWithSelection a
    = Selection a (List a)


type SelectableList a
    = Selected (ListWithSelection a)
    | NotSelected (List a)



-- Public


fromList : List a -> SelectableList a
fromList list =
    NotSelected list


toList : SelectableList a -> List a
toList sList =
    case sList of
        Selected (Selection _ list) ->
            list

        NotSelected list ->
            list


select : a -> SelectableList a -> SelectableList a
select el sList =
    let
        list =
            toList sList
    in
    if List.member el list then
        Selected <| Selection el list

    else
        NotSelected list


selectFirst : (a -> Bool) -> SelectableList a -> SelectableList a
selectFirst predicate sList =
    let
        list =
            toList sList
    in
    List.foldl
        (\el selection ->
            case selection of
                Selected (Selection _ _) ->
                    selection

                NotSelected l ->
                    if predicate el then
                        Selected <| Selection el l

                    else
                        selection
        )
        (NotSelected list)
        list


upSelect : (a -> a) -> a -> SelectableList a -> SelectableList a
upSelect updater element sList =
    let
        list =
            toList sList

        updated =
            updater element
    in
    list
        |> List.map
            (\el ->
                if el /= element then
                    el

                else
                    updated
            )
        |> Selection updated
        |> Selected


clear : SelectableList a -> SelectableList a
clear sList =
    NotSelected (toList sList)


selected : SelectableList a -> Maybe a
selected sList =
    case sList of
        Selected (Selection el _) ->
            Just el

        NotSelected _ ->
            Nothing


isSelected : a -> SelectableList a -> Bool
isSelected item list =
    case list of
        Selected (Selection selection _) ->
            item == selection

        NotSelected _ ->
            False


rest : SelectableList a -> SelectableList a
rest sList =
    case sList of
        Selected (Selection sel list) ->
            NotSelected <| List.filter ((/=) sel) list

        noSelection ->
            noSelection


hasSelection : SelectableList a -> Bool
hasSelection sList =
    sList |> selected |> (/=) Nothing


map : (a -> b) -> SelectableList a -> SelectableList b
map f sList =
    case sList of
        Selected (Selection el list) ->
            Selected <| Selection (f el) (List.map f list)

        NotSelected list ->
            NotSelected <| List.map f list


mapWithStatus : (el -> Bool -> newEl) -> SelectableList el -> SelectableList newEl
mapWithStatus f sList =
    case sList of
        Selected (Selection el list) ->
            Selected <|
                Selection (f el True) <|
                    List.map
                        (\elem ->
                            if elem == el then
                                f elem True

                            else
                                f elem False
                        )
                        list

        NotSelected list ->
            NotSelected <| List.map (\elem -> f elem False) list


filterMap : (el -> Maybe newEl) -> SelectableList el -> SelectableList newEl
filterMap f sList =
    case sList of
        Selected (Selection el list) ->
            f el
                |> Maybe.map (\elem -> Selected <| Selection elem (List.filterMap f list))
                |> Maybe.withDefault (NotSelected <| List.filterMap f list)

        NotSelected list ->
            NotSelected <| List.filterMap f list


mapSelected : (a -> a) -> SelectableList a -> SelectableList a
mapSelected f sList =
    case sList of
        Selected (Selection el _) ->
            upSelect f el sList

        _ ->
            sList


mapBoth : (a -> b) -> (a -> b) -> SelectableList a -> SelectableList b
mapBoth fSelected fUnselected sList =
    case sList of
        Selected (Selection sel list) ->
            Selected
                (Selection (fSelected sel) <|
                    List.map
                        (\el ->
                            if el == sel then
                                fSelected el

                            else
                                fUnselected el
                        )
                        list
                )

        NotSelected list ->
            NotSelected <| List.map fUnselected list


find : (a -> Bool) -> SelectableList a -> Maybe a
find predicate sList =
    sList |> toList |> List.filter predicate |> List.head
