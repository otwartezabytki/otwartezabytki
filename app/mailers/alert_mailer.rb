# encoding: utf-8
class AlertMailer < ActionMailer::Base
  default from: Settings.oz.email_sender

  def notify_oz(alert)
    @alert = alert
    mail(:to => Settings.oz.email_sender, :subject => "Zgłoszono alert!")
  end
end
