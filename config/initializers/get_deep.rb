# -*- encoding : utf-8 -*-
class Hash
  def get_deep(*fields)
    fields.inject(self.with_indifferent_access) {|acc,e| acc[e] if acc.is_a?(Hash)}
  end
end
