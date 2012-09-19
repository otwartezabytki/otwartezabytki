# == Schema Information
#
# Table name: widgets
#
#  id                 :integer          not null, primary key
#  user_id            :integer
#  widget_template_id :integer
#  uid                :string(255)
#  config             :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class Widget::AddRelic < Widget

  serialized_attr_accessor :button_type => 'small'

  validates :button_type, :inclusion => {:in => ['small', 'medium', 'big']}

  def snippet
    widget_url = Rails.application.routes.url_helpers.widgets_add_relic_url(uid, :host => Settings.oz.host)
    %Q(<script type="text/javascript">
  (function(){
    function async_load(){
      var s = document.createElement('script');
      s.type = 'text/javascript'; s.async = true;
      s.src = '#{widget_url}.js';
      var x = document.getElementsByTagName('script')[0];
      x.parentNode.insertBefore(s, x);
    }
    if (window.attachEvent)
      window.attachEvent('onload', async_load);
    else
      window.addEventListener('load', async_load, false);
  })();
</script>
<div id='oz_add_relic_widget'></div>)
  end

end
