namespace :usercleaning do

  desc "Remove users who haven't accepted invitation after 1 month."
  task non_accepted_invitations: :environment do
      puts "Suppression des utilisateurs invités il y a plus d'un mois, sans avoir accepté l'invitation ..."
      User.where("invitation_sent_at < ? AND invitation_accepted_at IS NULL ", 1.month.ago).each do |user|
          puts user.email + " supprimé."
          User.delete(user.id)
          user = nil
      end
  end

  desc "Anonymize users who haven't been connected for five years."
  task anonymize_users_after_5_years: :environment do
    puts "Anonymisation des utilisateurs non connectés depuis 5 ans ..."
    User.where("last_sign_in_at < ? ", 5.years.ago).each do |user|
      user.firstname = "Anonymous"
      user.surname = "User"
      user.email = "anonymous" + user.id.to_s + "@opidor.fr"
      user.last_sign_in_at = nil

      if user.save
        puts "Utilisateur " + user.id.to_s + " anonymisé."
        user = nil
      end

    end
  end

end
