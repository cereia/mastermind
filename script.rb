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
  COLORS = %w[blue cyan green magenta red yellow].freeze
  # game class that holds methods related to interactivity and playing the game
  class Game
    attr_reader :maker, :breaker, :round, :indicator
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
      if answer.match(/y/i)
        create_board(Human)
      elsif answer.match(/n/i)
        create_board(Computer)
      else
        determine_maker
      end
    end

    def create_board(maker)
      @maker = maker.new(self)
      @breaker = @maker.instance_of?(Human) ? Computer.new(self) : Human.new(self)
      puts "Codemaker: #{@maker}\nCodebreaker: #{@breaker}"
      puts "\n"
      @secret_code = @maker.instance_of?(Computer) ? @maker.sc_generator : @maker.sc_getter
      puts show_code if @maker.instance_of?(Human)
    end

    def play_round
      while @round < 13
        puts "Round #{@round} guess: #{breaker.make_guess}"
        show_guess_and_secret_code_comparison_result(@secret_code == @guess)
        puts "\n"
        break if @secret_code == @guess

        @round += 1
      end
      restart
    end

    def show_guess_and_secret_code_comparison_result(comparison)
      if comparison
        puts "#{breaker} guessed the #{show_code} in #{@round} round(s)!"
      elsif rounds_left.zero?
        puts "That was the last round :(\nHere's the #{show_code}"
      else
        create_indicator
        puts "*: correct\no: correct color\nx: incorrect\nIndicator: #{@indicator}"
        breaker.count_num_of_elements_in_indicator if breaker.instance_of?(Computer)
        puts "That wasn't it. Please try again! #{rounds_left} guesses left!"
      end
    end

    # create indicator checks for exact matches first before checking for other matches
    def create_indicator
      code = @secret_code.dup
      guess = @guess.dup
      exact_matches(code, guess)
      non_exact_matches(code, guess)
      @indicator.shuffle!
    end

    def exact_matches(sc_dup, guess_dup)
      @indicator = []
      guess_dup.each_index do |index|
        if guess_dup[index] == @secret_code[index]
          @indicator.push('*')
          guess_dup[index] = nil
          sc_dup[index] = nil
        end
        next
      end
    end

    def non_exact_matches(sc_dup, guess_dup)
      guess_dup.compact.each do |element|
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
        Game.new
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
    def initialize(game)
      super(game)
      @saved_guesses = []
      @num_wrong = 0
      @num_okay = 0
      @num_perfect = 0
      @all_colors_found = false
      @possibilities = []
      create_possibilities_array
    end

    def create_possibilities
      arr = []
      i = 0
      while arr.length < COLORS.length
        arr.push COLORS[i][0]
        i += 1
      end
      arr
    end

    def create_possibilities_array
      0.upto(3) { |i| @possibilities[i] = create_possibilities }
    end

    def sc_generator
      arr = []
      0.upto(3) { |i| arr[i] = COLORS[rand(0..5)][0] }
      arr
    end

    # if indicator shows all x -> remove letter(s) from all possibilities
    # if indicator shows xo/oo -> remove letter(s) from possibilities of letter's current index
    #   [rrgg] -> [xoox] -> remove r from 1 and 2; remove g from 3 and 4
    # if indicator shows *x/** -> remove letter(s) from possibilities that aren't letter's index
    #   [rrgg] -> [**xx] -> remove r from 3/4; remove g from 1/2

    # after removing possibilities/first 3 guesses: has to pick a certain number of colors per pair
    # code = [rggc]
    # [bbcc] -> [xxx*] -> pick 1 color
    # [ggmm] -> [*oxx] -> pick 2 colors
    # [rryy] -> [*xxx] -> pick 1 color
    # guess 4 ex: [bggy] -> alphabetical and follows pick rules

    def make_guess
      if @game.round < 4 && @all_colors_found == false
        @game.guess = first_three_guesses[@game.round - 1]
      # elsif @all_colors_found == true
      #   check_guess_against_saved_guesses(@game.guess.shuffle!)
      else
        picked = pick_4_colors_from_possibilities(@game.guess)
        check_guess_against_saved_guesses(picked)
      end
    end

    def check_guess_against_saved_guesses(guess)
      if @saved_guesses.include?(guess)
        # @game.guess = @game.guess.shuffle
        picked = pick_4_colors_from_possibilities(@game.guess)
        check_guess_against_saved_guesses(picked)
      else
        puts 'saved guesses:'
        @saved_guesses.map { |i| puts "#{i}\n" }
        guess
      end
    end

    def count_num_of_elements_in_indicator
      @num_wrong = count_num_of_element('x')
      @num_okay = count_num_of_element('o')
      @num_perfect = count_num_of_element('*')
      remove_possibilities_if_all_wrong_or_no_wrong
      remove_possibilities_if_okay_and_no_perfect
      puts "x's #{@num_wrong}\no's #{@num_okay}\n*'s #{@num_perfect}"
      puts 'possibilities:'
      @possibilities.each_index { |i| puts "#{i}: #{@possibilities[i]}\n" }
    end

    def count_num_of_element(indicator_symbol)
      @game.indicator.count { |element| element.include?(indicator_symbol)}
    end

    def remove_possibilities_if_all_wrong_or_no_wrong
      if @num_wrong == 4
        # remove the guess colors from the possibilities array
        @possibilities = @possibilities.map { |possibility_arr| possibility_arr - @game.guess.uniq }
      elsif @num_wrong.zero?
        @all_colors_found = true
        @saved_guesses.push(@game.guess.dup)
        # remove all except the guess colors from the possibilities array
        @possibilities = @possibilities.map { |possibility_arr| @game.guess.uniq & possibility_arr }
      end
    end

    def remove_possibilities_if_okay_and_no_perfect
      return unless @num_okay.positive? && @num_perfect.zero?

      @possibilities.each_index { |index| @possibilities[index].delete(@game.guess[index]) }
    end

    def first_three_guesses
      guesses = []
      i = 0
      while i < COLORS.length - 1
        guesses.push([COLORS[i][0], COLORS[i][0], COLORS[i + 1][0], COLORS[i + 1][0]])
        i += 2
      end
      guesses
    end

    def pick_4_colors_from_possibilities(arr)
      0.upto(3) { |i| arr[i] = @possibilities[i][rand(0..@possibilities[i].length - 1)] }
      arr
    end

    def to_s
      'Computer'
    end
  end
end

Mastermind::Game.new
