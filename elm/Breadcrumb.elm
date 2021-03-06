module Breadcrumb exposing (baseDot, baseSegment, breadcrumb, dot, segment)

import Connection.Connected as ConnectedProvider exposing (ConnectedProvider)
import Dimensions exposing (dimensions)
import Element exposing (..)
import Element.Background as Bg
import Element.Border as Border
import Element.Font as Font
import Graphics.Palette exposing (palette)
import Html.Attributes as Html
import List.Extra as List
import Page exposing (Page)
import Page.Request
import Playlist.Dict
import Styles exposing (delayedTransition, transition)


baseDot : Int -> List (Element.Attribute msg) -> Element msg
baseDot size attrs =
    el
        ([ width (px size)
         , height (px size)
         , centerY
         , Border.rounded 8
         ]
            ++ attrs
        )
        Element.none


dot : Int -> Bool -> Element msg
dot size active =
    el
        [ height (px size)
        , inFront <|
            baseDot
                size
                [ Bg.color palette.primary
                , if active then
                    delayedTransition 0.2 "transform"

                  else
                    transition [ "transform" ]
                , Element.htmlAttribute (Html.classList [ ( "active-dot", active ), ( "inactive-dot", not active ) ])
                ]
        ]
        (baseDot (size - 2) [ Bg.color palette.primaryFaded ])


baseSegment : Int -> List (Element.Attribute msg) -> Element msg
baseSegment size attrs =
    el
        ([ height (px size)
         , width fill
         , centerY
         ]
            ++ attrs
        )
        Element.none


segment : Int -> Bool -> Element msg
segment size active =
    el
        [ width fill
        , height fill
        , inFront <|
            baseSegment size
                [ centerY
                , Bg.color palette.primary
                , Border.rounded 2
                , transition [ "transform" ]
                , Element.htmlAttribute (Html.classList [ ( "active-segment", active ), ( "inactive-segment", not active ) ])
                ]
        ]
    <|
        baseSegment (size - 1) [ Bg.color palette.primaryFaded ]


indexFromPage : Page -> Int
indexFromPage page =
    if Page.oneOf page [ Page.Request.ServiceConnection, Page.Request.PlaylistsSpinner ] then
        0

    else if Page.oneOf page [ Page.Request.PlaylistPicker, Page.Request.PlaylistDetails Playlist.Dict.anyKey ] then
        1

    else if Page.oneOf page [ Page.Request.DestinationPicker Playlist.Dict.anyKey, Page.Request.DestinationPicked Playlist.Dict.anyKey ConnectedProvider.any ] then
        2

    else if Page.is page <| Page.Request.TransferSpinner Playlist.Dict.anyKey ConnectedProvider.any then
        3

    else
        4


breadcrumb : List (Element.Attribute msg) -> { m | device : Element.Device, page : Page } -> Element msg
breadcrumb attrs model =
    let
        d =
            dimensions model

        { labelWidth, paddingX, fontSize, dotSize, segSize } =
            case ( model.device.class, model.device.orientation ) of
                ( Phone, Portrait ) ->
                    { labelWidth = 75, paddingX = 30, fontSize = d.xxSmallText, dotSize = 10, segSize = 4 }

                _ ->
                    { labelWidth = 170, paddingX = 78, fontSize = d.smallText, dotSize = 15, segSize = 5 }

        index =
            indexFromPage model.page

        bigSpot =
            dot dotSize True

        fadedSpot =
            dot dotSize False

        items =
            [ bigSpot ]
                :: List.repeat index [ segment segSize True, bigSpot ]
                ++ List.repeat (3 - index) [ segment segSize False, fadedSpot ]
    in
    row
        ([ spaceEvenly
         , htmlAttribute (Html.style "z-index" "0")
         , above <| row [ paddingXY paddingX 10, width fill ] (List.flatten items)
         ]
            ++ attrs
        )
    <|
        List.indexedMap
            (\i s ->
                el
                    [ width (px labelWidth)
                    , Font.center
                    , if i == index then
                        delayedTransition 0.2 "color"

                      else
                        transition [ "color" ]
                    , if i > index then
                        Font.color palette.textFaded

                      else
                        Font.color palette.text
                    , fontSize
                    ]
                    (text s)
            )
            [ "Connect", "Pick playlist", "Pick destination", "Transfer" ]
