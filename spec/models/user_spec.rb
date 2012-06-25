require 'spec_helper'

describe User do
 context "role" do
   it "should not be editable by update_attributes" do
     user = create :user

     expect {
       user.update_attributes(:role => "admin")
     }.to raise_error

   end

   it "should be editable by admin user" do
     user = create :user
     user.update_attributes({ :role => "admin" }, :as => :admin)
     user.role.should eq "admin"
     user.admin?.should eq true
   end
 end

  context 'registration' do
    it 'should be possible to create nil user' do
      user = User.create
      user.email.should be_blank
      user.username.should be_blank
      user.role.should eq 'user'
      user.password.should be_nil
      ActionMailer::Base.deliveries.size.should eq 0
    end

    it 'should be possible to update user credentials' do
      user = create :user
      user.update_attributes :username => "sampleuser", :email => "sampleuser@example.com"

      user.password.should_not be_nil
      ActionMailer::Base.deliveries.should_not be_empty

      email = ActionMailer::Base.deliveries.last
      assert_equal ["sampleuser@example.com"], email.to
      assert_match(/#{user.password}/, email.encoded)
    end
  end
end
