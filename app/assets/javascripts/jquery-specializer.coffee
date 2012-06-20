jQuery.fn.specialize = (klass, extensions) ->
  unless extensions?
    for new_klass, new_extensions of klass
      jQuery.fn.specialize(new_klass, new_extensions)
    return

  extend = (name, callback) ->
    old_method = jQuery.fn[name]
    jQuery.fn[name] = ->
      if this.is(klass)
        return callback.apply(this, arguments)
      else
        return old_method.apply(this, arguments) if typeof old_method == 'function'

  extend(name, callback) for name, callback of extensions

  return
