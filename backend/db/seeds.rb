if User.find_by(email: "admin@test.com").nil?
  User.create!(email: "admin@test.com", password: "password", role: User.roles[:superadmin])
end