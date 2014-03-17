class OsmXml

  def initialize
    read_xml_from_osm
    @relics = Relic.where("register_number IS NOT NULL") - @existing
  end

  def general_info relic, node
    node.tag("k"=>"heritage", "v"=>"2")
    node.tag("k"=>"heritage:operator", "v"=>"nid")
    node.tag("k"=>"ref:nid", "v"=>relic.register_number)
    node.tag("k" => "name", "v" => relic.identification)
    node.tag("k" => "addr:city", "v" => relic.place.name) if relic.place.present?
  end

  def how_much
    @relics.count
  end

  def category_info relic, node
    if relic.categories.include?("park_ogrod") && 
      !relic.categories.include?("mieszkalny")

      node.tag("k" => "leisure", "v" => "park") 

    elsif relic.categories.include?("dworski_palacowy_zamek")

      if relic.categories.include?("mieszkalny")
        node.tag("k" => "historic", "v" => is_home?(relic) ? "house" : "manor")
      else
        node.tag("k" => "historic", "v" =>"castle")
        if relic.identification =~ /ruin/i
          node.tag("k" => "ruins", "v" => "yes")
        end
      end

    elsif relic.categories.include?("cmentarny")

      node.tag("k" => "landuse", "v" => "cementery")
      get_religion(relic, node)

    elsif relic.categories.include?("sakralny")

      node.tag("k" => "amenity", "v" =>"place_of_worship")
      get_religion(relic, node)

    elsif relic.categories.include?("przemyslowy_poprzemyslowy")

      node.tag("k" => "landuse", "v" => "industrial")

    elsif relic.categories.include?("militarny")

      node.tag("k" => "landuse", "v" => "military")

    elsif relic.categories.include?("uzytecznosci_publicznej")

      node.tag("k" => "building", "v" => "public")

    elsif relic.categories.include?("architektura_inzynieryjna") && 
      !relic.categories.include?("mieszkalny")

      define_industrial(relic, node)

    elsif relic.categories.include?("mala_architektura")

      if relic.identification =~ /brama/i
        node.tag("k" => "amenity", "v" => "gate")
      elsif relic.identification =~ /ogrodzeni/i
        node.tag("k" => "amenity", "v" => "fence")
      else
        node.tag("k" => "historic", "v" => "wayside_shrine")
      end

    elsif relic.categories.include?("sportowy_kulturalny_edukacyjny")

      node.tag("k" => "building", "v" => "civic")

    elsif relic.categories.include?("uklad_urbanistyczny_zespol_budowlany") ||
      relic.categories.include?("mieszkalny")

      node.tag("k" => "landuse", "v" => "residental")
      if relic.identification =~ /kamienic/i
        node.tag("k" => "building", "v" => "apartments")
      elsif is_home?(relic)
        node.tag("k" => "building", "v" => "house")
      end

    elsif relic.categories.include?("budynek_gospodarczy")

      node.tag("k" => "building", "v" => is_home?(relic) ? "house" : "farm_auxiliary")
    elsif relic.categories.empty?
      define_industrial(relic, node)
    end
  end

  def save
    file_path = [Rails.root, "public", "oz_relics.xml"].join("/")
    file = File.open(file_path, "w")
    new_xml = Builder::XmlMarkup.new(:indent => 2)
    new_xml.instruct!(:xml, :encoding => "UTF-8",  :version => "1.0")

    @relics.each do |relic|
      new_xml.node("lat"=> relic.latitude, "lon" => relic.longitude) do |node|
        general_info(relic, node)
        category_info(relic, node)
      end
    end
    file.write(new_xml)
    file.close
  end

  def get_religion relic, node
    if relic.categories.include?("zydowski")
      node.tag("k" => "religion", "v" => "jewish")
    elsif relic.categories.include?("muzlumanski")
      node.tag("k" => "religion", "v" => "muslim")
    else
      if relic.categories.include?("protestancki")
        node.tag("k" => "religion", "v" => "christian")
        node.tag("k" => "denomination", "v" => "protestant")
      elsif relic.categories.include?("prawoslawny")
        node.tag("k" => "religion", "v" => "christian")
        node.tag("k" => "denomination", "v" => "orthodox")
      elsif relic.categories.include?("katolicki")
        node.tag("k" => "religion", "v" => "christian")
        node.tag("k" => "denomination", "v" => "roman_catholic")
      end
    end
  end

  def define_industrial relic, node
    if relic.identification =~ /most/i
      node.tag("k" => "bridge", "v" => "yes")
    elsif relic.identification =~ /m%yn/i
      node.tag("k" => "building", "v" => "mill")
    elsif relic.identification =~ /wiatrak/i
      node.tag("k" => "building", "v" => "windmill")
    elsif relic.identification =~ /magazyn/i
      node.tag("k" => "amenity", "v" => "warehouse")
    else
      node.tag("k" => "landuse", "v" => "industrial")
    end
  end

  def is_home? relic
    relic.identification =~ /dom/i ? true : false
  end

  def read_xml_from_osm
    @existing= []
    file_path = [Rails.root, 'public', 'osm-relics'].join("/")
    xml = Nokogiri::XML(File.open(file_path))
    xml.xpath("//tag[@k='ref:nid']").each do |tag|
      relic = Relic.find_by_register_number(tag.attributes["v"].value)
      @existing << relic if relic.present?
    end
    @existing
  end

end
