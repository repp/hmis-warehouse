FactoryGirl.define do
  factory :hud_service, class: 'GrdaWarehouse::Hud::Service' do
    sequence(:ServicesID, 7)
    sequence(:ProjectEntryID, 1)
    sequence(:PersonalID, 10)
  end
end
