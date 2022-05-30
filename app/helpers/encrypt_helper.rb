# require 'active_support'
module EncryptHelper
  key = SecureRandom.random_bytes(32)
  crypt = ActiveSupport::MessageEncryptor.new(key)
  encrypted_data = crypt.encrypt_and_sign("your password")
  password = crypt.decrypt_and_verify(encrypted_data)
end
