class IssueCardCloner
  def initialize(clone, template_card, cloned_column, client)
    @template_card  = template_card
    @clone = clone
    @cloned_column  = cloned_column
    @client         = client
    @cloned_issue   = nil
  end

  def run
    create_issue!
    create_card!
  end

  def self.run(clone, template_card, cloned_column, client)
    new(clone, template_card, cloned_column, client).run
  end

  private
  attr_reader :template_card, :client, :clone, :cloned_issue, :cloned_column

  def create_issue!
    content = {
      title: base_issue[:title],
      body:  base_issue[:body],
      labels: base_issue[:labels].map { |i| i[:name] }
    }
    @cloned_issue = client.create_issue(clone.owner, clone.repo_name, content)
  end

  def create_card!
    client.create_issue_card(cloned_column[:id], cloned_issue[:id])
  end

  def base_issue
    @base_issue ||= client.issue(template_card[:content_url])
  end
end
