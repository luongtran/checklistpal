class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
      can :manage 
    if user.has_role? :admin
      can :manage, :all
    elsif user.has_role? :free
      can [:create , :update , :destroy],[List,Task]
    elsif user.has_role? :paid
      can [:create , :update , :destroy],[List,Task] 
    end
  end
end
