# encoding: UTF-8
module Rflak
  class DummyEntry
    protected


    # Set the user based on passed values
    #
    # options:: Hash, default empty Hash
    def user=(options = {})
      @user = User.new(options)
    end
  end
end
