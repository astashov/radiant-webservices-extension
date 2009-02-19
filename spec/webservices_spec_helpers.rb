module WebservicesSpecHelpers
   
  def login_as(user)
    controller.stub!(:authenticate).and_return(true)
    controller.stub!(:logged_in?).and_return(true)
    controller.stub!(:current_user).and_return(user)
    @current_user = user
  end
  
    
  # You may avoid to specify date, it will be constructed automatically
  # (for today, tomorrow, yesterday, lastweek, nextweek, thisweek or YYYYMMDD)
  def rules
    rules = <<END
content_type:
  -
    if:
      name: cosmic-calendar
      frequency: daily
    value: ":name"
  -
    if:
      name: "_any_"
    value: ":frequency_:name"

sign: ":sign"
END
  end
  
end