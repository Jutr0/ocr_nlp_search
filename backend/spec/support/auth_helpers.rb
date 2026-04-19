module AuthHelpers
  # Returns headers hash with a valid JWT Authorization token for the given user.
  # Uses Devise::JWT::TestHelpers to generate the token without an HTTP round-trip.
  # Also sets Accept: application/json so controllers render .json.jbuilder views.
  def auth_headers(user)
    Devise::JWT::TestHelpers.auth_headers({ "Accept" => "application/json" }, user)
  end
end
