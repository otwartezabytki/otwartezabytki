# -*- encoding : utf-8 -*-
require 'spec_helper'

describe UserMailer do
  let(:user) { mock_model(User, :name => 'Darek', :email => 'darek@email.com') }
  let(:mail) { UserMailer.welcome_email(user, 'password', 'password-token') }

  it 'renders the receiver email' do
    mail.to.should == [user.email]
  end

  it 'renders the sender email' do
    mail.from.should == [ Settings.oz.email_sender ]
  end
end
