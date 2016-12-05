calc_progress_bar = ->
  if $('.oz-progress-bar').length > 0 #check if class exists
    console.log("w ifie")
    whole_div = $('.oz-progress-bar')  #get content of the class
    console.log(whole_div)
    checked_relics = whole_div.find('.checked span:first').text()  *1 #get number of checked relics
    console.log(checked_relics)
    all_relic = whole_div.find('.total span:first').text() *1 #get number of all relics
    console.log(all_relic)
    width_of_bg = whole_div.find('.bg').width() #get width of gray pogress bar
    console.log(width_of_bg)
    if width_of_bg > 900  # set width of gray progress bar to max of its background
      width_of_bg = 900
    val = checked_relics * 100 / all_relic  #calculate width of colored pogress bar
    console.log(val)
    whole_div.find('.color').css "width", val + "%"
    val2 = checked_relics * width_of_bg / all_relic + 16  #calculate position of a tag
    console.log(val2)
    whole_div.find('.checked').css "left", val2 + "px"

$(document).ready ->
  calc_progress_bar()

$(window).resize ->
  calc_progress_bar()