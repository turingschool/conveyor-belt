class GithubService
  def initialize(options = {})
    @conn = Faraday.new(url: "https://api.github.com") do |f|
      f.adapter  Faraday.default_adapter
      f.headers["Accept"] = "application/vnd.github.inertia-preview+json"
      f.headers["Authorization"] = "token #{options[:token]}"
      f.headers["Content-Type"] = "application/json"
    end
  end

  def create_board(owner, repo, project_name)
    body = { name: project_name }.to_json
    post_json("/repos/#{owner}/#{repo}/projects", body)
  end

  def create_column(project_id, name)
    body = { name: name }.to_json
    post_json("/projects/#{project_id}/columns", body)
  end

  def create_issue(repo_path, options = {})
    url = "/repos/#{repo_path}/issues"
    body = {
      title: options[:title],
      body: options[:body],
      labels: options[:labels]
    }
    post_json(url, body.to_json)
  end

  def create_issue_card(column_id, content_id)
    body = {
      content_type: "Issue",
      content_id: content_id
    }

    post_json("/projects/columns/#{column_id}/cards", body.to_json)
  end

  def create_note_card(column_id, note)
    body = { note: note }.to_json
    post_json("/projects/columns/#{column_id}/cards", body)
  end

  def issue(content_url)
    get_json(content_url)
  end

  def projects(owner, repo)
    response = conn.get("/repos/#{owner}/#{repo}/projects")
    JSON.parse(response.body, symbolize_names: true)
  end

  def columns(project_id)
    response = conn.get("/projects/#{project_id}/columns")
    JSON.parse(response.body, symbolize_names: true)
  end

  def cards(column_id)
    response = conn.get("/projects/columns/#{column_id}/cards")
    JSON.parse(response.body, symbolize_names: true)
  end

  private
    attr_reader :conn

    def get_json(url)
      response = conn.get(url)
      JSON.parse(response.body, symbolize_names: true)
    end

    def post_json(url, body)
      response = conn.post(url, body)
      JSON.parse(response.body, symbolize_names: true)
    end
end
