class CloneMailer < ApplicationMailer
  default from: 'no-reply@turing.io'

  def send_notification
    @clone = params[:clone]
    mail(reply_to: 'iandouglas@turing.io', to: params[:email], subject: "Your Project Board is Ready")
  end
end
