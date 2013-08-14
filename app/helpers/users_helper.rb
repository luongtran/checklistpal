module UsersHelper
  def avatar_url(user)
    if user.is_facebook_account?
      nil
    else
      user.get_avatar_url
    end
  end
end
