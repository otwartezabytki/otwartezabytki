require 'spec_helper'

describe ApplicationHelper do

  context "users statistics" do
    it "should return statistic results" do
      users_statistics.is_a? Array
      users_statistics.should have(3).items
      users_statistics.all? &:present?
    end
  end

  context "users_activity_statistics" do
    it "should return statistic results" do
      users_activity_statistics.is_a? Array
      users_activity_statistics.should have(2).items
    end
  end

  context "relics_statistics" do
    it "should return statistic results" do
      relics_statistics.is_a? Array
      relics_statistics.should have(4).items
    end
  end

  context "random_search_suggestions" do
    it "should return string of links" do
      random_search_suggestions.is_a? String
      random_search_suggestions.split(', ').should have(3).items
      random_search_suggestions.should match /(<a href="\/relics">.*?<span>.*?<\/span><\/a>)/
    end
  end

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
