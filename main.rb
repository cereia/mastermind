# frozen_string_literal: true

# 12 rounds of guessing
# 6 colors
# code is 4 long with a specific order
# after every guess, there has to be an indicator
#   correct = black/colored indicator (✓)
#   correct color, wrong place = white indicator (o)
#   wrong = nothing or (x)
#   show an array with indicators with shuffle called so indicator doesn't give away info
#   eg: code: [r, r, g, c] guess: [r, g, b, b]
#       indicator: [✓, o, x, x] indicator.shuffle: [x, o, x, ✓]

# module to contain all the code necessary for the game
require_relative 'lib/game'

Game.new
