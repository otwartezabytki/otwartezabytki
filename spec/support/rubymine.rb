# http://pivotallabs.com/standup-03-05-2012/
if ENV["RUBYMINE_HOME"]
  $:.unshift(File.expand_path("rb/testing/patch/common", ENV["RUBYMINE_HOME"]))
  $:.unshift(File.expand_path("rb/testing/patch/bdd", ENV["RUBYMINE_HOME"]))
end
