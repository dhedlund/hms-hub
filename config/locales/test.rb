# reverse English, useful for finding hard-coded text, used by tests
translations = YAML.load_file(Rails.root.join('config', 'locales', 'en.yml'))['en']

reverse_strings = lambda do |value|
  case value
    when String then value.reverse
    when Array  then value.map {|v| reverse_strings.call(v) }
    when Hash   then Hash[value.map {|k,v| [k, reverse_strings.call(v)] }]
    else value
  end
end

{ 'test' => reverse_strings.call(translations) }
