require 'nokogiri'
require 'net/https'

class Webservice < ActiveRecord::Base
  
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
    
    # If there is no rules in rule_scheme, we will not set parameters.
    rules = YAML.load(self.rule_scheme.to_s)
    rules = rules.blank? ? {} : rules
    
    # There is built-in special rules for :date parameters
    load_date!(input_params) if input_params[:date]
    
    rules.each do |param, param_rules|
      # If rule string looks like: 'key: value', then just set substituted value to parameter
      if param_rules.is_a?(String)
        @parameters[param.to_sym] = substitute_variables_in_result(param_rules, input_params)
      else
        # If current rule is array of recored, we will parse it bu usual way
        param_rules.each do |rule|
          # Special key 'value' will be set to parameter if key 'if' is true
          result = rule.delete('value')
          unless result
            logger.error("\033[1;31mYou don't specify value in rule scheme of webservice '#{self.title}'\033[0m")
            break
          end
          
          # Special key 'if' contains number of rules. If these rules are true, 
          # 'result' will be set to parameters.
          if should_use_current_rule?(rule.delete('if'), input_params)
            result = substitute_variables_in_result(result, input_params)
            @parameters[param.to_sym] = result
            break
          end
        end
      end
    end
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
    def load_date!(input_params)
      given_date = input_params[:date]
      date = case
      when given_date == 'today'; Date.today
      when given_date == 'tomorrow'; Date.today + 1.day
      when given_date == 'yesterday'; Date.today - 1.day
      else; Date.civil(given_date[0..3].to_i, given_date[4..5].to_i, given_date[6..7].to_i)
      end
      @parameters[:date] = date.strftime("%m/%d/%Y")
    end
    
    
    # Substitute input parameters to 'value' value. Also, If rule_scheme has string:
    # 'value: ':name_:city' (with colons), and input params were 
    # {:name => 'geo', :city => "London"}, value will be: 'geo_London'
    def substitute_variables_in_result(result, input_params)
      result.gsub!(/:([a-zA-Z]+)/) do |s|
        input_params[$1.to_sym]
      end
      result.gsub('-', '_')
    end
    
    
    # It compares given hash of rules with input params and if all of these
    # are true, it returns true. There are also special "_any_" value. It is true in any case.
    # Example:
    # Rule_scheme:
    # 
    #   city:
    #     -
    #       if:
    #         name: SanFrancisco
    #       value: "special_:name"
    #     -
    #       if:
    #         name: "_any_"
    #       value: ":name"
    # 
    # It will convert name => 'SanFrancisco' from input parameters to city => 'special_SanFrancisco',
    # but all other cities will be handled without changes (e.g., if name = 'Chicago',
    # city will be 'Chicago' too.
    def should_use_current_rule?(rule, input_params)
      condition = true
      if rule && rule.is_a?(Hash)
        rule.each do |key, value|
          if value == '_any_'
            condition &&= true
          else
            condition &&= input_params[key.to_sym] == value
          end
        end
      end
      condition
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
        errors.add(:rule_scheme, "You should specifify correct YAML format")
      end
    end
  
end