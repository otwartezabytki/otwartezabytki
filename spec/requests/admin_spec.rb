# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "Admin panel" do
	let(:user) { create :user }
	let(:admin_user) { create(:user, :admin) }

  # active admin has some annoying deprecations
  around :each do |example|
    ActiveSupport::Deprecation.silence(&example)
  end

  describe "GET /admin" do
  	it "should redirect to login page when no-one is logged in" do
  	  get admin_dashboard_path
  	  response.should redirect_to(new_user_session_path)
  	end

    it "should display permissions denied message for non-admin user" do
      post user_session_path 'user[email]' => user.email, 'user[password]' => 'password'
      get admin_dashboard_path
      response.should redirect_to(new_user_session_path)
    end

    it "should display dashbord for an admin user" do
      post user_session_path 'user[email]' => admin_user.email, 'user[password]' => 'password'
      get admin_dashboard_path
      response.status.should be(200)
      response.body.should have_content t "active_admin.dashboard"
    end    
  end

  describe "User registration" do
    it 'should create new user' do
      @users_count = User.count

      visit new_user_registration_path

      fill_in 'user_email', :with => 'account@example.com'
      fill_in 'user_password', :with => 'password'

      puts body
      find("[name='commit']").click

      User.count.should eq @users_count + 1
    end
  end

  context "as logged in admin user" do

    before :all do
      @relics = create_list :relic, 10
    end

    before :each do
      post user_session_path 'user[email]' => admin_user.email, 'user[password]' => 'password'
    end

    describe "GET /admin/relics" do
      it "should display list of relics" do
        get admin_relics_path
        response.body.should have_content(@relics.first.identification)
      end
    end

    describe "GET /admin/users" do
      it "should display list of users" do
        @user = create :user
        get admin_users_path
        response.body.should have_content(@user.email)
      end
    end
  end
end