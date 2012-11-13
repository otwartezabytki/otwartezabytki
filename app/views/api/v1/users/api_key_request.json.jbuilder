json.user do |json|
  json.username     @user.username
  json.api_key      @user.api_key
  json.api_secret   @user.api_secret
end
