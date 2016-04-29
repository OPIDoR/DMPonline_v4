namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    admin = User.create!(email: "benjamin.faure@inist.fr",
                 password: "password",
                 password_confirmation: "password")
    admin.add_role(:admin)
    admin.organisation_id = Organisation.find_by_name('DCC').id
    admin.skip_confirmation!
  end
end
