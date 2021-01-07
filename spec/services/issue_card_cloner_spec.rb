require 'rails_helper'

RSpec.describe IssueCardCloner do
  describe 'GitHub API best practices' do
    it 'should pause at least one second after POST requests' do
      # Mock all dependencies
      labels = [{name: 'Big Problem'}, {name: 'Lotta Work'}]
      base_issue = double(:base_issue, title: 'Generic Issue Title', labels: labels, body: 'Super important task')
      cloned_issue = double(id: 1)
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
#
# template_card =  {
#   :url=>"https://api.github.com/projects/columns/cards/52175896",
#  :project_url=>"https://api.github.com/projects/10373898",
#  :id=>52175896,
#  :node_id=>"MDExOlByb2plY3RDYXJkNTIxNzU4OTY=",
#  :note=>nil,
#  :archived=>false,
#  :creator=>
#   {:login=>"BrianZanti",
#    :id=>8962411,
#    :node_id=>"MDQ6VXNlcjg5NjI0MTE=",
#    :avatar_url=>
#     "https://avatars3.githubusercontent.com/u/8962411?u=f9ab9972dc16076ec54e6efecb0ac7ea70eb05c0&v=4",
#    :gravatar_id=>"",
#    :url=>"https://api.github.com/users/BrianZanti",
#    :html_url=>"https://github.com/BrianZanti",
#    :followers_url=>"https://api.github.com/users/BrianZanti/followers",
#    :following_url=>
#     "https://api.github.com/users/BrianZanti/following{/other_user}",
#    :gists_url=>"https://api.github.com/users/BrianZanti/gists{/gist_id}",
#    :starred_url=>
#     "https://api.github.com/users/BrianZanti/starred{/owner}{/repo}",
#    :subscriptions_url=>"https://api.github.com/users/BrianZanti/subscriptions",
#    :organizations_url=>"https://api.github.com/users/BrianZanti/orgs",
#    :repos_url=>"https://api.github.com/users/BrianZanti/repos",
#    :events_url=>"https://api.github.com/users/BrianZanti/events{/privacy}",
#    :received_events_url=>
#     "https://api.github.com/users/BrianZanti/received_events",
#    :type=>"User",
#    :site_admin=>false},
#  :created_at=>2021-01-04 20:47:12 UTC,
#  :updated_at=>2021-01-04 20:47:15 UTC,
#  :column_url=>"https://api.github.com/projects/columns/12318778",
#  :content_url=>
#   "https://api.github.com/repos/turingschool-examples/little-esty-shop/issues/73"}
#
#
#
#
# cloned_column = {:url=>"https://api.github.com/projects/columns/12365983",
#  :project_url=>"https://api.github.com/projects/10465922",
#  :cards_url=>"https://api.github.com/projects/columns/12365983/cards",
#  :id=>12365983,
#  :node_id=>"MDEzOlByb2plY3RDb2x1bW4xMjM2NTk4Mw==",
#  :name=>"Backlog",
#  :created_at=>2021-01-07 20:38:42 UTC,
#  :updated_at=>2021-01-07 20:38:42 UTC}
# end
