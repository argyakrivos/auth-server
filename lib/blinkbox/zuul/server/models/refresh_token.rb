require "active_record"

module Blinkbox::Zuul::Server
  class RefreshToken < ActiveRecord::Base

    module Status
      VALID = "VALID"
      INVALID = "INVALID"
      NONE = "NONE"
    end

    module Elevation
      CRITICAL = "CRITICAL"
      ELEVATED = "ELEVATED"
      NONE = "NONE"
    end

    module LifeSpan
      TOKEN_LIFETIME_IN_DAYS = 90.0
      CRITICAL_ELEVATION_LIFETIME_IN_SECONDS = 10.minutes

      NORMAL_ELEVATION_LIFETIME_IN_SECONDS = 1.days
    end

    belongs_to :user
    belongs_to :client

    validates :token, length: { within: 30..50 }, uniqueness: true
    validates :expires_at, presence: true

    after_initialize :extend_lifetime
    after_create :set_initial_critical_elevation

    def extend_lifetime
      self.expires_at = DateTime.now + LifeSpan::TOKEN_LIFETIME_IN_DAYS
    end

    def elevation
      if self.critical_elevation_expires_at.future?
        Elevation::CRITICAL
      elsif self.elevation_expires_at.future?
        Elevation::ELEVATED
      else
        Elevation::NONE
      end
    end

    # Returns a boolean representing whether the refresh token is critically
    # elevated (true) or elevated/none (false)
    #
    # @return [Boolean] True if the refresh token has critical elevation.
    def critically_elevated?
      elevation == Elevation::CRITICAL
    end

    # Returns a boolean representing whether the refresh token is elevated
    # critical/elevated (true) or none (false)
    #
    # @return [Boolean] True if the refresh token has elevation.
    def elevated?
      elevation != Elevation::NONE
    end

    def extend_elevation_time
      case self.elevation
      when Elevation::CRITICAL
        self.critical_elevation_expires_at = DateTime.now + LifeSpan::CRITICAL_ELEVATION_LIFETIME_IN_SECONDS
      when Elevation::ELEVATED
        self.elevation_expires_at = DateTime.now + LifeSpan::NORMAL_ELEVATION_LIFETIME_IN_SECONDS
      end
      self.save!
    end

    def status
      self.expires_at.past? || self.revoked ? Status::INVALID : Status::VALID
    end

    def as_json(options = {})
      if status == RefreshToken::Status::INVALID
        return { "token_status" => RefreshToken::Status::INVALID }
      end

      json = { "token_status" => status, "token_elevation" => elevation }
      if elevation_expires_at.future?
        expiry_time = critically_elevated? ? critical_elevation_expires_at : elevation_expires_at
        json["token_elevation_expires_in"] = expiry_time.to_i - DateTime.now.to_i
      end
      json["user_roles"] = user.role_names if user.roles.any?
      
      json
    end

    private

    def set_initial_critical_elevation
      self.critical_elevation_expires_at = DateTime.now + LifeSpan::CRITICAL_ELEVATION_LIFETIME_IN_SECONDS
      self.elevation_expires_at = DateTime.now + LifeSpan::NORMAL_ELEVATION_LIFETIME_IN_SECONDS
      self.save!
    end
  end
end
