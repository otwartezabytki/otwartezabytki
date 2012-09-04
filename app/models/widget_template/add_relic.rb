# == Schema Information
#
# Table name: widget_templates
#
#  id          :integer          not null, primary key
#  type        :string(255)
#  name        :string(255)
#  description :text
#  thumb       :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class WidgetTemplate::AddRelic < WidgetTemplate

  def snippet(widget)
    widget_url = Rails.application.routes.url_helpers.widget_url(widget.uid, :host => Settings.oz.host)
    %Q(<script type="text/javascript">
      (function(){
        function async_load(){
          var s = document.createElement('script'); s.type = 'text/javascript'; s.async = true; s.src = '#{widget_url}.js';
          var x = document.getElementsByTagName('script')[0]; x.parentNode.insertBefore(s, x);
        }
        if (window.attachEvent) window.attachEvent('onload', async_load); else window.addEventListener('load', async_load, false);
      })();
    </script>).squish
  end

end
