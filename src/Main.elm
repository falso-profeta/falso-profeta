module Main exposing (main)

import Browser
import Browser.Navigation as Nav exposing (Key)
import Config as Cfg
import Dict
import Html exposing (Html, div, text)
import Http
import Json.Decode as D
import Json.Encode exposing (Value)
import Pages.Intro as IntroPage
import Pages.Overview as OverviewPage
import Pages.Story as StoryPage
import Routes exposing (Route(..), parseUrl, toHref)
import Story exposing (Story, storyDecoder)
import Url exposing (Url)



-- import Debug
-- dbg x y = Debug.log (Debug.toString x) y
-- show x = Debug.log (Debug.toString x) x


dbg x y =
    y


show x =
    x


type Page
    = IntroPage
    | ErrorPage String
    | StoryPage StoryPage.Model
    | OverviewPage OverviewPage.Model


type alias Model =
    { page : Page
    , cfg : Cfg.Model
    }


type Msg
    = OnUrlChange Url
    | OnUrlRequest Browser.UrlRequest
    | OnConfigMsg Cfg.Msg
    | OnFetchStories (Result Http.Error (List Story))
    | OnPushUrl String
    | OnStoryMsg StoryPage.Msg
    | OnOverviewMsg OverviewPage.Msg
    | NoOp


pageFromRoute : Route -> Cfg.Model -> Page
pageFromRoute r cfg =
    case r of
        Intro ->
            IntroPage

        Error url ->
            ErrorPage url

        ViewStory key ->
            case Cfg.getStory key cfg of
                Just story ->
                    StoryPage (StoryPage.init story cfg)

                Nothing ->
                    ErrorPage key

        Overview ->
            OverviewPage (OverviewPage.init cfg)


init : Cfg.Model -> Model
init cfg =
    { page = IntroPage, cfg = cfg }


view : Model -> Html Msg
view m =
    case m.page of
        IntroPage ->
            IntroPage.view (OnPushUrl (Cfg.firstStory m.cfg |> Maybe.withDefault "final"))

        ErrorPage st ->
            div [] [ text ("error :" ++ st) ]

        StoryPage m_ ->
            Html.map OnStoryMsg (StoryPage.view m_)

        OverviewPage m_ ->
            Html.map OnOverviewMsg (OverviewPage.view m_)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg m =
    let
        m1 =
            dbg "msg" msg
    in
    case ( msg, m.page ) of
        -- Routing and generic navigation
        ( OnPushUrl st, _ ) ->
            ( m, Cfg.pushUrl st m.cfg )

        ( OnUrlRequest (Browser.Internal url), _ ) ->
            update (OnPushUrl (Url.toString url)) m

        ( OnUrlRequest (Browser.External url), _ ) ->
            ( m, Nav.load url )

        ( OnUrlChange url, _ ) ->
            ( { m | page = pageFromRoute (parseUrl url) m.cfg }, Cmd.none )

        -- Redirect to appropriate sub-model
        ( OnStoryMsg msg_, StoryPage m_ ) ->
            let
                ( page_, cmd ) =
                    StoryPage.update msg_ m_
            in
            ( { m | page = StoryPage page_ }, Cmd.map OnStoryMsg cmd )

        ( OnOverviewMsg msg_, OverviewPage m_ ) ->
            let
                ( page_, cmd ) =
                    OverviewPage.update msg_ m_
            in
            ( { m | page = OverviewPage page_ }, Cmd.map OnOverviewMsg cmd )

        -- Internal state and other global tasks
        ( OnConfigMsg msg_, _ ) ->
            ( { m | cfg = Cfg.update msg_ m.cfg }, Cmd.none )

        ( OnFetchStories (Ok sts), _ ) ->
            let
                new =
                    { m | cfg = m.cfg |> Cfg.setStories sts }
            in
            case new.page of
                ErrorPage url ->
                    ( new, Cfg.pushUrl url new.cfg )

                _ ->
                    ( new, Cmd.none )

        _ ->
            ( m, Cmd.none )


main : Program Value Model Msg
main =
    let
        fetchStories =
            Http.get
                { url = "./static/data.json"
                , expect = Http.expectJson OnFetchStories (D.list storyDecoder)
                }

        initFn flags url key =
            let
                ( m, cmd ) =
                    init (Cfg.init key)
                        |> update (OnUrlChange url)
            in
            ( m, Cmd.batch [ fetchStories, cmd ] )
    in
    Browser.application
        { init = initFn
        , update = update
        , subscriptions = \_ -> Sub.none
        , onUrlRequest = OnUrlRequest
        , onUrlChange = OnUrlChange
        , view = \m -> Browser.Document "Bolsonaro, o falso profeta" [ view m ]
        }
