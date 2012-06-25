class UserMailer < ActionMailer::Base
  default from: "no-reply@otwartezabytki.pl"

  def welcome_email(user, password)
    @user = user
    @password = password

    mail(:to => user.email, :subject => "Witaj w Otwartych Zabytkach!")
  end
end
