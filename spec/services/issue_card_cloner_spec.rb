require 'rails_helper'

RSpec.describe IssueCardCloner do
  describe 'GitHub API best practices' do
    it 'should pause at least one second after POST requests' do
      # Mock all dependencies
      labels = [{name: 'Big Problem'}, {name: 'Lotta Work'}]
      base_issue = double(:base_issue, title: 'Generic Issue Title', labels: labels, body: 'Super important task')
      cloned_issue = double(:cloned_issue, id: 1)
      client = double(:client, issue: base_issue, create_issue: cloned_issue, create_project_card: nil)
      repo = double(:repo, full_name: 'SomeGithubUser/some-repo')
      template_card = double(:template_card, content_url: "https://api.github.com/repos/example-org/example-repo/issues/1")
      cloned_column = double(:cloned_column, id: 1)

      time = Benchmark.measure {
        IssueCardCloner.run(repo, template_card, cloned_column, client)
      }
      expect(time.real).to be > 2 # 1 second for issue creation, 1 second for card creation
    end

    it 'should not parse URLs'

    it 'should not make requests for a single user or client id concurrently'

    it 'should make requests that trigger notifications at a reasonable pace'
  end
end
