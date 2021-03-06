module App.Components.Homepage where

import Prelude
import Effect (Effect)
import Effect.Aff (launchAff_)
import React.DOM.Props as Props
import React as React
import React.DOM as RDom

import App.Data.Actions (login) as Action
import App.Data.ActionTypes (Counting(..), Dogs(..), LiftedAction, Login(..))
import App.Data.RootReducer (reducer)
import App.Data.Types (DogState(..), State)
import Radox (lift)
import Radox.React

type HomepageProps
  = { title :: String }

homepage :: React.ReactClass HomepageProps
homepage = React.component "homepage" component
  where
    component this = do
          pure $ { state: { }
                 , render: reducer.consumer this render 
                 }

render :: ReactRadoxRenderMethod HomepageProps State {} LiftedAction
render all@{ dispatch, state, props } =
  RDom.div [] [ iterator dispatch state
              , login dispatch state
              , dogPicture dispatch state
              , React.createLeafElement fireEventFirstTime 
                  { dispatch: dispatch
                  , action: lift $ Up
                  } 
              ]

type FireProps
  = { dispatch :: LiftedAction -> Effect Unit
    , action   :: LiftedAction
    }

fireEventFirstTime :: React.ReactClass FireProps
fireEventFirstTime = React.component "fire" component
  where
    component this = do
       pure $ { state: { }
              , componentDidMount: do
                  props <- React.getProps this
                  props.dispatch props.action
              , render: pure mempty
              }

iterator :: (LiftedAction -> Effect Unit) -> State -> React.ReactElement
iterator dispatch state 
  = RDom.p [ Props.onClick (\_ -> dispatch (lift Up)) ] 
    [ RDom.text (show state.value) ] 

login :: (LiftedAction -> Effect Unit) -> State -> React.ReactElement
login dispatch state 
  = RDom.div [ ] [ button, label ]
  where
    button 
      = RDom.button 
          [ Props.onClick (\_ 
              -> do
                if state.loggedIn == false
                  then
                    launchAff_ $ Action.login dispatch "Hello" "World"
                  else
                    dispatch (lift Logout)) 
          ] 
          [ RDom.text (if state.loggedIn then "Logout" else "Login" )] 
    label 
      = RDom.p [] [ RDom.text (buttonText state) ]

buttonText :: State -> String
buttonText state
  | state.loggedIn == true = "Logged in!"
  | state.loggingIn == true = "Logging in..."
  | otherwise = "Not logged in"

dogPicture :: (LiftedAction -> Effect Unit) -> State -> React.ReactElement
dogPicture dispatch state
  = RDom.div [] [ fetchButton, image ]
  where
    fetchButton
      = RDom.button
          [ Props.onClick (\_ -> dispatch $ lift $ LoadNewDog ) ]
          [ RDom.text "fetch!" ]
    image
      = case state.dog of
          NotTried -> RDom.div [] []
          LookingForADog -> RDom.div [] [ RDom.text "Fetching..." ]
          FoundADog url -> RDom.div [] [ RDom.img [ Props.src url ] ]
          CouldNotFindADog -> RDom.div [] [ RDom.text "Sorry, could not find a good boy" ]
