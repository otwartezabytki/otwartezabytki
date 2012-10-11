# -*- encoding : utf-8 -*-
Formtastic::Helpers::FormHelper.builder = FormtasticBootstrap::FormBuilder
FormtasticBootstrap::FormBuilder.i18n_lookups_by_default = true
FormtasticBootstrap::FormBuilder.default_inline_hint_class = :block

module FormtasticBootstrap
  module Inputs
    module Base
      module Wrapping
        # Override this method if you want to change the display order (for example, rendering the
        # errors before the body of the input).
        def input_div_wrapping(inline_or_block_errors = :inline)
          template.content_tag(:div, :class => "input") do
            [hint_html(inline_or_block_errors), yield, error_html(inline_or_block_errors)].join("\n").html_safe
          end
        end
      end
    end
  end
end
