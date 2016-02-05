module AbacusTrainer (Model, Action, init, effective_update, view) where

import Html exposing (div, li, ol, Html)
import Html.Events exposing (onClick)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Svg.Events exposing (..)
import Color exposing (..)
import Random exposing (..)
import Window


import Easing exposing (ease, easeOutBounce, float)
import Effects exposing (Effects)
import Time exposing (Time, second)

--import Task
--import StartApp.Simple exposing( start )

--MODEL

type alias Position = { x:Int, y:Int }

type alias AnimationState =
    Maybe { prevClockTime : Time, elapsedTime : Time }

type alias Model =
  { window_height: Int
  , window_width: Int
  , user_choice: Int
  , score: Int
  , rng  : Generator Int
  , target_number_and_seed : (Int, Seed)
  , ball_locations : List Position
  , correct_locations : List Position
  , needs_refresh : Bool
  , angle         : Float
  , x_offset      : Int
  , animationState : AnimationState
  }

initial_state: Model
initial_state =
  { window_height = 600
  , window_width = 2400
  , user_choice = 0
  , score = 0
  , rng = int 0 9
  , target_number_and_seed = (1,  initialSeed 314)
  , ball_locations = resetPositions (List.repeat 10 {x = 0, y = 0})
  , correct_locations = resetPositions (List.repeat 10 {x = 0, y = 0})
  , needs_refresh = False
  , angle         = 0
  , x_offset      = 0
  , animationState = Maybe.Nothing
  }

init : ( Model, Effects Action)
init =
  ( initial_state
  , Effects.none
  )

rotateStep = 90
duration = second

--UPDATE

type Action = ClickedRefresh | Reset | ClickedBall Int  | Tick Time | WindowSize ( Int, Int )


update : Action -> Model -> Model
update action current_state =
  case action of
    ClickedRefresh ->
      { current_state
        | target_number_and_seed =
            generate current_state.rng (snd current_state.target_number_and_seed)
        , user_choice = 0
        , ball_locations = resetPositions current_state.ball_locations
        , correct_locations = resetPositions current_state.ball_locations
        , needs_refresh = True
      }

    Reset ->
      { current_state
        | user_choice = 0
        , ball_locations = resetPositions current_state.ball_locations
        , correct_locations = resetPositions current_state.ball_locations
      }

    ClickedBall index ->
        if ( current_state.needs_refresh == True ) then
          if (index == (fst current_state.target_number_and_seed) ) then
            { current_state
              | user_choice = (index + 1)
              , score = current_state.score + 1
              , correct_locations =
                  (List.map shift_ball_left (List.take(index + 1) current_state.ball_locations)) ++ (List.drop (index + 1) current_state.ball_locations)
              , needs_refresh = False
            }
          else
            { current_state
              | user_choice = (index +  1)
              , score = current_state.score - 1
            }
        else
           current_state
    WindowSize ( w, h ) ->
           {current_state 
           | window_width  = w
           , window_height = h 
           } 
    Tick _ ->
           current_state



effective_update : Action -> Model -> (Model, Effects Action)
effective_update action current_state =
  case action of
    ClickedRefresh ->
      case current_state.animationState of
        Nothing ->
          ( update action current_state, Effects.none ) -- tick Tick )

        Just _ ->
          ( update action current_state, Effects.none )

    Reset ->
      case current_state.animationState of
        Nothing ->
          ( current_state, Effects.none ) -- tick Tick )

        Just _ ->
          ( update action current_state, Effects.none )

    ClickedBall index ->
      case current_state.animationState of
        Nothing ->
          ( update action current_state, Effects.tick Tick )

        Just _ ->
          ( update action current_state, Effects.none )
    
    WindowSize ( w, h ) ->
        case current_state.animationState of
          Nothing ->
            ( current_state, Effects.none ) -- tick Tick )
          Just _ ->
            ( update action current_state, Effects.none )

    Tick clockTime ->
      let
        newElapsedTime =
          case current_state.animationState of
            Nothing ->
              0

            Just {elapsedTime, prevClockTime} ->
              elapsedTime + (clockTime - prevClockTime)
      in
        if newElapsedTime > duration then
          ( 
            { current_state
              | angle          = current_state.angle + rotateStep
              , x_offset       = current_state.x_offset + rotateStep
              , animationState = Nothing  
            }
            , Effects.none
          )
        else
          ( 
            { current_state
              | angle          = current_state.angle
              , x_offset       = current_state.x_offset
              , animationState = Just { elapsedTime = newElapsedTime, prevClockTime = clockTime }
            }
            , Effects.tick Tick
          )


          


resetBallLocation : Int -> Position -> Position
resetBallLocation n ball =
  { ball | x = (n * 80 + 200), y = 60 }


resetPositions : List Position -> List Position
resetPositions current_postions =
  List.indexedMap resetBallLocation current_postions


shift_ball_left : Position -> Position
shift_ball_left ball =
  { ball | x = ball.x - 100 }


--VIEW

view : Signal.Address Action -> Model -> Html
view address_of_actions current_state =
  let 
    w = current_state.window_width
    h = current_state.window_height
  in
  div
    []
    [ div
        []
        [ renderGUI address_of_actions (w, h) current_state ]
    , div
        []
        [ ol
            []
            [ li
                []
                [ Html.text  "Click in the Green square to get a new target number to click." ]
            , li
                []
                [ Html.text  "Click on the ball with the number shown in the Green square " ]
            , li
                []
                [ Html.text  "The light Blue square indicates your score." ]
            , li
                []
                [ Html.text  "The numbers on the balls become smaller as you get more correct" ]
            , li
                []
                [ Html.text  "And they get bigger when you make mistakes." ]
            ]
        ]
   --, div[ Html.Events.onClick address Reset ] [ Html.text (toString current_state ) ]
    ]


renderGUI : Signal.Address Action  -> (Int, Int) -> Model -> Html.Html
renderGUI address_of_actions (w, h) current_state =
    let
      boardWidth  = Basics.min 1200 w |> toString
      boardHeight = Basics.min 240 h |> toString
    in
      svg
        [ width boardWidth
        , height boardHeight
        , viewBox ("0 0 " ++ boardWidth ++ " " ++ boardHeight)
        , fill "lightGray"
        ]
        (List.concat
          [ (ten_circles address_of_actions current_state)
          , [ target_area address_of_actions (w, h) current_state ]
          , [ score_area  address_of_actions (w, h) current_state ]
          ]
        )



target_area : Signal.Address Action  -> (Int, Int) -> Model -> Svg
target_area address_of_actions (w, h) current_state =
    g [ Svg.Events.onClick (Signal.message address_of_actions ClickedRefresh) ]
      [ rect
          [ x "0"
          , y "120"
          , width "120"
          , height "120"
          , rx "15"
          , ry "15"
          , fill "green"
          ]
          []
      , text'
          [ x "0"
          , y "160"
          , fontSize "55"
          ]
          [ text (toString (1 + fst current_state.target_number_and_seed))]
      ]
score_area : Signal.Address Action  -> (Int, Int) -> Model -> Svg
score_area address_of_actions (w, h) current_state =
    g [ Svg.Events.onClick (Signal.message address_of_actions ClickedRefresh) ]
      [
        rect
          [ x "550"
          , y "120"
          , width "120"
          , height "120"
          , rx "15"
          , ry "15"
          , fill "lightBlue"
          ]
          []
      , text'
          [ x "550"
          , y "160"
          , fontSize "55" ]
          [ text (toString ( current_state.score)) ]
      ]



toOffset : AnimationState -> Float
toOffset animationState =
  case animationState of
    Nothing ->
      0

    Just {elapsedTime} ->
      ease easeOutBounce Easing.float 0 rotateStep duration elapsedTime

cr30 ball_pair n labelSize current_state address_of_actions =
  let 
    cball = fst ball_pair
    rball = snd ball_pair    
    cxpos = cball.x |> toString 
    rxpos = rball.x |> toString 
    ypos  = rball.y |> toString 

    animoffset = toOffset current_state.animationState
    x_offset = 
        if cball.x == rball.x 
        then cxpos
        else  ( ( rball.x )  - ( round animoffset ) ) |> toString

    angle = ( current_state.angle + animoffset ) |> toString 
  in
    g
      [ transform ("translate( " ++ x_offset ++ ", " ++ ypos ++ " ) ") 
      , Svg.Events.onClick (Signal.message address_of_actions (ClickedBall n) )
      ]
      [ circle
          [ cx "" -- rxpos
          , cy ""
          , r "30"
          , fill "white"
          , Svg.Attributes.style "stroke:rgb(255,0,0);stroke-width:2"
          ]
          []
      , g [ ] -- transform ( "rotate(" ++ angle ++ "," ++ cxpos ++ "," ++ ypos ++ ")" ) ]
        [
          text'
              [ x "" -- rxpos
              , y ""
          , fontSize labelSize
          ]
          [ text (toString (n + 1)) ]
        ]
      ]


ten_circles : Signal.Address Action -> Model -> List Svg
ten_circles address_of_actions current_state =
    let
      labelSize = Basics.max 0 (30 - current_state.score)
      cx n ball_pair = cr30 ball_pair n (labelSize |> toString) current_state address_of_actions
      ball_pairs = List.map2 (,) current_state.correct_locations current_state.ball_locations
    in
      List.indexedMap cx ball_pairs


--SIGNALS

--actions : Signal.Mailbox Action
--actions = Signal.mailbox Reset


--WIRING

model : Signal Action -> Signal Model
model actions = Signal.foldp update initial_state actions

--main: Signal Html
--main =  Signal.map (view actions.address) (model ( Signal.merge actions.signal ( Signal.map WindowSize  Window.dimensions ) ) )


