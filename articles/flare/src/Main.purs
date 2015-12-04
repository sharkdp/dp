module Main where

import Prelude
import Control.Apply
import Control.Bind

import Data.Array
import Data.Foldable (fold)
import Data.String (joinWith, toUpper, split)
import Data.Maybe
import Data.Monoid (mempty)
import Data.Int (toNumber)

import qualified Text.Smolder.HTML as H
import qualified Text.Smolder.Markup as H

import Flare
import Flare.Drawing
import Flare.Smolder

import Math

import Signal.DOM

greet :: String -> String
greet name = "Hello, " ++ fancy name ++ "!"
  where fancy = toUpper >>> split "" >>> joinWith "."

coloredCircle :: Number -> Number -> Drawing
coloredCircle hue radius =
  filled (fillColor (hsl hue 0.8 0.4)) (circle 50.0 50.0 radius)

plot :: Int -> Boolean -> Number -> Drawing
plot n s time = shadow (style s) $
                  filled (fillColor (hsl 220.0 0.6 0.5)) $
                    path (map point angles)

  where point phi = { x: 50.0 + radius phi * cos phi
                    , y: 50.0 + radius phi * sin phi }
        angles = map (\i -> 2.0 * pi / toNumber points * toNumber i) (0 .. points)
        points = 200
        radius phi = 48.0 * abs (cos (0.5 * toNumber n * (phi + phi0)))
        phi0 = 0.001 * time
        style false = mempty
        style true = shadowStyle

shadowStyle = shadowColor black <> shadowOffset 2.0 2.0 <> shadowBlur 2.0

ui7 = lift3 plot (intSlider "Leaves" 2 10 6)
                 (boolean "Shadow" false)
                 (lift animationFrame)

toInt false = 0
toInt true = 1

table :: Int -> Int -> H.Markup
table h w = H.table $ fold (map row (0 .. h))
  where row i = H.tr (fold (map (cell i) (0 .. w)))
        cell i j = H.td (H.text (show i ++ "," ++ show j))

ui6 = lift2 table (intSlider "Height" 0 9 5)
                  (intSlider "Width" 0 9 5)

main = do
  runFlare "controls1" "output1" $
    (int "a" 6) * (int "b" 7)
    -- or: lift2 (*) (int "a" 6) (int "b" 7)

  runFlareS "controls2" "output2" $
    map greet (string "Your name:" "Nemo")

  runFlareDrawing "controls3" "output3" $
    lift2 coloredCircle (numberSlider "Hue"    0.0 360.0 1.0 140.0)
                        (numberSlider "Radius" 2.0  45.0 0.1  25.0)

  runFlareDrawing "controls4" "output4" ui7

  runFlare "controls5" "output5" $
    foldp (+) 0 (map toInt (button "Increment"))

  runFlareHTML "controls6" "output6" ui6
