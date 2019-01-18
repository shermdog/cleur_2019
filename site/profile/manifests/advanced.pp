# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include profile::advanced
class profile::advanced (
  Hash $acls,
  Hash $vlans,
) {

  # ACLs
  # 'acls' hash contains the cisco_ace resources keyed by sequence number
  # 'defaults' hash contains defaults
  $acls['acls'].each | $acl, $aces | {
    cisco_acl { $acl:
      ensure          => present,
      stats_per_entry => true,
    }
    $aces.each | $seq, $ace | {
      cisco_ace { "${acl} ${seq}":
        * => $acls['defaults'] + $ace,
      }
    }
  }

  # vlans
  # 'vlans' hash contains the vlans keyed by vlan id
  # 'defaults' hash contains defaults
  $vlans['vlans'].each | $vlan, $params | {
    # need to deep merge defaults because they contain
    # a separate hsrp_group defaults hash
    $_params = deep_merge($vlans['defaults'], $params)

    # Add a require statement if there is an ACL configured
    if $_params['ipv4_acl_in'] {
      $_int_parms = $_params + { 'require' => "Cisco_acl[ipv4 ${$_params['ipv4_acl_in']}]" }
    }
    else {
      $_int_parms = $_params
    }

    cisco_vlan { $vlan:
      ensure    => 'present',
      shutdown  => false,
      state     => 'active',
      vlan_name => $_params['description'],
      noop      => $noop,
    }
    cisco_interface { "vlan${vlan}":
      * => $_int_parms - 'hsrp_group', # remove hsrp_group hash from params for this resource
    }
    cisco_interface_hsrp_group { "vlan${vlan} 1 ipv4":
      * => $_int_parms['hsrp_group']
    }
  }

}