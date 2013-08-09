class TestUser

  ANONYMOUS = TestUser.new

  attr_accessor :username,
                :password,
                :first_name, 
                :last_name, 
                :accepted_terms_and_conditions,
                :allow_marketing_communications

  attr_accessor :access_token,
                :refresh_token,
                :id,
                :local_id

  attr_accessor :clients

  def initialize
    @clients = []
  end

  def generate_details
    @first_name = "John"
    @last_name = "Doe"
    @username = random_email
    @password = random_password
    @accepted_terms_and_conditions = true
    @allow_marketing_communications = true
    self
  end

  def register
    response = $zuul.register_user(self)
    if response.status == 200
      token_info = MultiJson.load(response.body)
      @access_token = token_info["access_token"]
      @refresh_token = token_info["refresh_token"]
      @id = token_info["user_id"]
      @local_id = @id[/\d+$/]
    end
    response
  end

  def register_client(client)
    response = client.register(@access_token)
    @clients << client if response.status == 200
    response
  end

end