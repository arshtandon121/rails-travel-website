class CampPolicy < ApplicationPolicy
  attr_reader :user, :camp

  def initialize(user, camp)
    @user = user
    @camp = camp
  end

  def show?
    user.admin? || user == camp.user
  end

  def update?
    user.admin? || user == camp.user
  end

  def destroy?
    user.admin?
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all  # Admins can see all camps
      elsif user.camp_owner?
        scope.where(user_id: user.id)  # Camp owners can only see their own camps
      else
        scope.none  # Default to no access if role is not defined
      end
    end
  end
end
