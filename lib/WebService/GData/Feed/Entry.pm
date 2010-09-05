package WebService::GData::Feed::Entry;
use WebService::GData;
use base 'WebService::GData::Feed';
our $VERSION  = 0.01_02;
##inherits and not relevant properties
##entry,totalResults,startIndex,itemsPerPage

##inherits and relevant
##title,updated,category,link,author,new,etag

	sub id {
		my $this = shift;
		$this->{_feed}->{id}->{'$t'};
	}

	sub summary {
		my $this = shift;
		$this->{_feed}->{summary}->{'$t'}=$_[0] if(@_==1);
		$this->{_feed}->{summary}->{'$t'};
	}

	sub content_type {
		my $this = shift;
		$this->{_feed}->{content}->{'type'};
	}

	sub content_source {
		my $this = shift;
		$this->{_feed}->{content}->{'src'};
	}

	sub published {
		my $this = shift;
		$this->{_feed}->{published}->{'$t'};
	}

"The earth is blue like an orange.";

__END__


=pod

=head1 NAME

WebService::GData::Feed::Entry - Abstract class wrapping json atom feed entry tag for google data API v2.

=head1 SYNOPSIS

    use WebService::GData::Feed::Entry;

    my $feed = new WebService::GData::Feed::Entry($jsonfeed->{entry});

    $feed->title;
    $feed->author;
    $feed->summary;
    $feed->published;


=head1 DESCRIPTION

I<inherits from L<WebService::GData::Feed>>

This package wraps the entry tag from a query to a feed using the json format of the Google Data API v2 (no other format is supported!).
It gives you access to some of the entry tag data via wrapper methods.
Unless you implement a service, you should never instantiate this class directly.


=head1 CONSTRUCTOR

=head2 new

=over

Accept the contenst of the entry tag from a feed that has been perlified (from_json($json_string)) and an auth object.

The auth object is not use in this class.

=head1 INHERITED METHODS

As it inherits from  WebService::GData::Feed, you get access to the same methods that also exists within the entry tag namespace.

This inherited method will send you back the entry data, not the feed data.

=head2 title

=head2 updated

=head2 category

=head2 link

=head2 author

=head2 etag

=head1 CUSTOM METHODS


=head2 id

=over

get the id of the entry.

=head2 summary

=over

get/set the summary of the entry (description).


=head2 content_type

=over

Get the content type of the entry.

=head2 content_source

=over

Get the content source of the entry.

=head2 published

=over

Get the publication date of the entry.


=head1 BUGS AND LIMITATIONS

If you do me the favor to _use_ this module and find a bug, please email me
i will try to do my best to fix it (patches welcome)!

=head1 AUTHOR

shiriru E<lt>shirirulestheworld[arobas]gmail.comE<gt>

=head1 LICENSE AND COPYRIGHT

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut