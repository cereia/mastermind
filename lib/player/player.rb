# frozen_string_literal: true

# player class
class Player
  require_relative 'human_cpu/cpu'
  require_relative 'human_cpu/human'
  COLORS = %w[blue cyan green magenta red yellow].freeze

  def initialize(game)
    @game = game
  end
end
