require 'rails_helper'

# enable these lines if you need HTTP level debugging
# stack = Faraday::RackBuilder.new do |builder|
#   builder.use Faraday::Request::Retry, exceptions: [Octokit::ServerError]
#   builder.use Octokit::Middleware::FollowRedirects
#   builder.use Octokit::Response::RaiseError
#   builder.use Octokit::Response::FeedParser
#   builder.response :logger
#   builder.adapter Faraday.default_adapter
# end
# Octokit.middleware = stack

describe ProjectBoardCloner do
  let(:instructor) { create(:instructor) }
  let(:student)    { create(:student, nickname: 'student') }

  let(:org_name) { 'turingschool-examples'}
  let(:repo_name) { 'watch-and-learn' }
  let(:project) {
    create(:project,
           name: "BE3 Group Project",
           user: instructor,
           project_board_base_url: "https://github.com/#{org_name}/#{repo_name}/projects/1",
           github_column: 9804554
          )
  }

  let(:clone) {
    create(:clone,
           students: "Richard H.",
           project: project,
           user: student
          )
  }

  let(:staff_client)   { Octokit::Client.new(access_token: instructor.token) }
  let(:student_client) { Octokit::Client.new(access_token: student.token) }

  let(:github_student)         { double(:github_user, login: student.nickname) }
  let(:base_project_on_github) { double(:github_project, number: 1, id: 9999) }
  let(:forked_repo)            { double(:forked_repo, full_name: "#{student.nickname}/#{repo_name}", name: repo_name, owner: github_student, full_path: "https://github.com/student/brownfield-of-dreams") }
  let(:cloned_project)         { double(:project, id: 1, html_url: "http://github.com/#{student.nickname}/#{repo_name}") }
  let(:invitation)             { double(:invitation, repository: forked_repo, id: 1234) }
  let(:column)                 { double(:column, name: "To Do") }

  subject { ProjectBoardCloner.new(project, clone, "student@example.com") }

  context "#run" do
    it "clones the repo while making the correct calls to Octokit" do
      allow(subject).to receive(:student_client).and_return(student_client)
      allow(subject).to receive(:staff_client).and_return(staff_client)

      expect(student_client).to receive(:fork).and_return(forked_repo)
      expect(student_client).to receive(:invite_user_to_repository)
      expect(student_client).to receive(:edit_repository).with(forked_repo.full_name, has_issues: true)
      expect(student_client).to receive(:create_project).with(forked_repo.full_name, project.name).and_return(cloned_project)

      expect(staff_client).to receive(:accept_repository_invitation)
      expect(staff_client).to receive(:user_repository_invitations).and_return([invitation])
      expect(staff_client).to receive(:projects).with("#{org_name}/#{repo_name}").and_return([base_project_on_github])
      expect(staff_client).to receive(:project_columns).with(9999).and_return([column])
      expect(ColumnCloner).to receive(:run!).with(column, forked_repo, "1", student_client)
      expect(staff_client).to receive(:create_project_card)

      subject.run
    end
  end
end
