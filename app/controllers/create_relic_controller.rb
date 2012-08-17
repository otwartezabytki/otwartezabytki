class CreateRelicController < ApplicationController
  include Wicked::Wizard

  steps :location, :address, :details, :photos

  def show
    render_wizard
  end

end
