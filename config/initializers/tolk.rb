# -*- encoding : utf-8 -*-

Tolk::ApplicationController.authenticator = proc {
  authenticate_user! and current_user.admin?
}