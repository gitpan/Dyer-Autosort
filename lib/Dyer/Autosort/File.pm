package Dyer::Autosort::File;
use strict;
use warnings;
use base 'File::PathInfo::Ext';
use File::Path;
use YAML;
use Carp;
our $VERSION = sprintf "%d.%02d", q$Revision: 1.8 $ =~ /(\d+)/g;

$Dyer::Autosort::File::DEBUG = 0;
sub DEBUG : lvalue { $Dyer::Autosort::File::DEBUG }


=pod

=head1 NAME

Dyer::Autosort::File

=cut

=head1 new()

	$ENV_DOCUMENT_ROOT = '/abspath/toclient';	

	my $f = new Dyer::Autosort::File('/abspath/toclient/filetosort-@WHATEVER.pdf');

=cut




sub abs_client {
	my $self= shift;
	$self->DOCUMENT_ROOT or croak(__PACKAGE__." missing DOCUMENT_ROOT, abs_client arg to constructor");
	return $self->DOCUMENT_ROOT;
}


sub rel_destination {
	my $self = shift;

	unless ( defined $self->{rel_destination} ){

		unless( $self->type_requirements_met ){
			carp(" cannot return rel_destination(), type requirements are not met for [".
				$self->abs_path."]");
			return;
		}

		my $destination_formula = $self->_type->{rel_destination};
		$destination_formula or warn("missing destination formula in conf type for type".
			$self->code."\n") and return;
		
	
		while ($destination_formula=~m/\{([^\{\}]+)\}/ ){
			my $field = $1;
			my $replacement = $self->_fhdata->{$field};
			$field or die("field not set");
			$replacement or die("replacement for $field missing");

			
			$destination_formula=~s/\{$field\}/$replacement/;
			print STDERR " = $field:$replacement\n" if DEBUG;

		}
		$self->{rel_destination} = $destination_formula;
	}
	
	return $self->{rel_destination};
}


sub abs_destination {
	my $self = shift;
	$self->rel_destination or return;
	return $self->abs_client .'/'.$self->rel_destination;
}

sub abs_destination_loc {
	my $self = shift;
	my $dest_loc = $self->abs_destination or return;
	$dest_loc=~s/\/[^\/]+$//;
	$dest_loc or die("no dest_loc");
	return $dest_loc;
}


sub _assure_destination_loc{
	my $self = shift;
	my $loc = $self->abs_destination_loc or die('cant get abs destination loc');
	#print STDERR "dest loc: $loc \n";
	if (-d $loc) { return 1; }
	File::Path::mkpath($loc) 
		or croak('cant autosort because cant assure that destination location '
			.$loc .' will be there');
	return 1;
}



sub sort {
	my $self = shift;

	print STDERR "sort called for ".$self->abs_path ."\n" if DEBUG;

	unless( $self->code ){
		print STDERR " no code.\n" if DEBUG;
		return;
	}
	print STDERR " code found ".$self->code."\n" if DEBUG;
	
	unless($self->type_requirements_met){
		print STDERR " requirements not met\n" if DEBUG;
		return;
	}

	print STDERR " type requirements met\n" if DEBUG;

	unless( $self->abs_destination ){
		print STDERR " cant get abs destination\n" if DEBUG;
		return;
	}

	print STDERR " abs_destination gotten\n" if DEBUG;
	
	unless( $self->_assure_destination_loc ){
		print STDERR " cant assure destination location\n" if DEBUG;
		return;
	}	
	
	print STDERR " abs_destination_loc assured\n" if DEBUG;
	
# TODO may seriously need to use File::PathInfo::Ext for this, otherwise metadata is lost.


	
	$self->move($self->abs_destination)
		or carp(__PACKAGE__.'::sort() cant move from:'.$self->abs_path ."\n to:".$self->abs_destination) and return;

	print STDERR " file moved/sorted.\n" if DEBUG;



#	File::Copy::move($self->abs_path, $self->abs_destination) 
#		or carp('cant move from:'.$self->abs_path ."\n to:".$self->abs_destination) and return;
	
	return 1;	
}


sub unsort {
	my $self = shift;
	print STDERR "unsort called for ".$self->abs_path ."\n" if DEBUG;

	unless( $self->code ){
		print STDERR " no code, will not unsort.\n" if DEBUG;
		return;
	}
	
	if ( $self->move( $self->DOCUMENT_ROOT.'/incoming/'.$self->filename)   ){
		print STDERR __PACKAGE__."::unsort moved to ".$self->abs_path."\n";
		return 1;
	}
	else {
		carp(__PACKAGE__.'::sort() cant move from:'.$self->abs_path ."\n to:".$self->abs_destination) and return;
	}	

#	File::Copy::move($self->abs_path, $self->abs_destination) 
#		or carp('cant move from:'.$self->abs_path ."\n to:".$self->abs_destination) and return;
	
	return 1;	

}


=head2 sort()

=head2 unsort()

=cut


## from DyerAutosort.pm


sub code {
	my $self = shift;	
	return $self->_fhdata->{code};
}

sub filename_fixed {
	my $self = shift;	
	return $self->_fhdata->{filename_fixed};
}

sub dd {
	my $self = shift;	
	return $self->_fhdata->{dd};
}

sub yy {
	my $self = shift;	
	return $self->_fhdata->{yy};
}

sub yyyy {
	my $self = shift;	
	return $self->_fhdata->{yyyy};
}

sub mm {
	my $self = shift;	
	return $self->_fhdata->{mm};
}
sub MM {
	my $self = shift;	
	return $self->_fhdata->{MM};
}


sub vendor_name {
	my $self = shift;	
	return $self->_fhdata->{vendor_name};
}

sub checknum {
	my $self = shift;	
	return $self->_fhdata->{checknum};
}

sub date_found {
	my $self = shift;	
	return $self->_fhdata->{date_found_flag};
}

sub _fhdata {
	my $self = shift;
	$self->{_fhdata} ||= fields_hash($self->abs_path);
	return $self->{_fhdata};
}

##


sub conf {
	my $self = shift;
	$self->{abs_types_conf} ||= '/etc/autosort.conf';
	
	unless( $self->{conf} ){
		$self->{conf} = YAML::LoadFile($self->{abs_types_conf}) 
			or croak("cant read ".$self->{abs_types_conf});
	}
	return $self->{conf};
}

sub _type {
	my $self = shift;
	$self->code or warn("has no code") and return;

	exists $self->conf->{types}->{$self->code} or warn(" code ".$self->code." has no type def in conf file")
		and return;
	
	my $type = $self->conf->{types}->{$self->code};
	## $type
	return $type;
}


sub type_requires {
	my $self = shift;	
	$self->code or return;
	$self->_type or print STDERR " type_requires(), no type defined:".$self->abs_path and return;
	
	ref $self->_type->{required} eq 'ARRAY' 
		or carp("type ".$self->code." seems to be missing 'required' list in conf file") and return;
	
	return $self->_type->{required};	
}

sub type_requirements_met {
	my $self = shift;

	my $not_met=0;
	

	$self->type_requires or return 0;

	for ( @{$self->type_requires} ){
		print STDERR " -requirement: $_.. " if DEBUG;
		
		if (defined $self->_fhdata->{$_}){
		
			print STDERR "defined.. " if DEBUG;

			if( $self->_fhdata->{$_} and $self->_fhdata->{$_}=~/\w/){
				print STDERR 'value: '.$self->_fhdata->{$_}."\n" if DEBUG;
				next;
			}
		}
		
		print STDERR " value not met\n" if DEBUG;
		$not_met++; 		
	}
	if ($not_met) { return 0;}
	return 1;
}









#moved from DyerAutosort.pm
sub fields_hash {
	my $full=shift;
	$full=~s/^.+\///;
	$full=~m/\w/ or return;

	# return fields from filename
	my %f=();
	
	#print STDERR "\n\n-begin\n";

	#init #{{{
	%f = (
		filename=>0,
		filename_fixed=>0,
		date=>0,
		mm=>0,
		MM=>0,
		yy=>0,
		yyyy=>0,
		dd=>0,
		code=>0,
		checknum=>0,
		ext=>0,
		vendor_name=>0
	);

	my %MM=(
	'01'=>'January',
	'02'=>'February',
	'03'=>'March',
	'04'=>'April',
	'05'=>'May',
	'06'=>'June',
	'07'=>'July',
	'08'=>'August',
	'09'=>'September',
	'10'=>'October',
	'11'=>'November',
	'12'=>'December'	
	); #}}}

	$f{filename}=$full;
	$f{filename_fixed}=$full;
	my $filename=$full;
	
	# extension
	if ($filename=~s/\.(\w{2,4})$//){
		$f{ext}=$1;
	} 
	
	# code
	if ($filename=~s/[\- ]?(@[A-Z]+)//){ 
		$f{code}=$1;	
	} 
	

	
	#cleanup
	$f{filename_fixed}=~s/VOID\-?//;	
	#$filename=~s/^VOID-?//;



	my $date_found_flag=0;
	#get date 
	if ($filename=~m/([01][0-9])([0-3][0-9])([09][0-9])[\- ]?/){
	#$filename=~s/-*([01][0-9])([0-3][0-9])([09][0-9])-*//){
	my ($a,$b,$c)=($1,$2,$3);
	
	#if ($filename=~s/-*([01]?[0-9])([0-3][0-9])([00][0-9])-*//){
			#print STDERR "fullpath[$f{filename}] match $a $b $c\n";
			
			if ($b<32 and $a<13) {			
				($f{mm}, $f{dd}, $f{yy}) = ($a, $b, $c); my $dr_HACK="$f{mm}$f{dd}$f{yy}";
				
				if ($f{mm}=~m/^\d$/ ){
					$f{mm}="0$f{mm}";
					$f{filename_fixed}=~s/$dr_HACK/$f{mm}$f{dd}$f{yy}/;					
				}
				$f{MM} = $MM{$f{mm}};			
				if ($f{yy}=~m/^0/){
					$f{yyyy}='20'.$f{yy};
				} else {
					$f{yyyy}='19'.$f{yy};
				}
				$date_found_flag=1;
				
			}
			
			$filename=~s/-?$a$b$c-?//;
	} #else { print STDERR "fullpath[$f{filename}] not matching ([01][0-9])([0-3][0-9])([09][0-9])\n";}
	

	#check num
	if($filename=~s/-?(\d{5,9})$//){
		$f{checknum}=$1;
	} 

	
	#$f{filename_fixed}=~s/&/and/g;
	$f{filename_fixed}=~s/'//g;
	#$filename=~s/&/and/g;
	$filename=~s/'|"|\+|\$|\#|\(|\)|\{|\}|\=|\|\^|\%|\!|\:|\;|\,|\*|\[|\]|\?|\<|\>//g;
	
	#what's left is the vendorname
	if($filename=~m/\w/){
		$filename=uc($filename);
		$filename=~s/^\W|\W$//g; # get rid of any leading and ending non word chars
		$filename=~s/\W|_/ /g;
		$filename=~s/ {2,}/ /g;
		
		$f{vendor_name}=$filename;
		$f{vendor_name}=~s/^VOID//;
	}

	if (!$date_found_flag and 
		$filename=~s/-*([12][09][8901][0-9])-*// 
			and ($f{code} ne '@AP' 
				and $f{code} ne '@APV')){
		
		$f{yyyy}=$1;		

		unless($f{mm} and $f{dd} and $f{yy}){
			$f{mm}=12;
			$f{dd}=31;
			$f{yy}=$f{yyyy};
			$f{yy}=~s/^\d{2}//;
			
			$f{filename_fixed}="$f{mm}$f{dd}$f{yy}-$f{filename_fixed}";
			
		}
	} 
	
	
	#if ($f{filename} eq $f{filename_fixed}){ $f{filename_fixed}=0; }
	unless ($f{filename} eq $f{filename_fixed}) {
	#print STDERR "fixed $f{filename} -> $f{filename_fixed}\n";
	}
	#print STDERR "mm $f{mm} - dd $f{dd} - yy $f{yy} - yyyy $f{yyyy} \n\n";

	if (DEBUG){
		print STDERR "fields_hash() called..\n";
		### %f
	}

	
	return \%f;
}

=head2 fields_hash()

arg is abs path to file

=cut

=head1 AUTHOR

Leo Charre lcharre at dyercpa dot com

=cut

1;

