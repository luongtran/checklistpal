module UsersHelper
  def avatar_url(user)
    user.get_avatar_url
  end
end
