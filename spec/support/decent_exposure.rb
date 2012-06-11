def exposed(name)
  value = controller.send(name)
  value.should_not be_nil
  value
end