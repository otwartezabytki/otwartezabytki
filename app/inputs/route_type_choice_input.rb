class RouteTypeChoiceInput < Formtastic::Inputs::RadioInput
  def to_html
    template.content_tag(
      :div,
      collection.map { |choice| choice_html(choice) }.join("\n").html_safe,
      :class => 'route-type'
    )
  end

  def choice_html(choice)
    template.content_tag(:label,
      builder.radio_button(
        input_name,
        choice_value(choice),
        input_options = input_html_options.merge(choice_html_options(choice))
      ) << template.content_tag(
        :span, choice_label(choice),
        :title => choice_label(choice)
      ),
      label_html_options.merge(
        :for => choice_input_dom_id(choice),
        :class => "route-type__choice route-type__choice--#{choice_value(choice)}"
      )
    )
  end
end
