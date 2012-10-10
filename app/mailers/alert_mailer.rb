# encoding: utf-8
class AlertMailer < ActionMailer::Base
  default from: Settings.oz.email_sender

  def notify_oz(alert)
    @alert = alert
    mail(:to => Settings.oz.email_sender, :subject => "Zgłoszono alert!")
  end

  def notify_wuoz(notification_id)
    @notification = WuozNotification.find(notification_id)
    recipient = 'dariusz.gertych@monterail.com, szymon@monterail.com'
    if @notification.zip_file?
      attachments["wuoz_powiadomienie_nr_#{@notification.id}.zip"] = File.read(@notification.zip_file.path)
    end
    mail(:to => recipient, :subject => @notification.subject)
  end
end
