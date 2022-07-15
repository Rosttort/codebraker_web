# frozen_string_literal: true

module Lib
  module Modules
    module DataLoader
      def save_data(data)
        File.open(Modules::Constants::DATA_FILE, 'a') { |file| file.write(data.to_yaml) }
      end

      def load_data
        return [] unless File.exist?(Modules::Constants::DATA_FILE)

        YAML.load_stream(File.read(Modules::Constants::DATA_FILE)).map { |record| record } || []
      end
    end
  end
end
