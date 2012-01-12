#!perl

use strict;
use warnings;
use Test::More;
use Module::Build;

eval "use Net::SNMP";
plan skip_all => "Net::SNMP required for testing Net::SNMP::Mixin module"
  if $@;

eval "use Net::SNMP::Mixin";
plan skip_all =>
  "Net::SNMP::Mixin required for testing Net::SNMP::Mixin module"
  if $@;

plan tests => 12;

#plan 'no_plan';

is( Net::SNMP->mixer('Net::SNMP::Mixin::CiscoDot1qVlanStaticTrunks'),
  'Net::SNMP', 'mixer returns the class name' );

my $builder        = Module::Build->current;
my $snmp_agent     = $builder->notes('snmp_agent');
my $snmp_community = $builder->notes('snmp_community');
my $snmp_version   = $builder->notes('snmp_version');

SKIP: {
  skip '-> no live tests', 11, unless $snmp_agent;

  my ( $session, $error ) = Net::SNMP->session(
    hostname  => $snmp_agent,
    community => $snmp_community || 'public',
    version   => $snmp_version || '2c',
  );

  ok( !$error, 'got snmp session for live tests' );
  isa_ok( $session, 'Net::SNMP' );
  ok(
    $session->can('cisco_vlan_ids2names'),
    'can $session->cisco_vlan_ids2names'
  );
  ok(
    $session->can('cisco_vlan_ids2trunk_ports'),
    'can $session->cisco_vlan_ids2trunk_ports'
  );
  ok(
    $session->can('cisco_trunk_ports2vlan_ids'),
    'can $session->cisco_trunk_ports2vlan_ids'
  );

  eval { $session->init_mixins };
  ok( !$@, 'init_mixins successful' );

  eval { $session->init_mixins(1) };
  ok( !$@, 'already initalized but reload forced' );

  eval { $session->init_mixins };
  like(
    $@,
    qr/already initalized and reload not forced/i,
    'already initalized and reload not forced'
  );

  eval { $session->cisco_vlan_ids2names };
  ok( !$@, 'cisco_vlan_ids2names' );

  eval { $session->cisco_vlan_ids2trunk_ports };
  ok( !$@, 'cisco_vlan_ids2trunk_ports' );

  eval { $session->cisco_trunk_ports2vlan_ids };
  ok( !$@, 'cisco_trunk_ports2vlan_ids' );

}

# vim: ft=perl sw=2
