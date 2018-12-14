class ColumnCloner
  def initialize(column_template, clone, client)
    @column_template   = column_template
    @clone             = clone
    @client            = client
    @cloned_column     = nil
    @template_cards    = nil
  end

  def self.run(column_template, clone, client)
    new(column_template, clone, client).run
  end

  def run
    clone_column!
    clone_cards!
  end

  private
  attr_reader :column_template, :cloned_column, :clone, :client

  def clone_column!
    @cloned_column ||= client.create_column(clone.github_project_id, column_template[:name])
  end

  def clone_cards!
    template_cards.each do |template_card|
      if template_card[:content_url] # it's an issue
        IssueCardCloner.run(clone, template_card, cloned_column, client)
      else # it's a note
        client.create_note_card(cloned_column[:id], template_card[:note])
      end
    end
  end

  def template_cards
    @template_cards ||= client.cards(column_template[:id]).reverse
  end

end
