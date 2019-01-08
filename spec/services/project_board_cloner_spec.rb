require "rails_helper"

describe ProjectBoardCloner do
  let(:instructor) { create(:instructor) }
  let(:student)    { create(:student, nickname: "ClassicRichard") }

  let(:project) {
    create(:project,
           name: "BE3 Brownfield Project",
           user: instructor,
           project_board_base_url: "https://github.com/turingschool-examples/brownfield-of-dreams/projects/1"
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

  subject { ProjectBoardCloner.new(project, clone) }

  context "#run", :vcr do
    it "forks the repo one time" do
      allow(subject).to receive(:student_client).and_return(student_client)
      allow(student_client).to receive(:fork)

      subject.run

      expect(student_client).to have_received(:fork).once.with("turingschool-examples/brownfield-of-dreams")
    end

    it "invites the staff member to the repo" do
      allow(subject).to receive(:student_client).and_return(student_client)
      allow(student_client).to receive(:invite_user_to_repo)

      subject.run

      expect(student_client).to have_received(:invite_user_to_repo).with("#{student.nickname}/brownfield-of-dreams", instructor.nickname)
    end

    it "accepts the staff member's invitation to the repo" do
      allow(subject).to receive(:staff_client).and_return(staff_client)
      allow(staff_client).to receive(:accept_repo_invitation)

      subject.run

      expect(staff_client).to have_received(:accept_repo_invitation).once
    end

    it "creates a master project board" do
    end

    xit "updates the clone in the database with URL"
    xit "updates the master project board with a card referencing the cloned repo"
  end
end
