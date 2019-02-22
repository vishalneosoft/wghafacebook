module FutureEventsHelper
  def portfolio_filter(parsed_date, holidays = nil)
    result = []
    if parsed_date.friday? || parsed_date.saturday?
      result << 'weekend'
    end

    if parsed_date.beginning_of_day >= Time.zone.now.next_week && parsed_date.beginning_of_day <= Time.zone.now.next_week + 7.days
      result << 'next-week'
    end

    return result.join(' ')
  end
end
