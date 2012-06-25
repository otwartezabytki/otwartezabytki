# -*- encoding : utf-8 -*-
module ApplicationHelper

  def next_relic_url_for(user)
    edit_relic_path(Relic.next_for(user).id)
  end

end
