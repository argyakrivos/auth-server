@refresh_tokens
Feature: Refreshing an access token
  As a client application
  I want to be able to refresh an access token
  So that I can continue to call identity-based service

  Background:
    Given I have registered an account

  Scenario: Refreshing an access token using a refresh token
    Given I have provided my refresh token
    When I submit the access token refresh request
    Then the response contains an access token 

  Scenario: Trying to refresh an access token without a refresh token
    Given I have not provided my refresh token
    When I submit the access token refresh request
    Then the response indicates that the request was invalid

  Scenario: Trying to refresh an access token with an incorrect refresh token
    Given I have provided an incorrect refresh token
    When I submit the access token refresh request
    Then the response indicates that my refresh token is incorrect

  Scenario: Binding a refresh token to a client using client credentials
    Given I have registered a client
    And I have provided my refresh token and client credentials
    When I submit the access token refresh request
    Then the response contains an access token

  Scenario: Refreshing an access using a refresh token that is bound to a client, with client credentials
    Given I have bound my refresh token to a client
    And I have provided my refresh token and client credentials
    When I submit the access token refresh request
    Then the response contains an access token 

  Scenario: Trying to refresh an access using a refresh token that is bound to a client, without client credentials
    Given I have bound my refresh token to a client
    And I have provided my refresh token
    But I have not provided my client credentials
    When I submit the access token refresh request
    Then the response indicates that the client credentials are incorrect

