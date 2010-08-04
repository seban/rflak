# encoding: UTF-8
module Rflak
  # Class represents single user of flaker.pl.
  class User
    ATTR_LIST = [:action, :url, :sex, :avatar, :login, :api_key]

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


    # Try to authorize user with login and api_key. Method returns User object for good credentails
    # or nil for bad.
    #
    # login:: String
    #
    # api_key:: String
    def self.auth(login, api_key)
      user = User.new(:login => login, :api_key => api_key)
      user.auth
      user.authorized? ? user : nil
    end


    # Authorize User instance with login and api_key. Returns true for valid credentaials of false
    # if not.
    #
    # returns:: True of False
    def auth
      Flaker.basic_auth(@login, @api_key)
      resp = Flaker.get('/type:auth')
      Flaker.basic_auth('', '')
      @authorized = (resp['status']['code'] == "200")
    end


    # Returns true if User instance is authorized
    #
    # returns:: True or False
    def authorized?
      @authorized || false
    end


    # Returns array of watched tags. Raises Rflak::NotAuthorized if not authorized user
    #
    # returns:: Array
    def tags
      resp = Flaker.auth_connection(self) do |connection|
        connection.get("/type:list/source:tags/login:#{ @login }")
      end
      return resp['tags']
    end


    # Returns array of favourited entries. Raises Rflak::NotAuthorized if not authorized user
    #
    # returns:: Array
    def bookmarks
      resp = Flaker.auth_connection(self) do |connection|
        connection.get("/type:list/source:bookmarks/login:#{ @login }")
      end
      resp['bookmarks'].map do |id|
        Flaker.fetch('show') { |flak| flak.entry_id(id) }
      end
    end


    # Return login list of users that follow user. Pass <tt>true</tt> as parameter if you want to get extended
    # data (avatar, fiest name, url, sex, ...)
    #
    # extended:: Boolean, default false
    # returns:: Array
    def followers(extended = false)
      request_path = "/type:list/source:followedby/login:#{ @login }"
      request_path << "/extended:true" if extended
      resp = Flaker.auth_connection(self) do |connection|
        connection.get(request_path)
      end
      resp['followedby']
    end


    # Returns login list of users following by user. Pass <tt>true</tt> as parameter if you want to get extended
    # data (avatar, fiest name, url, sex, ...)
    #
    # extended:: Boolean, default false
    # returns:: Array
    def following(extended = false)
      request_path = "/type:list/source:following/login:#{ @login }"
      request_path << "/extended:true" if extended
      resp = Flaker.auth_connection(self) do |connection|
        connection.get(request_path)
      end
      resp['following']
    end
  end
end
