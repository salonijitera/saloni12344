class UserService
  def self.register(username:, email:, password:, password_confirmation:)
    raise ArgumentError, 'Username cannot be blank' if username.blank?
    raise ArgumentError, 'Email cannot be blank' if email.blank?
    raise ArgumentError, 'Password cannot be blank' if password.blank?
    raise ArgumentError, 'Password confirmation cannot be blank' if password_confirmation.blank?

    raise ArgumentError, 'Passwords do not match' unless password == password_confirmation
    raise ArgumentError, 'Invalid email format' unless email =~ URI::MailTo::EMAIL_REGEXP

    if User.exists?(email: email)
      raise ArgumentError, 'Email has already been taken'
    else
      encrypted_password = Devise::Encryptor.digest(User, password)
      user = User.create!(
        username: username,
        email: email,
        password_hash: encrypted_password,
        is_email_verified: false
      )

      token = SecureRandom.hex(10)
      expiration_date = Time.now + 24.hours

      EmailVerificationToken.create!(
        user: user,
        token: token,
        expires_at: expiration_date,
        is_used: false
      )

      # Here you would send the email with the token and instructions
      # For example: UserMailer.send_verification_email(user, token).deliver_now

      { message: 'User registered successfully. Please check your email to verify your account.' }
    end
  rescue => e
    { error: e.message }
  end
end
