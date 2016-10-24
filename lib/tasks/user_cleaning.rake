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
end