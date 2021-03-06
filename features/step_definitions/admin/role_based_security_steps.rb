Given(/^I am authenticated as a user in the "(.*?)" role$/) do |role_name|
  # yes, this is a bit crap, but until we have role management it's about as good as we can do...
  @me = TestUser.new
  @me.username = "tm-books-itops@blinkbox.com"
  @me.password = "d41P8YETV7OjU^cufcu0"
  obtain_access_and_token_via_username_and_password
end

Given(/^I am authenticated as a user with no roles$/) do
  @me = TestUser.new.generate_details
  @me.register
  Cucumber::Rest::Status.ensure_status_class(:success)
end

When(/^I try to search for a user$/) do
  $zuul.admin_find_user({ username: random_email }, @me.access_token)
end

When(/^I try to get information for a user$/) do
  $zuul.admin_get_user_info(123, @me.access_token)
end