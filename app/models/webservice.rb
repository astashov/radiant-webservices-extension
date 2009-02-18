class Webservice < ActiveRecord::Base
  
  validates_presence_of :base_url, :title
  validates_uniqueness_of :title
  
  attr_reader :parameters
  
  def load(input_params)
    @parameters ||= {}
    rules = YAML.load(self.rule_scheme)
    load_date(input_params) if input_params[:date]
    rules.each do |param, param_rules|
      param_rules.each do |rule|
        result = rule.delete('result')
        if should_use_current_rule?(rule, input_params)
          result = substitute_variables_in_result(result, input_params)
          @parameters[param.to_sym] = result
          break
        end
      end
    end
  end
  
  
  private
  
    def load_date(input_params)
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
      rule.each do |key, value|
        if value == '_any_'
          condition &&= true
        else
          condition &&= input_params[key.to_sym] == value
        end
      end
      condition
    end
  
end