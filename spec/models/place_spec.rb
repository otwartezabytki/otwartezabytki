# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Place do
  it { should belong_to :commune }
end
