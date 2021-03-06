@users @user_info
Feature: Updating a user's information
  As a user
  I want to be able to update information about myself
  So that I can keep my details up to date

  Background:
    Given I have registered an account

  @smoke
  Scenario: Updating email address, within critical elevation period
    Given I have a critically elevated access token
    When I change my email address
    And I request my user information be updated
    Then the response contains complete user information matching my new details
    And it is not cacheable
    And the critical elevation got extended

  @extremely_slow
  Scenario Outline: Updating email address, outside critical elevation period
    Given I have <elevation_level> access token
    When I change my email address
    And I request my user information be updated
    Then the request fails because I am unauthorised
    And the response includes low elevation level information

    Examples:
      | elevation_level |
      | an elevated     |
      | a non-elevated  |

  Scenario: Updating first name and last name, within critical elevation period
    Given I have a critically elevated access token
    When I change my first name to "Bob"
    And I change my last name to "Smith"
    And I request my user information be updated
    Then the response contains complete user information matching my new details
    And it is not cacheable
    And the critical elevation got extended

  @extremely_slow
  Scenario Outline: Updating first name and last name, outside critical elevation period
    Given I have <elevation_level> access token
    When I change my first name to "Bob"
    And I change my last name to "Smith"
    And I request my user information be updated
    Then the request fails because I am unauthorised
    And the response includes low elevation level information

    Examples:
      | elevation_level |
      | an elevated     |
      | a non-elevated  |

  Scenario: Updating marketing preferences, within critical elevation period
    Given I have a critically elevated access token
    When I change whether I allow marketing communications
    And I request my user information be updated
    Then the response contains complete user information matching my new details
    And it is not cacheable
    And the critical elevation got extended

  @extremely_slow
  Scenario Outline: Updating marketing preferences, outside critical elevation period
    Given I have <elevation_level> access token
    When I change whether I allow marketing communications
    And I request my user information be updated
    Then the request fails because I am unauthorised
    And the response includes low elevation level information

    Examples:
      | elevation_level |
      | an elevated     |
      | a non-elevated  |

  Scenario: Trying to change acceptance of terms and conditions
    When I change whether I accepted terms and conditions
    And I request my user information be updated
    Then the request fails because it is invalid

  Scenario: Trying to update user information without authorisation
    # RFC 6750 § 3.1:
    #   If the request lacks any authentication information (e.g., the client
    #   was unaware that authentication is necessary or attempted using an
    #   unsupported authentication method), the resource server SHOULD NOT
    #   include an error code or other error information.

    When I request my user information be updated, without my access token
    Then the request fails because I am unauthorised
    And the response does not include any error information

  Scenario: Trying to update client information
    When I do not change my details
    And I request my user information be updated
    Then the request fails because it is invalid

  Scenario: Trying to update user information for a different user
    For security reasons we don't distinguish between a user that doesn't exist and a user that
    does exist but is not the current user. In either case we say it was not found.

    Given another user has registered an account
    When I request the other user's information be updated
    Then the request fails because the user was not found