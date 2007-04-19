package Dyer::Autosort;
use Dyer::Autosort::File;
use strict;
use Carp;
use warnings;
our $VERSION = sprintf "%d.%02d", q$Revision: 1.4 $ =~ /(\d+)/g;

my $DEBUG = 0;
sub DEBUG : lvalue { $DEBUG }



=pod

=head1 NAME

Dyer::Autosort - sort and unsort client files to and from incoming

=head1 SYNOPSIS

	my $client = new DyerAutosortClient({
		abs_client => '/srv/doc/Clients/Joe Montenegro',
	});

=head1 DESCRIPTION

Imagine you have a lot of files in a server. Various people edit these files, create directories for them,
and organize them as they see fit. For example, users organize files by 'year', 'author', etc- and they
want to actually have the file system hierarchy as 1975/bubba/file.txt

If you name your files descriptively, autosort allows you to create a file hierarchy by filename.

A master configuration file defines rules, for example if we have 'recipies' files, which we will order
by meal eaten with, and the date it was entered.
Then we name our recipe files:

	021289-Super Marvelous Food-@DI.txt
	021290-Another Super Food-@BR.txt

Maybe we want to organize our recipies by authors. So we have:

	/storage/joe

We make an incoming directory for joe:

	/storage/joe/incoming

We place the files there:

	/storage/joe/incoming/021289-Super Marvelous Food-@DI.txt
	/storage/joe/incoming/021290-Another Super Food-@BR.txt

We add to the YAML configuration file :

	---
	types:
	 '@DI':
	   rel_destination: 'Recipies/Dinner/{yyyy}/{filename}'
	   required:
		 - code
		 - ext
		 - filename
		 - yyyy
	 '@BR':
	   rel_destination: 'Recipies/Breakfast/{yyyy}/{filename}'
		required:
		 - code
		 - ext
		 - filename
		 - yyyy

Then we use autosort script (included in dist) to automatically create the hierarchy:

	autosort -s /storage/joe

What if we change the rules in the configuration file? Then unsort and resort the hierarchy:

	autosort -u /storage/joe
	autosort -s /storage/joe


=head2 MOTIVATION

This whole thing was asked for at work to organize massive ammounts of documents.
At first I thought it was kind of nuts. Why not just place metadata to the files and sort them, 
find them etc.. via that? Using the filesystem as a database seemed crazy.
But the concern was partly that there were so many files, and they were used to the old way of 
working. 

This application basically lets users do things like scan in (and name) a million documents for a thousand
clients or users, and very quickly, the stuff goes to where they know it will be found. They can
use the filesystem to find the files.

If any rules change, or another kind of file is added, the change can be implemented quickly.

=head1 METHODS

The Dyer::Autosort package is the abstraction for one 'client' or 'account'. One directory structure in which 
we organize files into a tree, according to filename.

(Invidual file methods are in Dyer::Autosort::File)

=head2 new()

argument is hash ref
main argument is absolute path to client directory
returns undef if: directory does not exist
returns undef if: directory does not have an 'incoming' directory within it.

	my $client = new Dyer::Autosort({
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

=head2 has_incoming()

returns boolean, if client has incoming directory present
will likely deprecate

=cut

sub rel_incoming {
	my $self = shift;
	$self->{rel_incoming} ||='incoming';
	return $self->{rel_incoming};
}

=head2 rel_incoming()

returns relative path to incoming dir- relative to abs_client path

=cut

sub abs_incoming {
	my $self = shift;
	return $self->abs_client .'/'. $self->rel_incoming;
}

=head2 abs_incoming()

returns path to client incoming directory, where incoming files reside

=cut

sub abs_client {
	my $self= shift;
	return $self->{abs_client};
}

=head2 abs_client()

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

=head2 client_name()

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

=head2 _remove_empty_dirs()

called internally, removes empty dirs after an unsort operation.

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

	$a->unsort;

=cut

=head1 autosort.conf

by default the conf file is /etc/autosort.conf

a sample file is included.


=head1 CAVEATS

this is made to run as root pretty much, but it doesnt have to. you will have to tell the autosort script
and instances of this module that the conf file is elsewhere.


Please note, this software- altough in use, is still under development and needs more documentation.

At this point, if you can make use of this system, I suggest you shoot an email to the AUTHOR for assitance.

=head1 DEBUGGING

	Dyer::Autosort::DEBUG = 1;

Will set debug flags for both Dyer::Autosort and Dyer::Autosort::File

=head1 BUGS

Please email AUTHOR

=head1 AUTHOR

Leo Charre leocharre at cpan dot org

=cut

=head1 SEE ALSO

L<Dyer::Autosort::File>
autosort

=cut

1;
