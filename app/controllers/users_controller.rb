# -*- encoding : utf-8 -*-
class UsersController < ApplicationController
  expose(:user) { User.find_by_username!(params[:id])}
end
