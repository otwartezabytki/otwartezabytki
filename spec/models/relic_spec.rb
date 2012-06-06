# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Relic do
  it { should belong_to :place }
  it { should belong_to :district }
  it { should belong_to :commune }
  it { should belong_to :voivodeship }
end
