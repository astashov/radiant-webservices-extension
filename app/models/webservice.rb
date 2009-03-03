require 'nokogiri'
require 'net/https'

class Webservice < ActiveRecord::Base
  include WebserviceParser
  
  validates_presence_of :base_url, :title
  validates_uniqueness_of :title
  validate :correct_yaml_in_rule_scheme
  
  # Parameters store key-value pairs that will be sent to remote webservice.
  # Data stores response of remote webservice.
  attr_reader :parameters, :data
  
  
  # Load parameters to @parameters getter.
  def load!(input_params = nil)
    input_params ||= {}
    input_params.symbolize_keys!
    @parameters ||= {}
    
    # There is built-in special rules for :date parameters
    @parameters[:date] = load_date(input_params[:date]) if input_params[:date]
    parameters = parse(:yaml => self.rule_scheme.to_s, :input_params => input_params)
    @parameters.merge!(parameters)
  end
  
  
  # Get response from remote webservice with parameters from @parameters getter. 
  # Set this response to @data getter.
  def get_data!
    # Create string of querystring parameters from hash like :key => value
    qs_params = @parameters.inject([]) do |params, values| 
      params << "#{CGI.escape(values[0].to_s)}=#{CGI.escape(values[1].to_s)}"
    end
    url = self.base_url + '?' + qs_params.join("&")
    logger.info("\033[1;32mWe will use this URL: #{url}\033[0m")
    
    # Trying to get data from webservice
    begin
      result = ""
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == "https")  # enable SSL/TLS
      result = http.request_get(uri.path + '?' + uri.query).body
      logger.debug("Webservice response:\n#{result}")
      @data = Nokogiri::XML.parse(result)
    rescue => msg
      logger.error("\033[1;31mCan't get webservice's data: #{msg.to_s}\033[0m")
      return nil
    end
  end
  
  
  # Get value by XPath from @data getter.
  def get_value(xpath)
    if @data && @data.root
      value = @data.at(xpath, @data.root.namespaces)
      value.blank? ? "" : value.text.to_s
    end
  end
  
  
  private  
  
    # Special rules for handling :date parameter. Convert 'today', 'tomorrow', 'yesterday'
    # and YYYYMMDD to MM/DD/YYYY and save it to @parameters getter
    def load_date(given_date)
      date = case
      when given_date == 'today'; Date.today
      when given_date == 'thismonth'; Date.civil(Date.today.year, Date.today.month, 1)
      when given_date == 'lastmonth'; Date.civil(Date.today.year, Date.today.month - 1, 1)
      when given_date == 'nextmonth'; Date.civil(Date.today.year, Date.today.month + 1, 1)
      when given_date == 'tomorrow'; Date.today + 1.day
      when given_date == 'yesterday'; Date.today - 1.day
      when given_date.match(/\d+_days_ago/); Date.today - given_date.match(/(\d+)_days_ago/)[1].to_i.days
      else; Date.strptime(given_date, '%Y%m%d') rescue Date.today
      end
      date.strftime("%m/%d/%Y")
    end
    
    
    # Validation rule. Check YAML in Rule Scheme (if it is not blank)
    def correct_yaml_in_rule_scheme
      error = false
      begin
        yaml = YAML.load(self.rule_scheme.to_s)
      rescue
        error = true
      end
      error = true if !yaml.blank? && yaml.is_a?(String)
      if error
        errors.add(:rule_scheme, "You should specify correct YAML format")
      end
    end
  
end