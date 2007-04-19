use Test::Simple 'no_plan';
use lib './lib';
use Dyer::Autosort::File;
use Dyer::Autosort;
use Cwd;
use Smart::Comments '###';
use strict;
use constant DEBUG => 0;
my $a = new Dyer::Autosort({ abs_client => cwd().'/t/Testing_Client' });


ok( my $incoming = $a->ls_incoming);

### $incoming


for ( grep { !/BOGUS/ } @$incoming){
	my $f = new Dyer::Autosort::File({ abs_client => $a->abs_client, rel_path => "incoming/$_" });
	ok($f, "instanced file for $_");


	if ( $f->code ){
		ok($f->type_requires);
		(print STDERR "code ".$f->code."\n") if DEBUG;
		
		ok( my $requires = $f->type_requires );

		my $data = $f->_data;
		## $data

		## $requires
	
		if (DEBUG){
			print STDERR " vendor ".$f->vendor_name.", ";
			print STDERR " date found ".$f->date_found.", ";
			print STDERR " checknum ". $f->checknum.", ";
			print STDERR " dd ". $f->dd.", ";
			print STDERR " MM ". $f->MM.", ";
			print STDERR " yy ". $f->yy.", ";
			print STDERR " ext ". $f->ext.", ";
			print STDERR " filename ". $f->filename."\n";

			
			
		}	
		
		
		ok( $f->type_requirements_met,'type reqs met yes');
		
	
	}
	

}


# we know these are wrong..
for ( grep { /BOGUS/ } @$incoming){
	my $f = new Dyer::Autosort::File({ abs_client => $a->abs_client, rel_path => "incoming/$_" });


	ok( !$f->type_requirements_met);
}
