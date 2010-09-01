package WebService::GData::Feed;
use WebService::GData;
use base 'WebService::GData';
our $VERSION  = 0.01_01;
	sub __init {
		my ($this,$feed,$auth) = @_;
		$this->{_feed}   = $feed->{feed} || $feed || {};
		$this->{_auth}   = $auth || undef;
	}

	sub title {
		my $this = shift;
		if(@_==1){
			$this->{_feed}->{title}->{'$t'}=$_[0];
		}
		$this->{_feed}->{title}->{'$t'};
	}
	sub updated {
		my $this = shift;
		$this->{_feed}->{updated}->{'$t'};
	}
	sub category {
		my $this = shift;
		$this->{_feed}->{category};
	}
	sub etag {
		my $this = shift;
		return $this->{_feed}->{feed}->{'gd$etag'};
	}
	sub author {
		my $this = shift;
		$this->{_feed}->{author};
	}
	##OPEN SEARCH 1.1 RESPONSE ELEMENTS
	sub total_results {
		my $this = shift;
		$this->{_feed}->{'openSearch$totalResults'}->{'$t'};
	}
	sub total_items {
		my $this = shift;
		return $this->total_results;
	}
	sub start_index {
		my $this = shift;
		$this->{_feed}->{'openSearch$startIndex'}->{'$t'};
	}
	sub items_per_page {
		my $this = shift;
		$this->{_feed}->{'openSearch$itemsPerPage'}->{'$t'};
	}
	sub links {
		my $this = shift;
		$this->{_feed}->{link};
	}


	sub link {
		my ($this,$type) = @_;
		my $links =  $this->links;
		foreach my $link (@$links){
			return $link->{href} if($link->{rel}=~m/$type/);
		}
	}

	sub previous_link {
		my ($this) = @_;
		return $this->get_link('previous');
	}

	sub next_link {
		my ($this) = @_;
		return $this->get_link('next');
	}

	#ok, i need to cleanup this mess...
	#entry works as a factory and loads the proper entry class
	sub entry {
		my ($this,$wanted_class)      = @_;

		my $entries   = $this->{_feed}->{entry} || [];
		$entries = [$entries] if(ref($entries) ne 'ARRAY');

		#default to the base Entry class
		my $class = qq[WebService::GData::Feed::Entry];

		if($wanted_class){
			$class = $wanted_class;
		}
		else {
			#from which service this request comes from...
			my $service   = ref($this);

			#what kind of feed is this??
			my $feedType  = $this->_get_feed_type;

			if($service=~m/GData::(.*)::/ && $feedType){
				my ($match,$ser) = $service=~m/GData::(.*)::/;
				$class = 'WebService::GData::'.$match.'::Feed::'.$feedType;
			}
		}

		eval("use $class");
	
		my @ret=();
		foreach my $entry (@$entries) {
			push @ret, $class->new($entry,$this->{_auth});
		}
		return \@ret;
	}	

	sub _get_feed_type {
		my $this = shift;

		my $feedTypeString = '';

		if($this->{_feed}->{category} || $this->{_feed}->{entry}->{category}){
			$feedTypeString = $this->{_feed}->{category}->[0]->{term} || $this->{_feed}->{entry}->{category}->[0]->{term};
		}
		#the feed type is after the anchor http://gdata.youtube.com/schemas/2007#video
		my $feedType  = (split('#',$feedTypeString))[1];
		   $feedType  = "\u$feedType";#Uppercase to load the proper class
		return $feedType;
	}


"The earth is blue like an orange.";

__END__


=pod

=head1 NAME

WebService::GData::Feed - Abstract class wrapping json atom feed for google data API v2.

=head1 VERSION

0.01

=head1 SYNOPSIS

	use WebService::GData::Feed;

    #create an object that only has read access
   	my $feed = new WebService::GData::Feed($jsonfeed,$auth);

    $feed->title;
	$feed->author;
	my @entries = $feed->entry();#send back WebService::GData::Feed::Entry or a service related Entry object 



=head1 DESCRIPTION

inherits from WebService::GData;

This package wraps the result from a query to a feed using the json format of the Google Data API v2 (no other format is supported!).

It gives you access to some of the data via wrapper methods and works as a factory to get access to the entries for each service.

If you use a YouTube service, calling the entry() method will send you back YouTube::Feed::Entry's. 

If you use a Calendar service, calling the entry() method will send you back a Calendar::Feed::Entry.

By default, it returns a WebService::GData::Feed::Entry which gives you only a read access to the data.

Unless you implement a service, you should never instantiate this class directly.

=head1 METHODS


=head2 new

=over

Accept a json feed entry that has been perlified (from_json($json_string)) and an auth object.

The auth object is passed along each entries classes but the Feed class itself does not use it.


=head2 title

=over

set/get the title of the feed.

=head2 updated

=over

get the last updated date of the feed.


=head2 category

=over

Get the categories of the feed in a array reference containing hash references with scheme/term keys.

=head2 etag

=over

Get the etag of the feed.

=head2 author

=over

Get the author of the feed.

=head2 total_items

=over

Get the total result of the feed.

=head2 total_results

=over

Get the total result of the feed. Alias for total_items

=head2 start_index

=over

Get the start number of the feed.

=head2 items_per_page

=over

Get the the link of items per page.

=head2 links

=over

Get the links of the feed in a array reference containing hash references with rel/type/href keys.	

=head2 link

=over

Get a specific link entry by looking in the rel attribute of the link tag.

Example:

    my $previous_url= my $feed->get_link('previous');
    
	#create a new entry with application/x-www-form-urlencoded content-type
    my $batch_url= my $feed->get_link('batch');


=head2 previous_link

=over

Get a the previous link if set or undef.

=head2 next_link

=over

Get a the next link if set or undef.

entry



=head2 entry

=over

This method return an array reference of Feed::* objects.

It works as a factory by instantiating the proper Feed::* class.

ie,if you read a Video feed from a youtube service, it will instantiate the WebService::GData::Youtube::Feed::Video class and feed it the result.


=head1  CONFIGURATION AND ENVIRONMENT

none


=head1  DEPENDENCIES

L<JSON>

L<LWP>

=head1  INCOMPATIBILITIES

none

=head1 BUGS AND LIMITATIONS

If you do me the favor to _use_ this module and find a bug, please email me
i will try to do my best to fix it (patches welcome)!

=head1 AUTHOR

shiriru E<lt>shiriru0111[arobas]hotmail.comE<gt>

=head1 LICENSE AND COPYRIGHT

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut