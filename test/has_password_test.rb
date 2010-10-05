require 'test_helper'

class HasPasswordTest < ActiveSupport::TestCase
  def setup
    @person = people(:hal)
  end

  #####################################################################
  #                     C L A S S    M E T H O D S                    #
  #####################################################################
  test 'sha1' do
    assert_equal Digest::SHA1.hexdigest('passwordsalt'), Person.encrypt('password', 'salt')
  end
  
  test 'password generation' do
    assert_equal 8, Person.generate_password.length
  end
  
  #####################################################################
  #                     A U T H E N T I C A T I O N                   #
  #####################################################################
  test 'valid authentication' do 
    assert_equal @person, Person.authenticate(@person.email, 'password')
  end
  
  test 'invalid password' do
    assert_nil Person.authenticate(@person.email, 'invalid')
  end
  
  test 'invalid email and password' do
    assert_nil Person.authenticate('fake', 'faker')
  end
  
  test 'no password' do
    assert_nil Person.authenticate(@person.email, nil)
  end
  
  #####################################################################
  #               P A S S W O R D    A T T R I B U T E                #
  #####################################################################
  test 'virtual password attribute' do
    assert @person.respond_to?(:password)
    assert @person.respond_to?(:password=)
  end
  
  test 'change password with confirmation' do
    @person.password = 'newpassword11'
    @person.password_confirmation = 'newpassword11'
    @person.save
    assert_equal @person, Person.authenticate(@person.email, 'newpassword11')
  end
  
  test 'password reset token generation' do
    @person.set_reset_token
    assert_equal 20, @person.password_reset_token.length
  end
  
  test 'password reset' do
    assert_equal @person, Person.authenticate(@person.email, 'password')
    @person.reset_password
    assert @person.save
    assert_nil Person.authenticate(@person.email, 'password')
    assert @person.force_change_password?
    assert_nil @person.password_reset_token
  end
  
  #####################################################################
  #                          L I F E C Y C L E                        #
  #####################################################################
  test 'encrypt password before save' do
    person = Person.new :email=>'new@email.com', :password=>'password1', :password_confirmation=>'password1'
    assert person.save
    assert !person.password_hash.empty?
    assert !person.password_salt.empty?
  end
  
  #####################################################################
  #                       V A L I D A T I O N S                       #
  #####################################################################
  test 'password confirmation' do
    person = Person.new :password=>'password'
    assert !person.valid?
    assert !person.errors.on(:password_confirmation).blank?
  end
  
  test 'minimum password length of 6' do
    person = Person.new :password=>'12345'
    assert !person.valid?
    assert !person.errors.on(:password).blank?
  end
  
  test 'maximum password length of 40' do
    person = Person.new :password=>'1                                        '
    assert !person.valid?
    assert !person.errors.on(:password).blank?
  end
  
  test 'passwords need one integer' do
    person = Person.new :password=>'abcdefg'
    assert !person.valid?
    assert !person.errors.on(:password).blank?
  end
  
  #####################################################################
  #                        P R O T E C T I O N S                      #
  #####################################################################
  test 'do not update password hash through mass assignment' do
    @person.update_attributes! :password_hash=>'updated'
    assert_not_equal 'updated', @person.password_hash
  end
  
  test 'do not update password salt through mass assignment' do
    @person.update_attributes! :password_salt=>'updated'
    assert_not_equal 'updated', @person.password_salt
  end
  
  test 'do not update password reset token through mass assignment' do
    @person.update_attributes! :password_reset_token=>'updated'
    assert_not_equal 'updated', @person.password_reset_token
  end
  
end