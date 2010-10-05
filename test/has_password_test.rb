require 'test_helper'

class HasPasswordTest < ActiveSupport::TestCase
  def setup
    @person = people(:hal)
  end

  #####################################################################
  #                     A U T H E N T I C A T I O N                   #
  #####################################################################
  test 'sha1' do
    assert_equal Digest::SHA1.hexdigest('passwordsalt'), Person.encrypt('password', 'salt')
  end
  
  test 'valid authentication' do 
    assert_equal @person, Person.authenticate(@person.email, 'password')
  end
  
  test 'invalid password' do
    assert_nil Person.authenticate(@person.email, 'invalid')
  end
  
end