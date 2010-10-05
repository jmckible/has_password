require 'digest/sha1'
require 'has_password'
ActiveRecord::Base.class_eval { include HasPassword }