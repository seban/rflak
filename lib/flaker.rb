# encoding: UTF-8
module Rflak
  # Utility class for fetching 'flak's from the web.
  #
  # Example:
  #   Flaker.fetch('user') do |flak|
  #     flak.login 'seban'
  #     flak.limit 2
  #     flak.tag 'ruby'
  #   end
  class Flaker
    include HTTParty

    FLAK_API_URL = 'http://api.flaker.pl/api'
    base_uri FLAK_API_URL

    attr_reader :perform_url

    def initialize(type)
      @perform_url = FLAK_API_URL + "/type:#{ type }"
    end


    def self.fetch(type)
      flak = Flaker.new(type)
      yield(flak) if block_given?
      parse_response get(flak.perform_url)
    end


    # Authorize connetion by user's credentials (login and api key) and perform instruction passed in
    # block. Raises NotAuthorize exception when user has bad login or api key.
    #
    # user:: User
    def self.auth_connection(user)
      user.auth unless user.authorized?
      raise NotAuthorized.new('Not authorized') unless user.authorized?
      Flaker.basic_auth(user.login, user.api_key)
      response = yield(Flaker)
      Flaker.basic_auth('','')
      return response
    end


    def self.parse_response(response)
      response['entries'].map do |entry|
        Entry.new(entry)
      end
    end


    def login(value)
      @perform_url += "/login:#{ value }"
    end


    def url(value)
      @perform_url += "/url:#{ value }"
    end


    def entry_id(value)
      @perform_url += "/entry_id:#{ value }"
    end


    def story(story_id)
      @perform_url += "/story:#{ story_id }"
    end


    def source(value)
      @perform_url += "/source:#{ value }"
    end


    def tag(value)
      @perform_url += "/tag:#{ value }"
    end


    def mode(value)
      @perform_url += "/mode:#{ value }"
    end


    def avatars(value)
      @perform_url += "/avatars:#{ value }"
    end


    def limit(value)
      @perform_url += "/limit:#{ value }"
    end


    def from(value)
      @perform_url += "/from:#{ value }"
    end


    def start(value)
      @perform_url += "/start:#{ value }"
    end


    def since(value)
      @perform_url += "/since:#{ value }"
    end


    def sort(value)
      @perform_url += "/sort:#{ value }"
    end


    def comments(value)
      @perform_url += "/comments:#{ value }"
    end
  end
end
