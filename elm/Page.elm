module Page exposing (Page, init, match, navigate, onNavigate)

import Connection exposing (ProviderConnection(..))
import Connection.Connected as ConnectedProvider exposing (ConnectedProvider, MusicService)
import Connection.Dict as ConnectionsDict exposing (ConnectionsDict)
import Dict.Any as Dict exposing (AnyDict)
import List.Connection as Connections
import MusicService exposing (MusicServiceError)
import Page.Request as Request
import Playlist exposing (Playlist)
import Playlist.Dict exposing (PlaylistKey, PlaylistsDict)
import Playlist.State exposing (PlaylistImportResult)
import RemoteData exposing (RemoteData(..), WebData)
import Task
import UserInfo exposing (UserInfo)


type Page
    = ServiceConnection
    | PlaylistsSpinner
    | PlaylistPicker
    | DestinationPicker PlaylistKey
    | TransferSpinner PlaylistKey ConnectedProvider
    | TransferReport PlaylistImportResult


type NavigationError
    = NotEnoughConnectedProviders Request.PageRequest
    | WaitingForLoadingPlaylists Request.PageRequest
    | PlaylistNotFound Request.PageRequest
    | MusicServiceNotFound Request.PageRequest


init : Page
init =
    ServiceConnection


match :
    { serviceConnection : a
    , playlistSpinner : a
    , playlistsPicker : a
    , destinationPicker : PlaylistKey -> a
    , transferSpinner : PlaylistKey -> ConnectedProvider -> a
    , transferComplete : PlaylistImportResult -> a
    }
    -> Page
    -> a
match matchers page =
    case page of
        ServiceConnection ->
            matchers.serviceConnection

        PlaylistsSpinner ->
            matchers.playlistSpinner

        PlaylistPicker ->
            matchers.playlistsPicker

        DestinationPicker playlist ->
            matchers.destinationPicker playlist

        TransferSpinner playlist connection ->
            matchers.transferSpinner playlist connection

        TransferReport result ->
            matchers.transferComplete result


navigate :
    Request.PageRequest
    -> { m | connections : ConnectionsDict, playlists : PlaylistsDict }
    -> Result NavigationError Page
navigate path model =
    case path of
        Request.ServiceConnection ->
            Ok <| ServiceConnection

        Request.PlaylistsSpinner ->
            tryPlaylistsSpinner model

        Request.PlaylistPicker ->
            tryPlaylistPicker model

        Request.DestinationPicker playlist ->
            tryDestinationPicker playlist model

        Request.TransferSpinner playlist destination ->
            tryTransferSpinner playlist destination model

        Request.TransferReport result ->
            Ok <| TransferReport result



-- Specific pages navigation


type alias WithServiceConnections m =
    { m | connections : ConnectionsDict }


type alias WithPlaylists m =
    { m | playlists : PlaylistsDict }


type alias WithPlaylistsAndConnections m =
    { m
        | connections : ConnectionsDict
        , playlists : PlaylistsDict
    }


tryTransferSpinner : PlaylistKey -> ConnectedProvider -> WithPlaylistsAndConnections m -> Result NavigationError Page
tryTransferSpinner playlistKey service ({ connections } as model) =
    model
        |> tryDestinationPicker playlistKey
        |> Result.andThen
            (\_ ->
                Dict.get (ConnectedProvider.type_ service) connections
                    |> Result.fromMaybe (MusicServiceNotFound (Request.TransferSpinner playlistKey service))
                    |> Result.map (\_ -> TransferSpinner playlistKey service)
            )


tryDestinationPicker : PlaylistKey -> WithPlaylists m -> Result NavigationError Page
tryDestinationPicker playlistKey { playlists } =
    playlists
        |> Dict.get playlistKey
        |> Maybe.map (\_ -> Ok <| DestinationPicker playlistKey)
        |> Maybe.withDefault (Err <| PlaylistNotFound (Request.DestinationPicker playlistKey))


tryPlaylistsSpinner : WithServiceConnections m -> Result NavigationError Page
tryPlaylistsSpinner { connections } =
    if hasAtLeast2Connected connections then
        Ok <| PlaylistsSpinner

    else
        Err <| NotEnoughConnectedProviders Request.PlaylistsSpinner


hasAtLeast2Connected : ConnectionsDict -> Bool
hasAtLeast2Connected connections =
    connections
        |> Dict.values
        |> List.map Tuple.first
        |> Connections.connectedProviders
        |> List.filter ConnectedProvider.hasUser
        |> List.length
        |> (<=) 2


tryPlaylistPicker : WithServiceConnections m -> Result NavigationError Page
tryPlaylistPicker { connections } =
    if connections |> Dict.values |> List.any isWaitingForPlaylists then
        Err <| WaitingForLoadingPlaylists Request.PlaylistPicker

    else
        Ok <| PlaylistPicker


isWaitingForPlaylists : ( ProviderConnection, WebData (List PlaylistKey) ) -> Bool
isWaitingForPlaylists service =
    case service of
        ( Connected _, Success _ ) ->
            False

        ( Disconnected _, _ ) ->
            False

        _ ->
            True



-- Navigation handlers


type alias NavigationHandlers msg =
    { userInfoReceivedHandler : ConnectedProvider -> WebData UserInfo -> msg
    , playlistsFetchedHandler : ConnectedProvider -> Result MusicServiceError (WebData (List Playlist)) -> msg
    }


onNavigate : NavigationHandlers msg -> Page -> WithPlaylistsAndConnections m -> Cmd msg
onNavigate handlers page { connections } =
    case page of
        ServiceConnection ->
            connections
                |> ConnectionsDict.connections
                |> List.filterMap Connection.asConnected
                |> List.filter (ConnectedProvider.user >> Maybe.map (\_ -> False) >> Maybe.withDefault True)
                |> List.map (\c -> ( c, c |> MusicService.fetchUserInfo |> Task.onError (\_ -> Task.succeed NotAsked) ))
                |> List.map (\( c, t ) -> Task.perform (handlers.userInfoReceivedHandler c) t)
                |> Cmd.batch

        PlaylistsSpinner ->
            connections
                |> ConnectionsDict.connectedConnections
                |> List.map
                    (\con ->
                        con |> MusicService.loadPlaylists |> Task.attempt (handlers.playlistsFetchedHandler con)
                    )
                |> Cmd.batch

        _ ->
            Cmd.none
