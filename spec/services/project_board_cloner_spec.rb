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
  let(:student)    { create(:student, nickname: "ClassicRichard") }

  let(:project) {
    create(:project,
           name: "BE3 Group Project",
           user: instructor,
           project_board_base_url: "https://github.com/turingschool-examples/watch-and-learn/projects/1",
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

  context '#run', :vcr do
    before :each do
      student_client.delete_repository('backburnerstudios/watch-and-learn')
      student_client.delete_repository('backburnerstudios/watch-and-learn-1')
      @subject = ProjectBoardCloner.new(project, clone, 'student@example.com')
    end
    after :each do
      student_client.delete_repository('backburnerstudios/watch-and-learn')
      student_client.delete_repository('backburnerstudios/watch-and-learn-1')
    end

    it 'forks the repo one time' do
      response = Faraday.get 'https://api.github.com/users/backburnerstudios/repos'
      expect(response.body).to_not include('backburnerstudios/watch-and-learn')

      @subject.run

      response2 = Faraday.get 'https://api.github.com/users/backburnerstudios/repos'
      expect(response2.body).to include('backburnerstudios/watch-and-learn')
      # these next two expectations fail because we're not actually getting OAuth scopes
      # expect(clone.github_project_id).to_not be_nil
      # expect(clone.url).to_not be_nil
    end

    xit 'invites the staff member to the repo' do
      allow(subject).to receive(:student_client).and_return(student_client)
      allow(student_client).to receive(:invite_user_to_repo)

      @subject.run

      expect(student_client).to have_received(:invite_user_to_repo).with("#{student.nickname}/watch-and-learn", instructor.nickname)
    end

    xit "accepts the staff member's invitation to the repo" do
      allow(subject).to receive(:staff_client).and_return(staff_client)
      allow(staff_client).to receive(:accept_repo_invitation)

      @subject.run

      expect(staff_client).to have_received(:accept_repo_invitation).once
    end

    xit 'creates a master project board' do
    end

    xit 'updates the clone in the database with URL'
    xit 'updates the master project board with a card referencing the cloned repo'
  end
end
