class GuidanceGroup < ActiveRecord::Base
  	attr_accessible :organisation_id, :name

	#associations between tables
	belongs_to :organisation
	has_and_belongs_to_many :guidances, join_table: "guidance_in_group"
	has_and_belongs_to_many :projects, join_table: "project_guidance"

end
