# frozen_string_literal: true

module Lib
  module Modules
    module Constants
      DATA_FILE = File.join(__dir__, '../data/rating.yml').freeze
      DIFFICULTY_RATING = {
        easy: 3,
        medium: 2,
        hard: 1
      }.freeze
    end
  end
end
