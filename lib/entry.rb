require 'net/http'
require 'json'
module Rflak
  # Class represents single entry in flaker.pl website. Entry is assigned with user to wich it belongs
  # and can have many comments assigned to it.
  class Entry
    ATTR_LIST = [:user, :permalink, :timestamp, :comments, :time, :text, :title, :has_video, :id,
      :has_photo, :link, :has_link, :datetime, :source, :data
    ]

    # define attribute methods public getters and private setters
    ATTR_LIST.each do |attr|
      attr_reader attr
      attr_writer(attr)
      private attr.to_s + '='
    end

    def initialize(options = {})
      options.each_pair do |key, value|
        send("#{ key }=", value)
      end
    end


    # Create new entry. Method raises NotAuthorized exception when passed user is not authorized. If
    # operation is successfull new entry will be returned.
    #
    #   Rflak::Entry.create(User.auth('good_login','good_api_key', { 'text' => 'some test content')
    #
    # user:: User
    #
    # content:: Hash
    #
    # returns:: Entry
    def self.create(user, content)
      raise NotAuthorized.new('Not authorized') unless user.authorized?

      url = URI.parse('http://api.flaker.pl/api/type:submit')
      post = Net::HTTP::Post.new(url.path)
      post.basic_auth(user.login, user.api_key)
      post.set_form_data(content)

      response = Net::HTTP.start(url.host,url.port) do |http|
        http.request(post)
      end
      entry_id = JSON.parse(response.body)['status']['info'].split('/').last
      Flaker.fetch('show') { |f| f.entry_id(entry_id) }.first
    end


    private


    # Set the user based on passed values
    #
    # options:: Hash, default empty Hash
    def user=(options = {})
      @user = User.new(options)
    end


    # Set the comments collection based on passed value
    #
    # options:: Array of Hashes, default []
    def comments=(collection = [])
      return collection if collection.empty?
      @comments = collection.map { |comment_hash| Comment.new(comment_hash) }
    end
  end
end
