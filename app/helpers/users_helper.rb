module UsersHelper
  def avatar_url(user)
    if user.is_facebook_account?
      nil  # edit later
    else
      if user.avatar_file_name.nil?  # never upload avatar
        return nil
      else
        user.get_avatar_url
      end

    end
  end
end
