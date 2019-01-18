# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include profile::banner
class profile::banner (
  String $motd,
  Boolean $noop = false,
) {

  banner { 'default':
    motd => $motd,
    noop => $noop,
  }

}