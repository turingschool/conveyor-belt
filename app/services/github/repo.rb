module Github
  class Repo
    def initialize(opts = {})
      @opts = opts
    end

    def is_collaborator?(nickname)
      search = client.collaborators(repo_path).find do |collaborator|
        collaborator[:login] == nickname
      end

      !search.nil?
    end

    def confirm_invitation!
      page, per_page = 1, 100
      no_more_invitations, found_invitation = false, false

      until no_more_invitations || found_invitation
        invitations = client.user_repository_invitations(page: page, per_page: per_page)

        found_invitation = invitations.find do |invite|
          invite.repository.full_name == repo_path
        end

        if invitations.count < per_page
          no_more_invitations = true
        end

        page += 1
      end

      if found_invitation
        client.accept_repo_invitation(found_invitation.id)
      else
        raise Octokit::NotFound
      end



      # invites = client.repo_invitations(repo_path)
      # invite = invites.find do |invite|
      #   invite[:inviter][:login] == nickname
      # end
      # client.accept_repo_invitation(invite[:id]) if invite
    end

    def enable_issues!
      byebug
      client.edit_repository(repo_path, has_issues: true)
    end

    # Common usage
    # Github::Repo.is_contributor?(nickname: "jmejia", owner: "turingschool", repo: "creditcheck", access_token: "<SOME_TOKEN>")
    def self.is_collaborator?(opts = {})
      new(opts).is_collaborator?
    end

    # Common usage
    # Github::Repo.enable_issues!(owner: owner, repo: repo, access_token: access_token)
    def self.enable_issues!(opts = {})
      new(opts).enable_issues!
    end

    private
    attr_reader :opts

    def repo_path
      "#{opts[:owner]}/#{opts[:repo]}"
    end

    def client
      Octokit::Client.new(access_token: opts[:access_token])
    end
  end
end
