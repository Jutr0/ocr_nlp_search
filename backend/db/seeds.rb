if Users::User.find_by(email: "admin@test.com").nil?
  Users::User.create!(email: "admin@test.com", password: "password", role: :superadmin)
end