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
      @secret_code = @maker.instance_of?(Computer) ? @maker.sc_generator([]) : @maker.sc_getter
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
        puts "is sc still here? #{breaker.possibilities.include?(@secret_code)} #{breaker.possibilities.index(@secret_code)}" if breaker.instance_of?(Computer) # for testing only
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
    attr_reader :possibilities # for testing only  => to check that code is still in possibilities array

    def initialize(game)
      super(game)
      @num_okay = 0
      @num_perfect = 0
      @num_wrong = 0
      @saved_combos = []
      @all_colors_found = false
      @possibilities = create_possibilities_array
      puts @possibilities.length # 1296 possibilities in total
      # puts "poss: #{@possibilities}"
    end

    def create_possibilities_array
      arr = Array(1111..6666)
      arr.map! do |arr_of_nums|
        arr_of_nums.to_s.split('')
                   .map do |num_string|
                     COLORS[num_string.to_i - 1][0] if num_string.to_i < 7 && !num_string.to_i.zero?
                   end
      end
      arr.reject { |poss| poss.include?(nil)}
    end

    def sc_generator(arr)
      0.upto(3) { |i| arr[i] = COLORS[rand(0..5)][0] }
      arr
    end

    def make_guess
      if @game.round < 4 && @all_colors_found == false
        first_3_guesses(@game.round - 1)
      else
        @game.guess = @possibilities.sample(1).flatten
      end
      @possibilities.reject! { |poss| poss == @game.guess }
      @game.guess
    end

    def count_num_of_elements_in_indicator
      @num_wrong = count_num_of_element('x')
      @num_okay = count_num_of_element('o')
      @num_perfect = count_num_of_element('*')
      remove_possibilities_based_on_num_wrong
      remove_possibilities_if_okay_and_no_perfect if @num_okay.positive? && @num_perfect.zero?
      @all_colors_found = true if @num_wrong.zero?
      puts "num of possibilities left: #{@possibilities.length}"
    end

    def count_num_of_element(indicator_symbol)
      @game.indicator.count { |element| element.include?(indicator_symbol)}
    end

    def remove_possibilities_based_on_num_wrong
      # reject possibilities depending on how many wrong colors there are in the guess
      guess = @game.guess.dup
      @possibilities.reject! do |poss|
        if @num_wrong == 4
          guess.any? { |color| poss.include?(color) }
        elsif @num_wrong.positive?
          poss.all? { |color| poss.count(color) <= guess.count(color) }
        else
          !poss.all? { |color| poss.count(color) <= guess.count(color) }
        end
      end
    end

    def remove_possibilities_if_okay_and_no_perfect
      @saved_combos = save_combos_to_remove
      # puts "saved: #{@saved_combos}"
      @possibilities.reject! do |poss|
        @saved_combos.include?(poss)
      end
    end

    def save_combos_to_remove
      hash = create_hash_of_colors_and_indices
      combos = []
      @possibilities.map do |poss|
        poss.each_with_index do |color, idx|
          next unless !hash[color].nil? && hash[color].include?(idx)

          combos.push(poss)
        end
        combos.uniq!
      end
      combos
    end

    def create_hash_of_colors_and_indices
      # create a hash that contains the color letters and respective indices of the current guess
      @game.guess.each_with_object({}) do |value, result|
        arr = []
        @game.guess.each_index { |idx| result[value] = arr.push(idx) if value == @game.guess[idx] }
        result
      end
    end

    def first_3_guesses(index)
      guesses = []
      COLORS.each_slice(2) do |color1, color2|
        guesses.push([color1[0], color1[0], color2[0], color2[0]])
      end
      @game.guess = guesses[index]
    end

    def to_s
      'Computer'
    end
  end
end

Mastermind::Game.new
