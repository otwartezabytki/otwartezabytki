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
end
