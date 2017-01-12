json.project_title @exported_plan.plan.project.title
json.phase_title @exported_plan.plan.version.phase.title

details = @exported_plan.admin_details

if details.present?
  json.details do
    details.each do |field|
      value = @exported_plan.send(field)
      json.set! field.to_sym, value if value.present?
    end
  end
end

json.sections do
  @exported_plan.sections.each do |section|
    json.set! section.number do
      json.title section.title
      json.questions do
        @exported_plan.questions_for_section(section.id).each do |question|
          json.set! question.number do
            cleaned_q = Nokogiri::HTML(question.text.gsub(/<li>/, ' * ')
                                                    .gsub("\n", '\\n')
                                                    .gsub("\r", ' ')).text
            json.question_text strip_tags(cleaned_q)

            answer = @exported_plan.plan.answer(question.id, false)
            q_format = question.question_format

            if answer.present?
                if (q_format.title == "Check box" || q_format.title == "Multi select box" ||
                                        q_format.title == "Radio buttons" || q_format.title == "Dropdown")
                  json.selections do
                    answer.options.each do |o|
                      json.set! o.number, o.text
                    end
                  end
                  if question.option_comment_display == true
                    json.comment_text (answer.try(:text) || 'No comment')
                  end
                else
                    cleaned_a = Nokogiri::HTML((answer.try(:text) || 'Question not answered')
                                                            .gsub(/<li>/, ' * ')
                                                            .gsub("\n", '\\n')
                                                            .gsub("\r", ' ')).text
                    json.answer_text strip_tags(cleaned_a)
                end
            end
          end
        end
      end
    end
  end
end
