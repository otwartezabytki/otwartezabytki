require 'spec_helper'

describe Suggestion do
  it 'should fill relic fields on create when relic_id provided' do
    relic = create :relic
    suggestion = Suggestion.new(:relic_id => relic.id)

    suggestion.identification.should eq relic.identification
    suggestion.place_id.should eq relic.place_id
    suggestion.street.should eq relic.street
    suggestion.dating_of_obj.should eq relic.dating_of_obj
    suggestion.latitude.should eq relic.latitude
    suggestion.longitude.should eq relic.longitude
  end
end
