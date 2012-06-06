# -*- encoding : utf-8 -*-
require 'spec_helper'

describe District do
  it { should belong_to :voivodeship }
end
