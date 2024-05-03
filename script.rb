# frozen_string_literal: true

# 12 rounds of guessing
# 6 colors
# code is 4 long with a specific order
# after every guess, there has to be an indicator
#   correct = black/colored indicator (*)
#   correct color, wrong place = white indicator (o)
#   else = nothing or (x)
#   show an array with indicators with shuffle called so indicator doesn't give away info
#   eg: code: [r, r, g, c] guess: [r, g, b, b]
#       indicator: [*, o, x, x] indicator.shuffle: [x, o, x, *]

# module to contain all the code necessary for the game
module Mastermind
  COLORS = %w[red green blue magenta cyan yellow].freeze
  # game class that holds methods related to interactivity and playing the game
  class Game
    attr_reader :maker, :breaker

    def initialize
      determine_maker
      @round = 1
      @guess = []
      play_round
    end

    def determine_maker
      puts 'Would you like to be the codemaker? Y/N'
      answer = gets.chomp
      determine_maker unless answer.match(/y|n/i)
      if answer[0].match(/y/i)
        create_board(Human, Computer)
      elsif answer[0].match(/n/i)
        create_board(Computer, Human)
      end
    end

    def create_board(maker, breaker)
      @maker = maker.new(self)
      @breaker = breaker.new(self)
      puts "Codemaker: #{@maker}\nCodebreaker: #{@breaker}"
      puts "\n"
      secret_code_maker
    end

    def secret_code_maker
      @secret_code = maker.instance_of?(Computer) ? @maker.sc_generator : @maker.sc_getter
      puts show_code if maker.instance_of?(Human)
    end

    def play_round
      puts show_code
      while @round < 13
        puts "Round #{@round} guess: #{guess_getter}"
        # puts "--------Round #{@round}--------"
        puts check_guess(@secret_code == @guess)
        break if @secret_code == @guess

        @round += 1
      end
    end

    def check_guess(comparison)
      if comparison
        "#{breaker} guessed the #{show_code} in #{@round} round(s)!"
      elsif rounds_left.zero?
        "That was the last round :(\nHere's the #{show_code}"
      else
        "That wasn't it. Please try again! #{rounds_left} guesses left!"
      end
    end

    def rounds_left
      13 - (@round + 1)
    end

    def guess_getter
      @guess = breaker.make_guess
    end

    def show_code
      "secret code: #{@secret_code}"
    end
  end

  # player class
  class Player
    def initialize(game)
      @game = game
    end
  end

  # human class to hold all user information and methods
  class Human < Player
    def sc_getter
      puts "#{COLORS}\nPlease choose 4.\nDuplicates are allowed.\nFirst character only!"
      code = []
      do_four_times(code)
    end

    def checked_color_input
      color = gets.chomp
      if color[0].match(/r|g|b|m|c|y/i)
        color[0]
      else
        checked_color_input
      end
    end

    def make_guess
      puts 'Please guess the secret code.'
      puts "#{COLORS}\nPlease choose 4.\nDuplicates are allowed.\nFirst character only!"
      guess = []
      do_four_times(guess)
    end

    def do_four_times(arr)
      0.upto(3) { |i| arr[i] = checked_color_input }
      arr
    end

    def to_s
      'Human'
    end
  end

  # computer class to hold all computer player information and methods
  class Computer < Player
    def sc_generator
      code = []
      do_four_times(code)
    end

    def make_guess
      guess = []
      do_four_times(guess)
    end

    def do_four_times(arr)
      0.upto(3) { |i| arr[i] = COLORS[rand(0..5)][0] }
      arr
    end

    def to_s
      'Computer'
    end
  end
end

Mastermind::Game.new
# a = Mastermind::Game.new
# a.show_code
# puts a.maker
# puts a.breaker
# p Mastermind::Board.new.maker
# Mastermind::Computer.new.sc_generator
