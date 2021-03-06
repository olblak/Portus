class RepositoryPolicy
  attr_reader :user, :repository

  def initialize(user, repository)
    @user = user
    @repository = repository
  end

  def show?
    @user.admin? ||
      @repository.namespace.public? ||
      @repository.namespace.team.users.exists?(user.id)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user.admin?
        @scope.all
      else
        # Show repositories only if the repository is public or
        # the repository belongs to the current_user
        @scope
          .joins(namespace: { team: :users })
          .where("namespaces.public = :namespace_public OR " \
                 "users.id = :user_id",
                  namespace_public: true, user_id: @user.id)
          .distinct
      end
    end
  end
end
