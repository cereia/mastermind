# frozen_string_literal: true

# 12 rounds of guessing
# 6 colors
# code is 4 long with a specific order
# after every guess, there has to be an indicator
#   correct = black/colored indicator
#   correct color, wrong place = white indicator
#   else = nothing

# module to contain all the code necessary for the game
module Mastermind
  COLORS = %w[red green blue magenta cyan yellow].freeze
  # board class to hold methods related directly to board
  class Board
    attr_reader :maker, :breaker

    def initialize(player1, player2)
      @maker = player1.new(self)
      @breaker = player2.new(self)
      puts "maker: #{maker} breaker: #{breaker}"
    end

    def secret_code
      @secret_code = maker.instance_of?(Computer) ? @maker.sc_generator : @maker.sc_getter
      puts "secret code check: #{@secret_code}"
      @secret_code
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
      0.upto(3) { |i| code[i] = checked_color_input }
      code
    end

    def checked_color_input
      color = gets.chomp
      if color[0].match(/r|g|b|m|c|y/i)
        color[0]
      else
        checked_color_input
      end
    end

    def to_s
      'Human'
    end
  end

  # computer class to hold all computer player information and methods
  class Computer < Player
    def sc_generator
      code = []
      0.upto(3) { |i| code[i] = COLORS[rand(0..5)][0] }
      code
    end

    def to_s
      'Computer'
    end
  end

  # game class that holds methods related to interactivity and playing the game
  class Game
    def initialize
      puts 'Would you like to be the codemaker? Y/N'
      answer = gets.chomp
      initialize unless answer.match(/y|n/i)
      if answer[0].match(/y/i)
        create_game(Human, Computer)
      elsif answer[0].match(/n/i)
        create_game(Computer, Human)
      end
    end

    def create_game(maker, breaker)
      board = Board.new(maker, breaker)
      board.secret_code
    end
  end
end

# Mastermind::Game.new
Mastermind::Game.new
# puts a.maker
# puts a.breaker
# p Mastermind::Board.new.maker
# Mastermind::Computer.new.sc_generator
