class WeekDaysInput < Formtastic::Inputs::StringInput
  def to_html
    input_wrapping do
      label_html <<
      template.content_tag(:div, class: 'week-days-input') do
        ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'].map do |day|
          template.content_tag(:div, class: 'day-input') do
            template.label_tag("#{object_name}[week_days][#{day}]", day.capitalize) +
            template.number_field_tag("#{object_name}[week_days][#{day}]", object.week_days[day], step: 0.01, min: 0)
          end
        end.join.html_safe
      end
    end
  end
end