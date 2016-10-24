namespace :sectionlocks do
    
    desc "Clean plan sections locks older than a day"
    task clean: :environment do
        puts "Cleaning plan sections locks ..."
        
        count = PlanSection.where("created_at < ?", 1.day.ago).count
        
        PlanSection.where("created_at < ?", 1.day.ago).each do |plansection|
            PlanSection.delete(plansection)
        end
        
        puts "Deleted " + count.to_s + " locks."
    end
end