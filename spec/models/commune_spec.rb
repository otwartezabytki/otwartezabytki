# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Commune do
  it { should belong_to :district }
end
