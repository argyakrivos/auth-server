
Given(/^I have authenticated with my email address and password$/) do
  provide_credentials
  submit_authentication_request
  check_response_tokens
end

Given(/^I have provided my email address$/) do
  provide_credentials(include_password: false)
end

Given(/^I have provided my email address and password$/) do
  provide_credentials
end

Given(/^the email address is different from the one I used to register$/) do
  @credentials["username"] = random_email    
end

Given(/^the password is (missing|incorrect)$/) do |error_type|
  case error_type
  when "missing" then @credentials.delete("password")
  when "incorrect" then @credentials["password"] = random_password
  end
end

Given(/^I have provided my refresh token$/) do
  @credentials = {
    "grant_type" => "refresh_token",
    "refresh_token" => @oauth_response["refresh_token"]
  }
end

When(/^I submit the (?:authentication|access token refresh) request$/) do
  submit_authentication_request
end

Then(/^the response indicates that my credentials are incorrect$/) do
  @response.code.to_i.should == 400
  oauth_response = MultiJson.load(@response.body)
  oauth_response["error"].should == "invalid_grant"
end