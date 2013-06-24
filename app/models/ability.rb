class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    if user.has_role? :admin
      can :manage, :all
    else
      #can :view, :member if user.has_role? :member
      #can :view, :vipmember if user.has_role? :paid
    end
  end
end
