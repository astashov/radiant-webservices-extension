require 'nokogiri'
require 'net/https'

class Webservice < ActiveRecord::Base
  
  validates_presence_of :base_url, :title
  validates_uniqueness_of :title
  validate :correct_yaml_in_rule_scheme
  
  attr_reader :parameters, :data
  
  def load!(input_params = nil)
    input_params ||= {}
    input_params.symbolize_keys!
    @parameters ||= {}
    rules = YAML.load(self.rule_scheme.to_s)
    rules = rules.blank? ? {} : rules
    load_date!(input_params) if input_params[:date]
    rules.each do |param, param_rules|
      if param_rules.is_a?(String)
        @parameters[param.to_sym] = substitute_variables_in_result(param_rules, input_params)
      else
        param_rules.each do |rule|
          result = rule.delete('value')
          unless result
            logger.error("\033[1;31mYou don't specify value in rule scheme of webservice '#{self.title}'\033[0m")
            break
          end
          if should_use_current_rule?(rule.delete('if'), input_params)
            result = substitute_variables_in_result(result, input_params)
            @parameters[param.to_sym] = result
            break
          end
        end
      end
    end
  end
  
  
  def get_data!
    qs_params = @parameters.inject([]) do |params, values| 
      params << "#{CGI.escape(values[0].to_s)}=#{CGI.escape(values[1].to_s)}"
    end
    url = self.base_url + '?' + qs_params.join("&")
    logger.info("\033[1;32mWe will use this URL: #{url}\033[0m")
    begin
      result = ""
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == "https")  # enable SSL/TLS
      http.start do
        http.request_get(uri.path + '?' + uri.query) { |res| result = res.body }
      end
      logger.debug("Webservice response:\n#{result}")
      @data = Nokogiri::XML.parse(result)
    rescue => msg
      logger.error("\033[1;31mCan't get webservice's data: #{msg.to_s}\033[0m")
      return nil
    end
  end
  
  
  def get_value(xpath)
    if @data && @data.root
      value = @data.at(xpath, @data.root.namespaces)
      value.blank? ? "<strong>Value is not found</strong>" : value.text.to_s
    end
  end
  
  
  private  
  
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
    
    
    def substitute_variables_in_result(result, input_params)
      result.gsub!(/:([a-zA-Z]+)/) do |s|
        input_params[$1.to_sym]
      end
      result.gsub('-', '_')
    end
    
    
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