module HasPassword
  def self.included(base)
    base.extend ClassMethods
  end
  
  #####################################################################
  #                     C L A S S    M E T H O D S                    #
  #####################################################################
  module ClassMethods
    def has_password
      return if self.included_modules.include? HasPassword::InstanceMethods
      __send__ :include, HasPassword::InstanceMethods
      
      attr_accessor  :password
      attr_protected :password_hash, :password_salt, :password_reset_token

      before_save :encrypt_password

      validates_confirmation_of :password,                 :if=>:update_password?
      validates_length_of       :password, :within=>6..40, :if=>:update_password?
      validates_format_of       :password, :with=>/\d/,    :if=>:update_password?, :message=>'requires at least one number'
      validates_presence_of     :password_confirmation,    :if=>:update_password?
    end
    
    def authenticate(email, password)
      return nil if email.blank? || password.blank?
      person = self.find_by_email email
      person && (self.encrypt(password, person.password_salt) == person.password_hash) ? person : nil
    end

    def encrypt(password, salt) 
      Digest::SHA1.hexdigest(password + salt)
    end

    def generate_password
      numbers = ('0'..'9').to_a
      letters = ('a'..'z').to_a + ('A'..'Z').to_a
      password = ''
      2.times do
        3.times{ password << letters[rand(letters.size)]}
        password << numbers[rand(numbers.size)]
      end
      password
    end
  end
  
  #####################################################################
  #                  I N S T A N C E     M E T H O D S                #
  #####################################################################
  module InstanceMethods
     def set_reset_token
       secret = ''
       existing = nil
       while secret == '' || existing != nil
         characters = ('0'..'9').to_a + ('a'..'z').to_a + ('A'..'Z').to_a
         1.upto(20) { secret << characters[rand(characters.size)]}
         existing = self.class.find_by_password_reset_token secret
       end
       update_attribute :password_reset_token, secret
     end

     def reset_password
       new_password = self.class.generate_password
       self.password = new_password
       self.password_confirmation = new_password
       self.force_change_password = true
       self.password_reset_token = nil
       new_password
     end
     
     def update_password?
       new_record? || !password.blank?
     end

     def encrypt_password 
       return if password.blank?
       self.password_salt = [Array.new(6){rand(256).chr}.join].pack("m").chomp if new_record?
       self.password_hash = self.class.encrypt(password, self.password_salt) 
     end
  end   
  
end