class StrongParametersStrategy < DecentExposure::ActiveRecordWithEagerAttributesStrategy
  delegate :delete?, :to => :request

  def attributes
    (get? || delete?) ? super : controller.send(:"#{name.singularize}_params")
  end
end
