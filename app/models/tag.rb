# encoding: utf-8
class Tag
  DATA = {
    'park' => [],
    'cmentarz' => [],
    'kamienica' => [],
    'budynek' => [],
    'kaplica' => [],
    'ewangelicki' => [],
    'ogrodzenie' => [],
    'willa' => [],
    'dzwonnica' => [],
    'oficyna' => [],
    'gospodarczy' => [],
    'spichrz' => [],
    'mieszkalny' => [],
    'plebania' => [],
    'stajnia' => [],
    'obora' => [],
    'kapliczka' => [],
    'cerkiew' => [],
    'wojenny' => [],
    'brama' => []
  }

  def self.all
    DATA.keys
  end
end
