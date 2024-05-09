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
    attr_accessor :guess

    def initialize
      determine_maker
      @round = 1
      @guess = []
      play_round
    end

    def determine_maker
      puts 'Would you like to be the codemaker? Y/N'
      answer = gets.chomp
      if answer.match(/y|n/i)
        maker_input_checker(answer)
      else
        determine_maker
      end
    end

    def maker_input_checker(input)
      if input.match(/y/i)
        create_board(Human, Computer)
      else
        create_board(Computer, Human)
      end
    end

    def create_board(maker, breaker)
      @maker = maker.new(self)
      @breaker = breaker.new(self)
      puts "Codemaker: #{@maker}\nCodebreaker: #{@breaker}"
      puts "\n"
      @secret_code = @maker.instance_of?(Computer) ? @maker.sc_generator : @maker.sc_getter
      puts show_code if @maker.instance_of?(Human)
    end

    def play_round
      while @round < 13
        puts "Round #{@round} guess: #{breaker.make_guess}"
        puts check_guess(@secret_code == @guess)
        break if @secret_code == @guess

        @round += 1
      end
      restart
    end

    def check_guess(comparison)
      if comparison
        "#{breaker} guessed the #{show_code} in #{@round} round(s)!"
      elsif rounds_left.zero?
        "That was the last round :(\nHere's the #{show_code}"
      else
        create_indicator
        puts "*: correct\no: correct color\nx: incorrect\nIndicator: #{@indicator}"
        "That wasn't it. Please try again! #{rounds_left} guesses left!"
      end
    end

    # create indicator checks for exact matches first before checking for other matches
    def create_indicator
      code = @secret_code.dup
      exact_matches(code)
      non_exact_matches(code)
      @indicator.shuffle!
    end

    def exact_matches(sc_dup)
      @indicator = []
      @guess.each_index do |index|
        if @guess[index] == @secret_code[index]
          @indicator.push('*')
          @guess[index] = nil
          sc_dup[index] = nil
        end
        next
      end
    end

    def non_exact_matches(sc_dup)
      @guess.compact.each do |element|
        if sc_dup.include?(element)
          sc_dup[sc_dup.index(element)] = nil
          @indicator.push('o')
        else
          @indicator.push('x')
        end
      end
      @indicator
    end

    def restart
      puts 'Would you like to play again? Y/N'
      answer = gets.chomp
      restart unless answer.match(/y|n/i)
      if answer.match(/y/i)
        determine_maker
      elsif answer.match(/n/i)
        puts 'Thank you for playing!'
      end
    end

    def rounds_left
      13 - (@round + 1)
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
      do_four_times([])
    end

    def checked_color_input
      color = gets.chomp
      if color.match(/r|g|b|m|c|y/i)
        color[0]
      else
        checked_color_input
      end
    end

    def make_guess
      puts 'Please guess the secret code.'
      puts "#{COLORS}\nPlease choose 4.\nDuplicates are allowed.\nFirst character only!"
      do_four_times(@game.guess)
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
      do_four_times([])
    end

    def make_guess
      do_four_times(@game.guess)
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
