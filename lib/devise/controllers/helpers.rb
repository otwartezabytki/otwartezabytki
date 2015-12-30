module CustomDeviseHelper
  def authenticate_user!
    super
    if current_user
      if !current_user.terms_of_service? && request.path != accept_terms_path
        redirect_to accept_terms_path
      end
    end
  end
end
