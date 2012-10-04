# encoding: utf-8
class UserMailer < ActionMailer::Base
  default from: Settings.oz.email_sender

  def welcome_email(user, password, reset_password_token)
    @user = user
    @password = password
    @reset_password_token = reset_password_token

    mail(:to => user.email, :subject => "Witaj w Otwartych Zabytkach!")
  end
end
