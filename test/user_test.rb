$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'rflak'
require 'rubygems'
require 'flexmock/test_unit'

class UserTest < Test::Unit::TestCase
  def setup
    @user = Rflak::User.new
  end


  def test_respond_to_attribute_getters
    [:action, :url, :sex, :avatar, :login].each do |attribute|
      assert @user.respond_to?(attribute)
    end
  end


  def test_auth_user_with_bad_credentials
    flexmock(Rflak::Flaker).should_receive(:get).with('/type:auth').and_return(auth_bad_credentials)
    resp = Rflak::User.auth('login','bad_auth')
    assert_nil(resp)
  end


  def test_auth_user_with_good_credentials
    flexmock(Rflak::Flaker).should_receive(:get).with('/type:auth').and_return(auth_good_credentials)
    resp = Rflak::User.auth('login', 'good_auth')
    assert_kind_of(Rflak::User, resp)
    assert_equal 'login', resp.login
    assert_equal 'good_auth', resp.api_key
  end


  def test_get_tags_not_authorized
    flexmock(Rflak::Flaker).should_receive(:get).with('/type:auth').and_return(auth_bad_credentials)
    user = Rflak::User.new(:login => 'login', :api_key => 'bad_key')
    assert_equal false, user.auth
    exception = assert_raise(Rflak::NotAuthorized) { user.tags }
    assert_equal 'Not authorized', exception.message
  end


  def test_get_tags_authorized
    tag_list_response = { 'tags' => %w(tag1 tag2 tag3) }
    flexmock(Rflak::Flaker).should_receive(:get).with('/type:auth').once.and_return(auth_good_credentials)
    flexmock(Rflak::Flaker).should_receive(:get).with("/type:list/source:tags/login:login").once.and_return(tag_list_response).times(1)
    user = Rflak::User.new(:login => 'login', :api_key => 'good_key')
    assert user.auth
    tags = user.tags
    assert_equal tag_list_response['tags'], tags
  end


  def test_get_bookmarks_not_authorized
    flexmock(Rflak::Flaker).should_receive(:get).with('/type:auth').and_return(auth_bad_credentials)
    user = Rflak::User.new(:login => 'login', :api_key => 'bad_key')
    assert_equal false, user.auth
    exception = assert_raise(Rflak::NotAuthorized) { user.bookmarks }
    assert_equal 'Not authorized', exception.message
  end


  def test_get_bookmarks_authorized
    bookmark_list_response = { 'bookmarks' => %w(1 2 3) }
    flexmock(Rflak::Flaker).should_receive(:get).with('/type:auth').once.and_return(auth_good_credentials)
    flexmock(Rflak::Flaker).should_receive(:get).with("/type:list/source:bookmarks/login:login").once.and_return(bookmark_list_response).times(1)
    flexmock(Rflak::Flaker).should_receive(:fetch).with("show", Proc).times(3).and_return(Rflak::Entry.new)
    user = Rflak::User.new(:login => 'login', :api_key => 'good_key')
    assert user.auth
    bookmarks = user.bookmarks
    assert_equal 3, bookmarks.size
    bookmarks.each do |bookmark|
      assert_kind_of(Rflak::Entry, bookmark)
    end
  end


  def test_get_followers_not_authorized
    flexmock(Rflak::Flaker).should_receive(:get).with('/type:auth').and_return(auth_bad_credentials)
    user = Rflak::User.new(:login => 'login', :api_key => 'bad_key')
    assert_equal false, user.auth
    exception = assert_raise(Rflak::NotAuthorized) { user.followers }
    assert_equal 'Not authorized', exception.message
  end


  def test_get_followers_authorized
    followers_list_response = { 'followedby' => %w(seban) }
    flexmock(Rflak::Flaker).should_receive(:get).with('/type:auth').once.and_return(auth_good_credentials)
    flexmock(Rflak::Flaker).should_receive(:get).with("/type:list/source:followedby/login:login").once.and_return(followers_list_response).times(1)

    user = Rflak::User.new(:login => 'login', :api_key => 'good_key')
    assert user.auth
    followers = user.followers

    assert_kind_of(Array, followers)
    assert_equal 1, followers.size
    followers.each { |f| assert_kind_of(String, f) }
  end


  def test_get_followers_extended
    followers_list_response = { 'followedby' => %w(seban) }
    flexmock(Rflak::Flaker).should_receive(:get).with('/type:auth').once.and_return(auth_good_credentials)
    flexmock(Rflak::Flaker).should_receive(:get).with("/type:list/source:followedby/login:login/extended:true").once.and_return(followers_list_response).times(1)

    user = Rflak::User.new(:login => 'login', :api_key => 'good_key')
    assert user.auth
    followers = user.followers(true)

    assert_kind_of(Array, followers)
    assert_equal 1, followers.size
    followers.each { |f| assert_kind_of(String, f) }
  end


  def test_get_following_not_authorized
    flexmock(Rflak::Flaker).should_receive(:get).with('/type:auth').and_return(auth_bad_credentials)
    user = Rflak::User.new(:login => 'login', :api_key => 'bad_key')
    assert_equal false, user.auth
    exception = assert_raise(Rflak::NotAuthorized) { user.following }
    assert_equal 'Not authorized', exception.message
  end


  def test_get_following_authorized
    following_list_response = { 'following' => %w(seban) }
    flexmock(Rflak::Flaker).should_receive(:get).with('/type:auth').once.and_return(auth_good_credentials)
    flexmock(Rflak::Flaker).should_receive(:get).with("/type:list/source:following/login:login").once.and_return(following_list_response).times(1)

    user = Rflak::User.new(:login => 'login', :api_key => 'good_key')
    assert user.auth
    following = user.following

    assert_kind_of(Array, following)
    assert_equal 1, following.size
    following.each { |f| assert_kind_of(String, f) }
  end


  def test_get_following_extended
    following_list_response = { 'following' => %w(seban) }
    flexmock(Rflak::Flaker).should_receive(:get).with('/type:auth').once.and_return(auth_good_credentials)
    flexmock(Rflak::Flaker).should_receive(:get).with("/type:list/source:following/login:login/extended:true").once.and_return(following_list_response).times(1)

    user = Rflak::User.new(:login => 'login', :api_key => 'good_key')
    assert user.auth
    following = user.following(true)

    assert_kind_of(Array, following)
    assert_equal 1, following.size
    following.each { |f| assert_kind_of(String, f) }
  end


  protected


  def auth_bad_credentials
    {"status" => {"code" => "401","text" => "Unauthorized","info" => "authorization is required"}}
  end


  def auth_good_credentials
    { "status" => {"code" => "200","text" => "OK","info" =>"authorization successful"}}
  end
end
