module Github
  class Repo
    def initialize(opts = {})
      @opts = opts
    end

    def enable_issues!
      client.edit_repository(repo_path, has_issues: true)
    end

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
