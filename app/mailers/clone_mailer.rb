class CloneMailer < ApplicationMailer
  default from: 'noreply@turing.io'

  def send_notification
    @clone = params[:clone]
    mail(to: params[:email], subject: "Your Project Board is Ready")
  end
end
