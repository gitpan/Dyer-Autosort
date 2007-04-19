use Test::Simple 'no_plan';
use Cwd;
use strict;
use warnings;
use lib './lib';
use Dyer::Autosort;
use Smart::Comments '###';

Dyer::Autosort::DEBUG = 0;

my $abs_client = cwd()."/t/Testing_Client";

	my $pending ;

my $a = new Dyer::Autosort({
		abs_types_conf	=> cwd().'/etc/autosort.conf',
		abs_client		=> $abs_client,
});
	
ok($a, 'instanced');


my $abs_incoming= $a->abs_incoming;
ok($abs_incoming,'abs_incoming()');
### $abs_incoming

ok($a->unsort, 'unsort() 1');
	
ok($a->unsorted_count,'unsorted_count()');
	


ok($a->unsort,'unsort() 2');
	
my $unsorted_count =  $a->unsorted_count;
ok($unsorted_count,"unsorted_count() $unsorted_count");	
	
  		
ok($a->sort, 'sort() 1');

ok($a->unsort,'unsort() 3' );


ok($a->sort, 'sort() 2');

