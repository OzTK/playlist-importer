module Graphics.Plug exposing (connected, disconnected)

import Browser
import Element exposing (Color)
import Element.Extra as Element
import Html exposing (Html)
import Main
import Svg exposing (animateTransform, defs, g, style, svg, text)
import Svg.Attributes exposing (attributeName, begin, calcMode, d, dur, enableBackground, end, fill, from, id, keySplines, keyTimes, origin, to, transform, type_, version, viewBox, x, y)


connected : Color -> Html msg
connected c =
    svg
        [ x "0px"
        , y "0px"
        , version "1.1"
        , viewBox "-43 59 86 23"
        , fill (Element.toHex c)
        ]
        [ g [ transform "rotate(45)" ]
            [ Svg.path [ d "M79.858,20.143c-0.777-0.778-2.037-0.778-2.814,0L61.877,35.309c-1.901-1.335-4.156-2.062-6.527-2.062 c-3.045,0-5.907,1.186-8.061,3.34l-5.619,5.618l-5.619,5.619c-2.153,2.153-3.339,5.017-3.339,8.062c0,2.37,0.727,4.625,2.06,6.525 L20.141,77.043c-0.777,0.777-0.777,2.037,0,2.814c0.389,0.389,0.898,0.583,1.407,0.583s1.019-0.194,1.407-0.583l14.632-14.632 c1.901,1.334,4.155,2.062,6.526,2.062c3.045,0,5.907-1.185,8.061-3.337l5.619-5.622l5.619-5.618 c3.963-3.965,4.382-10.142,1.276-14.585l15.17-15.168C80.637,22.18,80.637,20.92,79.858,20.143z M49.359,61.136 c-1.4,1.399-3.264,2.17-5.246,2.17s-3.846-0.771-5.248-2.173c-1.402-1.401-2.173-3.265-2.173-5.246 c0-1.982,0.772-3.846,2.173-5.248l4.212-4.211l5.247,5.246l5.247,5.247L49.359,61.136z M60.598,49.896l-4.212,4.211L45.892,43.612 l4.212-4.211c1.402-1.401,3.266-2.174,5.246-2.174c1.982,0,3.846,0.772,5.248,2.174C63.489,42.295,63.489,47.001,60.598,49.896z" ] []
            ]
        ]


disconnected : Color -> Html msg
disconnected c =
    svg
        [ x "0px"
        , y "0px"
        , enableBackground "new 0 0 100 100"
        , version "1.1"
        , viewBox "-43 59 86 23"
        , fill (Element.toHex c)
        ]
        [ g [ transform "rotate(45)" ]
            [ g []
                [ Svg.path [ d "M79.859,20.143c-0.778-0.777-2.037-0.777-2.815,0l-9.222,9.223c-1.901-1.334-4.156-2.061-6.527-2.061 c-3.046,0-5.909,1.186-8.061,3.34l-5.621,5.619c-0.374,0.373-0.583,0.879-0.583,1.406s0.209,1.035,0.583,1.408l13.308,13.309 c0.39,0.389,0.898,0.582,1.408,0.582c0.509,0,1.019-0.193,1.407-0.582l5.621-5.619c3.962-3.965,4.38-10.141,1.275-14.584 l9.227-9.227C80.637,22.18,80.637,20.92,79.859,20.143z M66.543,43.953l-4.214,4.211L51.835,37.67l4.215-4.211 c1.4-1.402,3.264-2.174,5.245-2.174c1.982,0,3.846,0.773,5.248,2.174C69.434,36.354,69.434,41.059,66.543,43.953z" ] []
                , Svg.path [ d "M51.213,52.229l-4.352,4.352l-3.441-3.44l4.351-4.351c0.778-0.777,0.778-2.037,0-2.814c-0.777-0.777-2.036-0.777-2.814,0 l-4.351,4.351l-2.12-2.12c-0.777-0.777-2.037-0.777-2.814,0l-5.619,5.619c-3.964,3.965-4.383,10.141-1.276,14.585l-8.635,8.634 c-0.777,0.777-0.777,2.037,0,2.814c0.389,0.389,0.898,0.584,1.407,0.584c0.51,0,1.019-0.195,1.408-0.584l8.632-8.631 c1.9,1.334,4.154,2.061,6.525,2.061c3.045,0,5.907-1.186,8.062-3.34l5.619-5.619c0.777-0.777,0.777-2.037,0-2.814l-2.118-2.119 l4.352-4.352c0.777-0.777,0.777-2.037,0-2.814S51.99,51.451,51.213,52.229z M43.36,67.133c-1.402,1.4-3.266,2.174-5.247,2.174 s-3.845-0.773-5.247-2.174c-2.893-2.893-2.893-7.6,0-10.494l4.211-4.211l10.494,10.494L43.36,67.133z" ] []
                ]
            ]
        ]
