module WebserviceParser
  
  # Parse YAML rules and convert input params by these rules. Options:
  #
  #   * :input_params - hash of input parameters. Empty by default
  #   * :yaml - YAML rules, by string. Blank by default
  #   * :if - name of field with conditions. 'if' by default
  #   * :value - name of field with value that should be used if conditions are true. 'value' by default
  def parse(options = {})
    parameters = {}
    options[:input_params] ||= {}
    options[:input_params].symbolize_keys!
    options[:if] ||= 'if'
    options[:value] ||= 'value'
    
    # If there is no rules in rule_scheme, we will not set parameters.
    rules = YAML.load(options[:yaml].to_s)
    rules = rules.blank? ? {} : rules
    
    rules.each do |param, param_rules|
      # If rule string looks like: 'key: value', then just set substituted value to parameter
      if param_rules.is_a?(String)
        parameters[param.to_sym] = substitute_variables_in_result(param_rules, options[:input_params])
      else
        # If current rule is array of recored, we will parse it bu usual way
        param_rules.each do |rule|
          # Special key 'value' will be set to parameter if key 'if' is true
          result = rule.delete(options[:value])
          unless result
            logger.error(
              "\033[1;31mYou don't specify value in rule scheme of " +
              "#{self.class.to_s.underscore.humanize} '#{self.title}'\033[0m"
            )
            break
          end
          
          # Special key 'if' contains number of rules. If these rules are true, 
          # 'result' will be set to parameters.
          if should_use_current_rule?(rule.delete(options[:if]), options[:input_params])
            result = substitute_variables_in_result(result, options[:input_params])
            parameters[param.to_sym] = result
            break
          end
        end
      end
    end
    parameters
  end
  
  
  private
  
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

end