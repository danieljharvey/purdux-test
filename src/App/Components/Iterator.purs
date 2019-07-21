module App.Components.Iterator where

import Prelude (Unit, bind, pure, show, ($), (-), (<), (<>))
import Data.Array (intercalate)
import Data.Functor (map)
import Effect (Effect)
import React.DOM.Props as Props
import React as React
import React.DOM as RDom

import App.Data.ActionTypes (Counting(..), LiftedAction)
import Radox (lift)

import PursUI (CSSRuleSet, CSSSelector(..), PursUI, addStyle, createBlankStyleSheet, fun, str)

type IteratorProps
  = { value :: Int
    , dispatch :: (LiftedAction -> Effect Unit)
    }

getColor :: Int -> String
getColor 1 = "red"
getColor 2 = "yellow"
getColor 3 = "green"
getColor i = if i < 1 then "white" else getColor (i - 3)

iteratorStyle :: CSSRuleSet IteratorProps
iteratorStyle
  =  str """
       font-size: 20px;
       line-height: 1.5;
       padding: 20px;
       background-color: darkgrey;
     """
  <> fun (\i -> "color: " <> getColor i.value)

iterator 
  :: React.ReactClass IteratorProps
iterator = React.component "iterator" component
  where
    component this = do
      (stylesheet :: PursUI "dogshit") <- createBlankStyleSheet 
      pure $ { state: {}
             , render: do
                props <- React.getProps this
                classes <- addStyle stylesheet iteratorStyle props
                pure (renderIter classes props)
             }

    renderIter classes props
      = RDom.p 
          [ Props.className (toClassNames classes)
          , Props.onClick (\_ -> props.dispatch (lift Up)) 
          ] 
          [ RDom.text (show props.value) ] 

toClassNames :: Array CSSSelector -> String
toClassNames as
  = intercalate " " $ map unwrap as
  where
    unwrap (CSSClassSelector s) = s
