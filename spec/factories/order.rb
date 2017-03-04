FactoryGirl.define do
  factory :order do
    total { (rand() * 100).to_i }
    user
  end
end