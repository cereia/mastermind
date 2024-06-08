# frozen_string_literal: true

# computer class to hold all computer player information and methods
class Computer < Player
  def initialize(game)
    super(game)
    @num_okay = 0
    @num_perfect = 0
    @num_wrong = 0
    @saved_combos = []
    @all_colors_found = false
    @possibilities = create_possibilities_array
  end

  # create an array of all 1296 possible combinations using numbers then repalce those numbers with color letters
  def create_possibilities_array
    arr = Array(1111..6666)
    arr.map! do |arr_of_nums|
      arr_of_nums.to_s.split('')
                  .map do |num_string|
                    COLORS[num_string.to_i - 1][0] if num_string.to_i < 7 && !num_string.to_i.zero?
                  end
    end
    arr.reject { |poss| poss.include?(nil) }
  end

  # pick a possibility from possibilities array to act as code
  def sc_generator
    @possibilities.sample(1).flatten
  end

  def make_guess
    if @game.round < 4 && @all_colors_found == false
      # first 3 rounds are guaranteed to be 1 of 3 guesses unless certain conditions are met
      first_3_guesses(@game.round - 1)
    else
      @game.guess = sc_generator
    end
    # remove the current guess from possibilities array
    @possibilities.reject! { |poss| poss == @game.guess }
    @game.guess
  end

  def count_and_remove_based_on_num_of_elements_in_indicator
    @num_wrong = count_num_of_element('x')
    @num_okay = count_num_of_element('o')
    @num_perfect = count_num_of_element('✓')
    remove_based_on_num_wrong
    remove_if_okay_and_no_perfect if @num_okay.positive? && @num_perfect.zero?
    remove_based_on_num_of_colors_matched_in_guess if (@num_okay + @num_perfect).positive? && @num_wrong.positive?
    @all_colors_found = true if @num_wrong.zero?
  end

  def count_num_of_element(indicator_symbol)
    @game.indicator.count { |element| element.include?(indicator_symbol) }
  end

  def remove_based_on_num_wrong
    # reject possibilities depending on how many wrong colors there are in the guess
    guess = @game.guess.dup
    @possibilities.reject! do |poss|
      if @num_wrong == 4
        # remove if the possibility contains any element of the guess when all guess colors are wrong
        guess.any? { |color| poss.include?(color) }
      elsif @num_wrong.positive?
        # remove if the possibility contains all elements of the guess when some guess colors are wrong
        contains_all?(poss, guess)
      else
        # remove if the possibility does not contain every element of the guess when all guess colors are right
        !contains_all?(poss, guess)
      end
    end
  end

  # returns true if the possibility contains all elements of the guess
  def contains_all?(possibility, guess)
    possibility.all? { |color| possibility.count(color) <= guess.count(color) }
  end

  def remove_if_okay_and_no_perfect
    @saved_combos = save_combos_to_remove
    @possibilities.reject! do |poss|
      @saved_combos.include?(poss)
    end
  end

  # create array of possibilities that need to be removed based on okay marks and 0 perfects
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

  def remove_based_on_num_of_colors_matched_in_guess
    # remove the possibility if the possibility doesn't match the number of okay and perfects in the current guess
    # guess [bcmy] has 2 right colors => keep: [ymgg] remove: [grgm]
    num_of_ok_and_perfect = @num_okay + @num_perfect
    @possibilities.select! { |poss| (poss - @game.guess).length <= 4 - num_of_ok_and_perfect }
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
