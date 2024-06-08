# frozen_string_literal: true

# human class to hold all user information and methods
class Human < Player
  def sc_getter
    puts "#{COLORS}\nPlease choose 1-4.\nDuplicates are allowed.\nFirst character only!"
    puts 'ex: br and brbr are accepted and equal brbr'
    @game.guess = check_color_inputs
  end

  # gets the colors the user wants to use and turns it from a string into a sanitized array
  # then take the sanitized array and create a new array of 4 elements to use as the code
  def check_color_inputs
    colors = gets.chomp.split('')
    colors.select! { |color| color.match?(/b|c|g|m|r|y/i) }
    if colors.length.positive?
      checked_arr = []
      colors.map { |color| checked_arr.push(color) } while checked_arr.length < 4
      checked_arr = checked_arr[0..3]
    else
      check_color_inputs
    end
  end

  def make_guess
    puts 'Please guess the secret code.'
    puts "Color list: #{COLORS}\nPlease choose 4.\nDuplicates are allowed.\nFirst character only!"
    @game.guess = check_color_inputs
  end

  def to_s
    'Human'
  end
end
