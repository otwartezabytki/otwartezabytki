// Unserialize (to) form plugin
// Version 1.0.8
// Copyright (C) 2010-2012 Christopher Thielen, others (see ChangeLog below)
// Dual-licensed under GPLv2 and the MIT open source licenses

// Usage:
//        var s = $("form").serialize(); // save form settings
//        $("form").unserializeForm(s);  // restore form settings

// Notes:
//        * Recurses fieldsets, p tags, etc.
//        * Form elements must have a 'name' attribute.

// Alternate Usage:
//        var s = $("form").serialize();
//        $("form").unserializeForm(s, {
//          'callback'        : function(key, value, [element]) { $(input[name=key]).val(val); },
//          'override-values' : false
//        });
//
//        callback (optional):
//          The above callback is given the element and value, allowing you to build
//          dynamic forms via callback. If you return false, unserializeForm will
//          try to find and set the DOM element, otherwise, (on true) it assumes you've
//          handled that attribute and moves onto the next.
//          The callback will be passed the key and value and, if found, the DOM object it
//          will use should you return false. If the DOM object is not found, the third parameter
//          will be the empty array jQuery returns when it cannot find an element.
//        override-values (optional, default is false):
//          Controls whether elements already set (e.g. an input tag with a non-zero length value)
//          will be touched by the unserializer. Does not apply to radio fields or checkboxes.
//          If you have a use case for radio fields or checkboxes, please file an issue at
//          https://github.com/cthielen/unserialize-to-form/issues/ . Also note this option
//          does not apply to a callback, i.e. a callback would still have the opportunity
//          to override a value even if this option is set to false. It is up to you as
//          the callback author to enforce the behavior you wish.

// See ChangeLog at end of file for history.

(function($) {
  var methods = {
    _unserializeFormSetValue : function( el, _value, override ) {

      if($(el).length > 1) {
        // Assume multiple elements of the same name are radio buttons
        $.each(el, function(i) {

          var match = ($.isArray(_value)
            ? ($.inArray(this.value, _value) != -1)
            : (this.value == _value)
            );

          this.checked = match;
        });
      } else {
        // Assume, if only a single element, it is not a radio button
        if($(el).attr("type") == "checkbox") {
          $(el).attr("checked", true);
        } else {
          if(override) {
            $(el).val(_value);
          } else {
            if (!$(el).val()) {
              $(el).val(_value);
            }
          }
        }
      }
    },

    _pushValue : function( obj, key, val ) {
      if (null == obj[key])
        obj[key] = val;
      else if (obj[key].push)
        obj[key].push(val);
      else
        obj[key] = [obj[key], val];
    }
  };

  // takes a GET-serialized string, e.g. first=5&second=3&a=b and sets input tags (e.g. input name="first") to their values (e.g. 5)
  $.fn.unserialize = function( _values, _options ) {

    // Set up defaults
    var settings = $.extend( {
      'callback'         : undefined,
      'override-values'  : false
    }, _options);

    return this.each(function() {
      // this small bit of unserializing borrowed from James Campbell's "JQuery Unserialize v1.0"
      _values = _values.split("&");
      _callback = settings["callback"];
      _override_values = settings["override-values"];

      if(_callback && typeof(_callback) !== "function") {
        _callback = undefined; // whatever they gave us wasn't a function, act as though it wasn't given
      }

      var serialized_values = new Array();
      $.each(_values, function() {
        var properties = this.split("=");

        if((typeof properties[0] != 'undefined') && (typeof properties[1] != 'undefined')) {
          methods._pushValue(serialized_values, properties[0].replace(/\+/g, " "), decodeURI(properties[1].replace(/\+/g, " ")));
        }
      });

      // _values is now a proper array with values[hash_index] = associated_value
      _values = serialized_values;

      // Start with all checkboxes and radios unchecked, since an unchecked box will not show up in the serialized form
      $(this).find(":checked").attr("checked", false);

      // Iterate through each saved element and set the corresponding element
      for(var key in _values) {
        var el = $(this).add("input,select,textarea").find("[name=\"" + unescape(key) + "\"]");

        if(typeof(_values[key]) != "string") {
          // select tags using 'multiple' will be arrays here (reports "object")
          // We cannot do the simple unescape() because it will flatten the array.
          // Instead, unescape each item individually
          var _value = new Array();
          $.each(_values[key], function(i, v) {
            _value.push(unescape(v));
          })
        } else {
          var _value = unescape(_values[key]);
        }

        if(_callback == undefined) {
          // No callback specified - assume DOM elements exist
          methods._unserializeFormSetValue(el, _value, _override_values);
        } else {
          // Callback specified - don't assume DOM elements already exist
          var result = _callback.call(this, unescape(key), _value, el);

          // If they return true, it means they handled it. If not, we will handle it.
          // Returning false then allows for DOM building without setting values.
          if(result == false) {
            var el = $(this).add("input,select,textarea").find("[name=\"" + unescape(key) + "\"]");
            // Try and find the element again as it may have just been created by the callback
            methods._unserializeFormSetValue(el, _value, _override_values);
          }
        }
      }
    })
  }
})(jQuery);