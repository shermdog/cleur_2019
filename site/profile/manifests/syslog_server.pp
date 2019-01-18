# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include profile::syslog_server
class profile::syslog_server (
  Boolean $noop = false,
  Boolean $purge = false,
  Hash $servers = {},
) {

  $servers.each |$server, $parameters| {
    syslog_server { $server:
      ensure           => $parameters[ensure],
      facility         => $parameters[facility],
      port             => $parameters[port],
      severity_level   => $parameters[severity_level],
      source_interface => $parameters[source_interface],
      vrf              => $parameters[vrf],
      noop             => $noop,
    }
  }

  # Purge unmanaged instances if enabled
  if $purge {
    resources { 'syslog_server':
      purge => true,
      noop  => $noop,
    }
  }

}