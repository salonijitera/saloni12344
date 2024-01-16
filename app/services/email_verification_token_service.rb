module Services
  class EmailVerificationTokenService
    def self.generate_token(user:)
      begin
        token = SecureRandom.hex(10)
        expires_at = 24.hours.from_now

        email_verification_token = EmailVerificationToken.create!(
          user: user,
          token: token,
          expires_at: expires_at,
          is_used: false
        )

        email_verification_token
      rescue => e
        raise "Failed to generate email verification token: #{e.message}"
      end
    end
  end
end
