module Connection.Selection
    exposing
        ( WithProviderSelection(..)
        , noSelection
        , select
        , importing
        , importDone
        , isSelected
        , setData
        , providerType
        , connection
        , map
        , data
        )

import Http
import RemoteData exposing (WebData, RemoteData(NotAsked, Success))
import Connection.Provider exposing (ConnectedProvider(..))
import Playlist exposing (Playlist)


type WithProviderSelection providerType data
    = NoProviderSelected
    | Selected (ConnectedProvider providerType) (RemoteData Http.Error data)
    | Importing (ConnectedProvider providerType) (RemoteData Http.Error data) Playlist


noSelection : WithProviderSelection providerType data
noSelection =
    NoProviderSelected


select : ConnectedProvider providerType -> WithProviderSelection providerType data
select connection =
    Selected connection NotAsked


importDone : WithProviderSelection providerType data -> WithProviderSelection providerType data
importDone selection =
    case selection of
        Importing con data _ ->
            Selected con data

        _ ->
            selection


importing : WithProviderSelection providerType data -> Playlist -> WithProviderSelection providerType data
importing selection playlist =
    case selection of
        Selected connection data ->
            Importing connection data playlist

        _ ->
            selection


isSelected : WithProviderSelection providerType data -> Bool
isSelected selection =
    case selection of
        NoProviderSelected ->
            False

        _ ->
            True


data : WithProviderSelection providerType data -> Maybe (RemoteData Http.Error data)
data selection =
    case selection of
        Selected _ data ->
            Just data

        _ ->
            Nothing


setData : WithProviderSelection providerType data -> RemoteData Http.Error data -> WithProviderSelection providerType data
setData selection data =
    case selection of
        Selected con _ ->
            Selected con data

        _ ->
            selection


providerType : WithProviderSelection providerType data -> Maybe providerType
providerType selection =
    case selection of
        Selected (ConnectedProvider pType) _ ->
            Just pType

        Selected (ConnectedProviderWithToken pType _ _) _ ->
            Just pType

        _ ->
            Nothing


connection : WithProviderSelection providerType data -> Maybe (ConnectedProvider providerType)
connection selection =
    case selection of
        Selected provider _ ->
            Just provider

        _ ->
            Nothing


map : (a -> a) -> WithProviderSelection providerType a -> WithProviderSelection providerType a
map f selection =
    case selection of
        Selected con (Success d) ->
            Selected con (Success (f d))

        _ ->
            selection
