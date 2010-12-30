module ApplicationHelper
  
  # format a date from the updated_at column on a sensor like: Dec 30 2010 12:48pm
  def format_log_date(date)
    # meridian is AM/PM but we want to downcase for prettiness
    meridian = date.strftime("%p").downcase
    
    # append am/pm to formatted date
    date.strftime("%b %d %Y  %I:%M") + meridian
  end
  
end
