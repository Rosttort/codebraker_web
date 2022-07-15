# frozen_string_literal: true

RSpec.describe Lib::Entities::Router do
  def app
    Rack::Builder.parse_file('./config.ru').first
  end

  let(:name) { Faker::Name.first_name }
  let(:level) { Codebraker::Constants::DIFFICULTIES.keys.sample  }
  let(:game) { Codebraker::Game.new(name, level) }
  let(:guess_number) { Codebraker::Validation::CODE_MIN.to_s * Codebraker::Constants::CODE_LENGTH }

  describe 'access to pages through menu' do
    context 'when unknown page' do
      before { get '/unknown' }

      it 'receives page 404' do
        expect(last_response).to be_not_found
      end
    end

    context 'when gets to /' do
      before { get Lib::Entities::Router::COMMANDS[:menu] }

      it 'receives menu page' do
        expect(last_response).to be_ok
      end
    end

    context 'when choosed statistic page' do
      before { get Lib::Entities::Router::COMMANDS[:statistics] }

      it 'shows title for statistic page' do
        expect(last_response.body).to include(I18n.t(:top_of_players))
      end
    end

    context 'when choosed rules page' do
      before { get Lib::Entities::Router::COMMANDS[:rules] }

      it 'shows text for rules page' do
        expect(last_response.body).to include(I18n.t(:rules))
      end
    end
  end

  describe 'accessing game page without any actions' do
    context 'when starting the game' do
      before do
        env 'rack.session', game: game
        get Lib::Entities::Router::COMMANDS[:game], player_name: name, level: level.to_s
      end

      it 'receives greetings message with users`s name' do
        expect(last_response.body).to include(I18n.t(:hello_message, name: name))
      end
    end
  end

  describe 'some action on game page' do
    context 'when user try to guess number' do
      before do
        game.check_guess(guess_number)
        env 'rack.session', game: game
        get Lib::Entities::Router::COMMANDS[:guess]
      end

      it 'receives text with number of attempts' do
        expect(last_response.body).to include(game.attempts_used.to_s)
      end
    end

    context 'when user press hint for the first time' do
      before do
        env 'rack.session', game: game, hints: []
        get Lib::Entities::Router::COMMANDS[:hint]
      end

      it 'response with hint' do
        expect(last_request.session[:hints].size).to eq(1)
      end

      it 'receives a field with the number of hints' do
        expect(last_response.body).to include((game.to_h[:hints] - 1).to_s)
      end
    end

    context 'when user guessed the code' do
      let(:secret_code) { game.secret_code.join }

      before do
        env 'rack.session', game: game
        post Lib::Entities::Router::COMMANDS[:guess], number: secret_code
      end

      it 'show win message with user`s name on win page' do
        expect(last_response.body).to include(I18n.t(:win_message, name: name))
      end
    end

    context 'when user lose the game' do
      before do
        env 'rack.session', game: game
        game.to_h[:attempts].times { post Lib::Entities::Router::COMMANDS[:guess], number: guess_number }
      end

      it 'show lose message with user`s name' do
        expect(last_response.body).to include(I18n.t(:lose_message, name: name))
      end
    end
  end

  describe 'shows error message' do
    context 'when user gives wrong name' do
      let(:wrong_name) { 'a' * (Codebraker::Validation::MIN_NAME_LENGTH- 1) }

      before { post Lib::Entities::Router::COMMANDS[:game], player_name: wrong_name, level: level.to_s}

      it do
        expect(last_response.body).to include('Wrong name! Please enter the name which consists of 3 to 20 letters!')
      end
    end

    context 'when user choose wrong difficulty' do
      let(:wrong_difficulty) { 'none' }

      before { post Lib::Entities::Router::COMMANDS[:game], player_name: name, level: wrong_difficulty }

      it do
        expect(last_response.body).to include('Wrong difficulty! Please choose one of the following!')
      end
    end

    context 'when user entered wrong length of guess code' do
      let(:wrong_guess_code) do
        Codebraker::Validation::CODE_MIN * (Codebraker::Constants::CODE_LENGTH + 1)
      end

      before do
        env 'rack.session', game: game
        post Lib::Entities::Router::COMMANDS[:guess], number: wrong_guess_code
      end

      it 'error about code lenth' do
        expect(last_response.body).to include('Wrong code! Please enter 4 numbers in range 1 to 6!')
      end
    end
  end
end
