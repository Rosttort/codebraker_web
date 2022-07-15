# frozen_string_literal: true

module Lib
  module Entities
    class Game
      include Lib::Modules::WebHelper

      def self.call(env)
        new(env).responce
      end

      def initialize(request)
        @request = request
        @game = @request.session[:game]
        @guess_number = @request.session[:guess_number]
        @guess_result = @request.session[:guess_result]
        @hints = @request.session[:hints]
        @errors = []
      end

      def responce
        case @request.path
        when Router::COMMANDS[:guess] then guess_number
        when Router::COMMANDS[:hint] then hint
        when Router::COMMANDS[:lose] then lose
        when Router::COMMANDS[:win] then win
        else respond(PAGES[:game])
        end
      rescue Codebraker::Errors::InvalidGuessError => e
        assign_errors(e)
      end

      private

      def guess_number
        return respond(PAGES[:game]) unless @request.params['number']
        
        @guess_number = @request.params['number']
        @request.session[:guess_number] = @guess_number
        @guess_result = @game.check_guess(@guess_number)
        @request.session[:check_guess] = @guess_result
        case check_guess[:status]
        when :win then win
        when :lost then lose
        else respond(PAGES[:game])
        end
      end

      def win
        Lib::RatingConsole.add_data(@game.to_h)
        @request.session.clear
        respond(PAGES[:win])
      end

      def lose
        @request.session.clear
        respond(PAGES[:lose])
      end

      def guess_marker
        check_guess.empty? ? '' : check_guess[:answer].chars
      end

      def check_guess
        @request.session[:check_guess] || {}
      end

      def no_match_result
        @request.session[:result] = @guess_result
        respond(PAGES[:game])
      end

      def hint
        return respond(PAGES[:main]) unless game_exist?

        @hints = @request.session[:hints] || []
        @hints << @game.give_hint
        @request.session[:hints] = @hints
        respond(PAGES[:game])
      end

      def game_exist?
        @request.session[:game]
      end

      def assign_errors(error)
        @errors << error.message
        respond(PAGES[:game])
      end
    end
  end
end
