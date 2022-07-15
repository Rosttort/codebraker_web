# frozen_string_literal: true

require 'pry'
require 'rack'
require 'haml'
require 'i18n'
require 'bundler/setup'
require 'faker'
require 'codebraker'

require_relative('config/i18n_config')
require_relative('lib/modules/data_loader')
require_relative('lib/modules/web_helper')
require_relative('lib/modules/constants')
require_relative('lib/entities/raiting_console')
require_relative('lib/entities/menu')
require_relative('lib/entities/game')
require_relative('lib/entities/router')
