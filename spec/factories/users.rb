FactoryBot.define do
  factory :user, class: 'User' do
    email { "user#{SecureRandom.hex(4)}@example.com" }
    password { "password" }
    password_confirmation { "password" }
  end
end
