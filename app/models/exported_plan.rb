class ExportedPlan < ActiveRecord::Base
  attr_accessible :plan_id, :user_id, :format

  #associations between tables
  belongs_to :plan
  belongs_to :user

  VALID_FORMATS = %i( csv html json pdf text xml docx)

  validates :format, inclusion: { in: VALID_FORMATS, message: '%{value} is not a valid format' }

  # Store settings with the exported plan so it can be recreated later
  # if necessary (otherwise the settings associated with the plan at a
  # given time can be lost)
  has_settings :export, class_name: 'Settings::Dmptemplate' do |s|
    s.key :export, defaults: Settings::Dmptemplate::DEFAULT_SETTINGS
  end

  # Getters to match Settings::Dmptemplate::VALID_ADMIN_FIELDS
  def project_name
    name = self.plan.project.title
    name += " - #{self.plan.title}" if self.plan.project.dmptemplate.phases.count > 1
    name
  end

  def project_identifier
    self.plan.project.identifier
  end

  def grant_title
    self.plan.project.grant_number
  end

  def principal_investigator
    self.plan.project.principal_investigator
  end

  def project_data_contact
    self.plan.project.data_contact
  end

  def project_description
    self.plan.project.description
  end

  def funder
    org = self.plan.project.dmptemplate.try(:organisation)
    org.name if org.present? && org.organisation_type.try(:name) == I18n.t('helpers.org_type.funder')
  end

  def institution
    plan.project.organisation.try(:name)
  end

  # sections taken from fields settings
  def sections
    sections = self.plan.sections

    return [] if questions.empty?

    section_ids = questions.pluck(:section_id).uniq
    sections = sections.select {|section| section_ids.member?(section.id) }

    sections.sort_by(&:number)
  end

  def questions_for_section(section_id)
    questions.where(section_id: section_id)
  end

  def admin_details
    @admin_details ||= self.settings(:export).fields[:admin]
  end

  # Export formats

  def as_csv
    CSV.generate do |csv|
      csv << ["Section","Question","Answer","Selected option(s)","Answered by","Answered at"]
      self.sections.each do |section|
        self.questions_for_section(section).each do |question|
          answer = self.plan.answer(question.id)
          options_string = answer.options.collect {|o| o.text}.join('; ')
          cleaned_q = Nokogiri::HTML(question.text.gsub(/<li>/, ' * ')).text
          cleaned_a = Nokogiri::HTML(answer.try(:text).gsub(/<li>/, ' * ')).text

          csv << [section.title, cleaned_q, sanitize_text(cleaned_a), options_string, answer.try(:user).try(:name), answer.created_at]
        end
      end
    end
  end

  def as_txt
    output = "#{self.plan.project.title}\n\n#{self.plan.version.phase.title}\n"


    self.sections.each do |section|
      output += "\n#{section.title}\n"

      self.questions_for_section(section).each do |question|
        qtext = sanitize_text( question.text.gsub(/<li>/, '  * ') )
        output += "\n#{qtext}\n"
        answer = self.plan.answer(question.id, false)

        if answer.nil? || answer.text.nil? then
          output += "Question not answered.\n"
        else
          output += answer.options.collect {|o| o.text}.join("\n")
          if question.option_comment_display == true then
            output += "\n#{sanitize_text(answer.text)}\n"
          else
            output += "\n"
          end
        end
      end
    end

    output
  end

private

  def questions
    @questions ||= begin
      question_settings = self.settings(:export).fields[:questions]

      return [] if question_settings.is_a?(Array) && question_settings.empty?

      questions = if question_settings.present? && question_settings != :all
        Question.where(id: question_settings)
      else
        Question.where(section_id: self.plan.sections.collect {|s| s.id })
      end

      questions.order(:number)
    end
  end

  def sanitize_text(text)
    if (!text.nil?) then ActionView::Base.full_sanitizer.sanitize(text.gsub(/&nbsp;/i,"")) end
  end

end
