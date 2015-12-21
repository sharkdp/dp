module Main where

import Prelude

import Control.Apply

import Data.Array
import Data.Foldable (foldMap)
import Data.String (joinWith, toUpper, split)
import Data.Monoid (mempty)
import Data.Int (toNumber)

import qualified Text.Smolder.HTML as H
import qualified Text.Smolder.Markup as H

import Math

import Signal.DOM

import Flare
import Flare.Drawing
import Flare.Smolder


-- Example 1

ui1 = (int "a" 6) * (int "b" 7)
-- or: ui1 = lift2 (*) (int "a" 6) (int "b" 7)


-- Example 2

greet :: String -> String
greet name = "Hello, " ++ fancy name ++ "!"
  where fancy = toUpper >>> split "" >>> joinWith "."

ui2 = map greet (string "Your name:" "Nemo")


-- Example 3

coloredCircle :: Number -> Number -> Drawing
coloredCircle hue radius =
  filled (fillColor (hsl hue 0.8 0.4)) (circle 50.0 50.0 radius)

ui3 = lift2 coloredCircle (numberSlider "Hue"    0.0 360.0 1.0 140.0)
                          (numberSlider "Radius" 2.0  45.0 0.1  25.0)


-- Example 4

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
        style true = shadowColor black <> shadowOffset 2.0 2.0 <> shadowBlur 2.0

ui4 = lift3 plot (intSlider "Leaves" 2 10 6)
                 (boolean "Shadow" false)
                 (lift animationFrame)


-- Example 5

ui5 = foldp (+) 0 (button "Increment" 0 1)

-- Example 6

table :: Int -> Int -> H.Markup
table h w = H.table $ foldMap row (0 .. h)
  where row i = H.tr $ foldMap (cell i) (0 .. w)
        cell i j = H.td (H.text (show i ++ "," ++ show j))

ui6 = lift2 table (intSlider "Height" 0 9 5)
                  (intSlider "Width" 0 9 5)


-- Run and attach to DOM:

main = do
  runFlareShow    "controls1" "output1" ui1
  runFlare        "controls2" "output2" ui2
  runFlareDrawing "controls3" "output3" ui3
  runFlareDrawing "controls4" "output4" ui4
  runFlareShow    "controls5" "output5" ui5
  runFlareHTML    "controls6" "output6" ui6
