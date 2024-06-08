# frozen_string_literal: true

# game class that holds methods related to interactivity and playing the game
class Game
  require_relative 'player/player'

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
    if answer.match?(/y/i)
      create_game(Human)
    elsif answer.match?(/n/i)
      create_game(Computer)
    else
      determine_maker
    end
  end

  def create_game(maker)
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
      sleep 1 if breaker.instance_of?(Computer)
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
      puts "✓: correct\no: correct color\nx: incorrect\nIndicator: #{@indicator}"
      breaker.count_and_remove_based_on_num_of_elements_in_indicator if breaker.instance_of?(Computer)
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

  # look for matches where color and index of the guess match the secret code
  def exact_matches(sc_dup, guess_dup)
    @indicator = []
    guess_dup.each_index do |index|
      if guess_dup[index] == @secret_code[index]
        @indicator.push('✓')
        guess_dup[index] = nil
        sc_dup[index] = nil
      end
      next
    end
  end

  # look for matches where color is correct, but index doesn't match the secret code's
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
    restart unless answer.match?(/y|n/i)
    if answer.match?(/y/i)
      Game.new
    elsif answer.match?(/n/i)
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
