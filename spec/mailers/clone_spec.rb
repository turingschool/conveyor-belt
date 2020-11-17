require "rails_helper"

RSpec.describe CloneMailer, type: :mailer do
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
           user: student,
           url: 'http://abc/123'
    )
  }

  it 'sends an email when cloning is complete' do
    CloneMailer.with(email: 'student@turing.io', clone: clone).send_notification.deliver_now

    expect(ActionMailer::Base.deliveries.count).to eq(1)
    email = ActionMailer::Base.deliveries.last

    expect(email.to).to eq(['student@turing.io'])
    expect(email.subject).to eq('Your Project Board is Ready')

    expect(email.reply_to).to eq(['iandouglas@turing.io'])

    expect(email.text_part.body.to_s).to include(clone.url)
    expect(email.html_part.body.to_s).to include(clone.url)
  end
end
