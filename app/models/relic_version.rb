class RelicVersion < Version
  self.table_name = :versions
  attr_accessible :comment
end
