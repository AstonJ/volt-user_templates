class UserTemplateTasks < Volt::Task
  def send_password_reset_email(email)
    # Find user by e-mail
    Volt.skip_permissions do
      store._users.where(email: email).fetch_first do |user|
        if user
          setup_and_send_password_reset(user, email)
        else
          raise "There is no account with the e-mail of #{email}."
        end
      end
    end
  end
  
  def setup_and_send_password_reset(user, email)
    generate_token(user, :password_reset_token)
    user.password_reset_sent_at = Time.zone.now
    user.save
    Mailer.deliver('user_templates/mailers/forgot', {to: email, name: user._name})
  end
  
  def generate_token(user, column)
    user[column] = SecureRandom.urlsafe_base64
  end
end