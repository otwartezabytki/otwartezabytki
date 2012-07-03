class PagesController < HighVoltage::PagesController
  before_filter :authenticate_user!, :only => :hello
end