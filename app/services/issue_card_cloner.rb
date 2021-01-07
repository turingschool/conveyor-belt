class IssueCardCloner
  def initialize(repo, template_card, cloned_column, client)
    @template_card  = template_card
    @repo           = repo
    @cloned_column  = cloned_column
    @client         = client
    @cloned_issue   = nil
  end

  def run
    create_issue!
    sleep(1)
    create_card!
    sleep(1)
  end

  def self.run(repo, template_card, cloned_column, client)
    new(repo, template_card, cloned_column, client).run
  end

  private
  attr_reader :template_card, :client, :clone, :cloned_issue, :cloned_column, :repo, :number

  def create_issue!
    options = {
      labels: base_issue.labels.map { |i| i[:name] }
    }

    @cloned_issue = client.create_issue(repo.full_name, base_issue.title, base_issue.body, options)
  end

  def create_card!
    options = {
      content_type: "Issue",
      content_id: cloned_issue.id
    }

    client.create_project_card(cloned_column.id, options)
  end

  def base_issue
    @base_issue = client.issue(repo_path, number)
  end

  def repo_path
    @repo_path ||= build_repo_path
  end

  def build_repo_path
    _repos, owner, repo_name, _issues, @number =  URI(template_card.content_url).path.split("/")[1..-1]
    @repo_path = "#{owner}/#{repo_name}"
  end
end
