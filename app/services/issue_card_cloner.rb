class IssueCardCloner
  def initialize(repo, template_card, cloned_column, client)
    @template_card  = template_card
    @repo      = repo
    @cloned_column  = cloned_column
    @client         = client
    @cloned_issue   = nil
  end

  def run
    create_issue!
    create_card!
  end

  def self.run(repo, template_card, cloned_column, client)
    new(repo, template_card, cloned_column, client).run
  end

  private
  attr_reader :template_card, :client, :clone, :cloned_issue, :cloned_column, :repo

  def create_issue!
    content = {
      title: base_issue[:title],
      body:  base_issue[:body],
      labels: base_issue[:labels].map { |i| i[:name] }
    }
    @cloned_issue = client.create_issue(repo.full_name, content)
  end

  def create_card!
    client.create_issue_card(cloned_column[:id], cloned_issue[:id])
  end

  def base_issue
    @base_issue ||= client.issue(template_card[:content_url])
  end
end
