require 'test_helper'

class HasPasswordTest < ActiveSupport::TestCase

  #####################################################################
  #                     A U T H E N T I C A T I O N                   #
  #####################################################################
  def test_sha1
    assert_equal Digest::SHA1.hexdigest('passwordsalt'), Person.encrypt('password', 'salt')
  end
  
  def test_valid_authentication
    assert_equal people(:hal), Person.authenticate(people(:hal).email, 'password')
  end
  
end