package Dyer::Autosort;
use Dyer::Autosort::File;
use strict;
use Carp;
use warnings;
our $VERSION = sprintf "%d.%02d", q$Revision: 1.3 $ =~ /(\d+)/g;

my $DEBUG = 0;
sub DEBUG : lvalue { $DEBUG }



=pod

=head1 NAME

Dyer::Autosort - sort and unsort client files to and from incoming

=head1 SYNOPSIS

	my $client = new DyerAutosortClient({
		abs_client => '/srv/doc/Clients/Joe Montenegro',
	});

=head1 new()

argument is absolute path to client directory
croaks if directory does not exist

	my $client = new DyerAutosortClient({
		abs_client => '/srv/doc/Clients/Joe Montenegro',
	});

=cut

sub new {
	my ($class, $self) = (shift, shift);
	$self ||= {};
	$self->{abs_client} || croak('missing arg to constructor: abs_client'); # path to /clients/joe
#	$self->{rel_incoming} ||= 'incoming';
	$self->{abs_types_conf} ||= '/etc/autosort.conf';
	
	bless $self, $class; 

	$self->_set_client or return;

	
	if( DEBUG ) {
		print STDERR "DEBUG Dyer::Autosort is on\n";
		Dyer::Autosort::File::DEBUG = 1;
	}



	
	return $self;
}





sub ls_incoming {
	my $self= shift;

	opendir(IDIR, $self->abs_incoming) or croak('cant open incoming');
	my @files = grep { !/^\.+$/ and -f  $self->abs_incoming."/$_" }  readdir IDIR;
	closedir IDIR;
	
	return \@files;
}

sub unsorted_count {
	my $self= shift; #TODO: what if files have been sorted, will this work properly
	return scalar @{ $self->ls_incoming };
}

=head2 ls_incoming()

returns array ref of files present in the client directory
this is not cached

=head2 unsorted_count()

returns count of unsorted files in incoming directory
if incoming directory does not exist, returns undef

=cut

sub has_incoming {
	my $self= shift;
	-d $self->abs_client.'/'.$self->rel_incoming or return 0;
	return 1;
}
=head1 has_incoming()

returns boolean, if client has incoming directory present

=cut

sub rel_incoming {
	my $self = shift;
	$self->{rel_incoming} ||='incoming';
	return $self->{rel_incoming};
}
=head1 rel_incoming()

returns relative path to incoming dir- relative to abs_client path

=cut

sub abs_incoming {
	my $self = shift;
	return $self->abs_client .'/'. $self->rel_incoming;
}
=head1 abs_incoming()

returns path to client incoming directory, where incoming files reside

=cut

sub abs_client {
	my $self= shift;
	return $self->{abs_client};
}
=head1 abs_client()

returns abs_path to client dir

=cut




sub _set_client {
	my $self = shift;	

	unless( -d $self->abs_client ){
		print STDERR $self->abs_client .' is not a dir. Cannot be autosort target.' if DEBUG;
		return;
	}
	unless( -d $self->abs_incoming ){
		print STDERR $self->abs_incoming ." does not exist. Cannot be autosort target. "
			."If you want this to be a client that can be autosorted, "
			."create an 'incoming' directory inside it." if DEBUG;
		return;
	}	
	return 1;
}

sub client_name {
	my $self= shift;
	$self->abs_client=~/[^\/]+$/ or die("cant match filename");
	my $name=$1;
	return $name;
}
=head1 client_name()

returns client name, just the name

=cut


sub _remove_empty_dirs {
	my $self = shift;
	print STDERR "called _remove_empty_dirs.. " if DEBUG;
	my $abs_client = $self->abs_client;

	$self->{empty_dirs_removed} = 0;	

	my $found_empty_dir=1; #startflag
	
	while ($found_empty_dir){
		 $found_empty_dir=0;
	
		my @ed = split( /\n/, `find "$abs_client" -type d -empty`);

		if (scalar @ed){
			for (@ed){
				my $d = $_;
				if ($d eq $self->abs_incoming){ next;} 
				rmdir ($_);
				$found_empty_dir++;	$self->{empty_dirs_removed}++;	
			}	
		}
	}
	print STDERR "removed ".$self->{empty_dirs_removed}.". done.\n" if DEBUG;
	

	return 1;
}

=head1 _remove_empty_dirs()

=cut

sub _load_types {
	my $self = shift;
	my $conf = YAML::LoadFile($self->{abs_types_conf}) or croak("cant read $$self{abs_types_conf}");	
	$self->{types} = $conf->{types};
	return 1;
}




sub sort {
	my $self = shift;
	my $sorted=0;
	print STDERR " sort called for ".$self->abs_client."\n" if DEBUG;
	for ( @{$self->ls_incoming}){
		my $filename = $_;
		my $file = new Dyer::Autosort::File({
			abs_client => $self->abs_client,
			rel_path => $self->rel_incoming."/$filename",		
			abs_types_conf => $self->{abs_types_conf},
		});
		if ($file->sort) {
			$sorted++; 
		}
		else {
		 print STDERR " not sorted [$filename]\n" if DEBUG;
		}
	}

	print STDERR "sorted $sorted, done.\n" if DEBUG;
	
	return $sorted;
} 

=head2 sort()

sorts any files that are in client's incoming directory.
creates a Dyer::Autosort::File object for each and calls method Dyer::Autosort::File::sort
for each

returns count of files succesfully sorted

=cut

sub unsort {
	my $self = shift;
	my $abs_client = $self->abs_client;
	print STDERR "unsort called.. " if DEBUG;

	my @files = split (/\n/,`find "$abs_client/" -type f -name "*\@*"`);
	my $rel_incoming = $self->rel_incoming;
	for (@files){
		my $from = $_;
		if ($from=~/^$abs_client\/+$rel_incoming/){ next;}
		my $tofn = $from;
		$tofn=~s/^.+\///;
		`mv "$from" "$abs_client/$rel_incoming/$tofn";`;		
	}
	
	$self->_remove_empty_dirs;

	print STDERR "unsort done.\n" if DEBUG;
	return 1;
}

=head2 unsort()

unsorts all files for this client.
will remove all empty directories

=cut



=head1 AUTHOR

Leo Charre leocharre at cpan dot org

=cut

=head1 SEE ALSO

Dyer::Autosort::File
DMS

=cut

1;
