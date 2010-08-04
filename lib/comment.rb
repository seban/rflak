# encoding: UTF-8
module Rflak
  # Class represents single comment assigned to 'flak'
  class Comment < DummyEntry
    ATTR_LIST = [:user, :permalink, :timestamp, :time, :text, :datetime, :source, :data, :subsource,
      :url, :related_id
    ]

    # define attribute methods public getters and private setters
    ATTR_LIST.each do |attr|
      attr_reader attr

      # user= method from dummy entry
      unless attr == :user
        attr_writer(attr)
        protected attr.to_s + '='
      end
    end


    def initialize(options = {})
      options.each_pair do |key, value|
        send("#{ key }=", value)
      end
    end


    # Create new comment entry. Method raises NotAuthorized exception when passed user is not
    # authorized. As entry parameter method takes <tt>Entry</tt> object or its <tt>id</tt> value.
    # Content is passed as simply text message. When new comment is created <tt>true</tt> is returned
    # otherwise returns <tt>false</tt>
    #
    # entry:: Entry || Fixnum
    #
    # user::  User
    #
    # returns:: Boolean
    def self.create(entry, user, content)
      raise NotAuthorized.new('Not authorized') unless user.authorized?

      url = URI.parse('http://api.flaker.pl/api/type:submit')
      post = Net::HTTP::Post.new(url.path)
      post.basic_auth(user.login, user.api_key)

      if entry.kind_of?(Entry)
        post.set_form_data('text' => "@#{ entry.id } #{ content }")
      else
        post.set_form_data('text' => "@#{ entry } #{ content }")
      end

      response = Net::HTTP.start(url.host,url.port) do |http|
        http.request(post)
      end
      response.code.to_i == 200
    end
  end
end
