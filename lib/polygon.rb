class Polygon
  def self.expand(path, radius)
    radius = radius.to_f
    radius45 = 0.7 * radius
    path = path.map{ |k, v| v.map(&:to_f) }
    boundaries = [
      translate(path, [0, radius]) + translate(path.reverse, [radius, 0]),
      translate(path, [radius, 0]) + translate(path.reverse, [0, -radius]),
      translate(path, [0, -radius]) + translate(path.reverse, [-radius, 0]),
      translate(path, [-radius, 0]) + translate(path.reverse, [0, radius])
    ]

    boundaries = boundaries + path.map do |vertex|
      circle(vertex.first, vertex.last, radius)
    end

    boundaries.reduce { |a, b| union(a, b) }
  end

  def self.translate(path, offset)
    offset = offset.map { |coord| to_latlng(coord) }
    path.map{ |vertex| [vertex.first + offset.first, vertex.last + offset.last] }
  end

  def self.circle(lat, lng, radius, detail = 16.0)
    radius = to_latlng(radius)
    (0..detail).to_a.map do |i|
      rad = 1 / detail * i * Math::PI * 2
      [lat + Math.cos(rad) * radius, lng + Math.sin(rad) * radius]
    end
  end

  def self.union(boundary1, boundary2)
    clipper = Clipper::Clipper.new
    clipper.add_subject_polygon(boundary1 + [boundary1.first])
    clipper.add_clip_polygon(boundary2 + [boundary2.first])
    clipper.union(:non_zero, :non_zero).max_by(&:size)
  end

  def self.to_latlng(km)
    km.to_f / 40_000.0 * 360.0
  end
end
