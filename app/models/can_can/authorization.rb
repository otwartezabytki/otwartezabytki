# -*- encoding : utf-8 -*-
require 'active_support/concern'

module CanCan::Authorization
  extend ActiveSupport::Concern

  included do
    before_create :authorize_create
    before_update :authorize_update
    before_destroy :authorize_destroy
    before_validation :assign_user_id
  end

  private

    def assign_user_id
      self.user = PaperTrail.whodunnit if PaperTrail.whodunnit
      true
    end

    def authorize_update
      user.ability.authorize!(:update, self)
    end

    def authorize_create
      user.ability.authorize!(:create, self)
    end

    def authorize_destroy
      user.ability.authorize!(:destroy, self)
    end
end
