# == Define: logstashforwarder::file
#
#  This define allows you to define files to be processed with logstash-forwarder
#
# === Parameters
#
# [*paths*]
#   File path(s) to files you want to process
#   Value type is Array
#   This variable is required
#
# [*dead_time*]
#   Set how long file should be kept open after rotated
#   Value type is String
#   This variable is optional
#
# [*fields*]
#   Fields you want to add to the event
#   Value type is Hash
#   Default value: undef
#   This variable is optional
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard.pijnenburg@elasticsearch.com>
#
define logstashforwarder::file(
  $paths,
  $dead_time = '',
  $fields = ''
) {

  validate_array($paths)

  $arr_paths = inline_template('<%= "[ "+@paths.sort.collect { |k| "\"#{k}\""}.join(", ")+" ]" %>')
  $opt_paths = "  \"paths\": ${arr_paths}"

  if ($dead_time != '') {
      $opt_dead_time = ",\n     \"dead time\": \"${dead_time}\""
  }

  if ($fields != '') {
    validate_hash($fields)
    $arr_fields = inline_template('<%= @fields.sort.collect { |k,v| "\"#{k}\": \"#{v}\"" }.join(", ") %>')
    $opt_fields = ",\n      \"fields\": { ${arr_fields} }\n    "
  }

  $content = "    {\n    ${opt_paths}${opt_dead_time}${opt_fields}}"

  logstashforwarder_fragment { $name:
    tag     => "LSF_CONFIG_${::fqdn}",
    content => $content,
    before  => Logstashforwarder_config['lsf-config']
  }
}
