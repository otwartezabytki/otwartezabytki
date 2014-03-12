# -*- encoding : utf-8 -*-
require 'spec_helper'

describe ApplicationHelper do
  before(:each) { refresh_relics_index }

  context "link_to_facet" do
    before do
      def search_params; {}; end
    end

    it "should return link" do
      link_to_facet({
        'term' => 'Dolnoslaskie_1', 'count' => 2
      }, ['2', '3', '4'], 0).should match /(<a href=".*">.*?<span>.*?<\/span><\/a>)/
    end

    it "should return selected structure" do
      link_to_facet({
        'term' => 'Dolnoslaskie_2', 'count' => 2
      }, ['2', '3', '4'], 0).should match /(<div class="selected"><a href=".*">.*?<span>.*?<\/span><\/a>)/
    end

    it "should return non selected" do
      link_to_facet({
        'term' => 'Dolnoslaskie_2', 'count' => 2
      }, ['2'], 0).should match /(<p>.*?<\/p><\/div>)/
    end

    it "should concatc html if block given" do
      link_to_facet({
        'term' => 'Dolnoslaskie_2', 'count' => 2
      }, ['2'], 0) do
        'some html'
      end.should match /<p>.*?<\/p><\/div>some html/
    end
  end

end
