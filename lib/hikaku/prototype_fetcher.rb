module Hikaku
  class PrototypeFetcher < AppFetcher
    attr_reader :username, :password

    def initialize(params)
      super
      @username = params.fetch(:username)
      @password = params.fetch(:password)
      @agent = Mechanize.new
    end

    # For the prototype, we can just fetch pages one after the
    # other - we don't need to maintain a session because the
    # prototype has default values built-in
    def fetch_pages(docpaths)
      login(@agent)
      docpaths.map {|d| fetch(d)}
    end

    private

    def login(agent)
      agent.add_auth(base_url, username, password)
    end
  end
end
