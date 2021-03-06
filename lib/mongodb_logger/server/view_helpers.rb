# view helpers
module Sinatra::ViewHelpers
  
  def pretty_hash(hash)
    begin
      Marshal::dump(hash)
      h(hash.to_yaml).gsub("  ", "&nbsp; ")
    rescue Exception => e  # errors from Marshal or YAML
      # Object couldn't be dumped, perhaps because of singleton methods -- this is the fallback
      h(object.inspect)
    end
  end
  
  def string_from_log_message(message)
    message.is_a?(Array) ? message.join("\n") : message.to_s
  end
  
  def meta_informations(log)
    meta_data = Hash.new
    log.each do |key, val|
      # predefined fields
      next if [:_id, :messages, :request_time, :ip, :runtime, :application_name, :is_exception, :params, :method, :controller, :action, :path, :url].include?(key.to_sym)
      meta_data[key] = val
    end
    meta_data
  end
  
  # TODO: improve this
  def number_to_human_size(number, precision = 2)
    number = begin
      Float(number)
    rescue ArgumentError, TypeError
      return number
    end
    case
      when number.to_i == 1 then
        "1 Byte"
      when number < 1024 then
        "%d Bytes" % number
      when number < 1048576 then
        "%.#{precision}f KB"  % (number / 1024)
      when number < 1073741824 then
        "%.#{precision}f MB"  % (number / 1048576)
      when number < 1099511627776 then
        "%.#{precision}f GB"  % (number / 1073741824)
      else
        "%.#{precision}f TB"  % (number / 1099511627776)
    end.sub(/([0-9]\.\d*?)0+ /, '\1 ' ).sub(/\. /,' ')
  rescue
    nil
  end
  
  def text_field_tag(object, name, options = {})
    value = ""
    value = options.delete(:value) if options[:value]
    value = object.send name if object && object.respond_to?(name)
    attr = []
    options.each do |key, val|
      attr << "#{key}='#{val}'"
    end
    "<input type='text' name='#{object.form_name}[#{name.to_s}]' value='#{value}' #{attr.join(" ")} />"
  end
  
  def submit_tag(name, value, options = {})
    attr = []
    options.each do |key, val|
      attr << "#{key}='#{val}'"
    end
    "<input type='submit' name='#{name.to_s}' value='#{value}' #{attr.join(" ")} />"
  end
  
  def check_box_tag(object, name, options = {})
    value = nil
    value = options.delete(:value) if options[:value]
    value = object.send name if object && object.respond_to?(name)
    attr = []
    options.each do |key, val|
      attr << "#{key}='#{val}'"
    end
    "<input id='#{object.form_name}_#{name.to_s}' type='checkbox' name='#{object.form_name}[#{name.to_s}]' #{'checked="checked"' if value} value='1' #{attr.join(" ")} />"
  end
  
  def label_tag(object, name, label, options = {})
    attr = []
    options.each do |key, val|
      attr << "#{key}='#{val}'"
    end
    "<label for='#{object.form_name}_#{name.to_s}' #{attr.join(" ")}>#{label}</label>"
  end
  
  def select_tag(object, name, options_array, options = {})
    value = nil
    value = options.delete(:value) if options[:value]
    value = object.send name if object && object.respond_to?(name)
    attr = []
    options.each do |key, val|
      attr << "#{key}='#{val}'"
    end
    select_tag = []
    select_tag << "<select id='#{object.form_name}_#{name.to_s}' name='#{object.form_name}[#{name.to_s}]' #{attr.join(" ")}>"
    options_array.each do |val|
      if val.is_a?(Array) && 2 == val.length
        skey, sval = val[0], val[1]
      else
        skey = sval = val
      end
      select_tag << "<option value='#{skey}' #{"selected='selected'" if value && skey.to_s == value}>#{sval}</option>"
    end
    select_tag << "</select>"
    select_tag.join("\n")
  end
  
end