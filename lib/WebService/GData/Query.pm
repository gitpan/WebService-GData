package WebService::GData::Query;
use WebService::GData;
use base 'WebService::GData';

    #specify default parameters

our $VERSION  = 0.01_01;
	#query parameters set by default
	#v
	our $API_VERSION    = 2;
	#alt
	our $ALT			= 'json';
	#prettyprint
	our $PRETTYPRINT    = 'false';
	#strict
	our $STRICT			= 'true';

	sub __init {
		my $this = shift;

		$this->{_query}={
			'v'         => $API_VERSION,
			alt         => $ALT,
			prettyprint => $PRETTYPRINT,
			strict	    => $STRICT,
		};
		return $this;
	}

WebService::GData::install_in_package(
	['strict','fields','v','alt','prettyprint','author','updated_min','updated_max','published_min','published_max'],
	sub {
		my $subname = shift;
		my $field   = $subname;
		   $field=~s/_/-/g;
		return sub {
			my ($this,$val)=@_;
			return $this->_set_query($field,$val);
		}
	}
);


	sub start_index {
		my ($this,$start)=@_;
		return $this->_set_query('start-index',(int($start)<1)?1:$start);	
	}

	sub max_results {
		my ($this,$max)=@_;
		return $this->_set_query('max-results',(int($max)<1)?1:$max);
	}

	sub limit {
		my ($this,$max,$offset) = @_;
		$this->start_index($offset);
		return $this->max_results($max);
	}

	sub q {
		my ($this,$search) = @_;
		$search=~s/\|/%7/g;
		$search=~s/\s+AND\s+/ /g;
		return $this->_set_query('q',$search);
	}


	sub category {
		my ($this,$category) = @_;
		$category=~s/\|/%7/g;
		$category=~s/\s+OR\s+/%7/g;
		$category=~s/\s+AND\s+/,/g;
		$category=~s/\s{1}/,/g;
		return $this->_set_query('category',$category);
	}

	sub _set_query {
		my ($this,$key,$val)=@_;
		$this->{_query}->{$key}=$val;
		return $this;
	}

	sub get {
		my ($this,$key)=@_;
		return $this->{_query}->{$key};
	}

	sub to_query_string {
		my $this = shift;
		my @query =();
		while(my($field,$value)=each %{$this->{_query}}){
			push @query,$field.'='.$value if(defined $value);
			push @query,$field if(!defined $value);
		}
		return '?'.join '&',@query;
	}

"The earth is blue like an orange.";

__END__


=pod

=head1 NAME

WebService::GData::Query - implements the basic query parameters available in the google data API v2.

=head1 VERSION

0.01

=head1 SYNOPSIS

	use WebService::GData::Query;

    #create an object that only has read access
	my $query = new WebService::GData::Query();

	$query->to_query_string();# by default:?alt=json&v=2&prettyprint=true&strict=true

	#?alt=json-c&v=2&prettyprint=true&strict=true&start-index=1&max-results=10
    $query->alt('json-c')->limit(10,1)->to_query_string();

	print $query->get('alt');#json-c



=head1 DESCRIPTION

inherits from WebService::GData;

Google data API supports searching the different services via a common set of parameters.

This package implements some helpers functions.

The parameters set are not checked for validity, meaning that you could build unproper requests.

Most of the time, you will receive an error from the service.

The package will be expanded to offer data validation. It should therefore avoid unnecessary network transactions and

reduce the risk of reaching quota limitations in use for the service you are querying.


=head1 GENERAL METHODS


=head2 new

=over

Creates a basic query instance.

The following parameters are set by default:

- alt is set to json

- v is set to 2

- prettyprint is set to true

- strict is set to true

Example:

	use WebService::GData::Query;

    #create an object that only has read access
	my $query = new WebService::GData::Query();

	$query->to_query_string();# by default:?alt=json&v=2&prettyprint=true&strict=true


=head2 get

=over

Returns the parameter specified

Example:

	use WebService::GData::Query;

    #create an object that only has read access
	my $query = new WebService::GData::Query();

	$query->get('alt');#json

=head2 to_query_string

=over

Returns the query string representation of the object.

Example:

	use WebService::GData::Query;

    #create an object that only has read access
	my $query = new WebService::GData::Query();

	$query->to_query_string();#?alt=json&v=2&prettyprint=true&strict=true

=head1 PARAMETER METHODS

All the methods that set a parameter return the object itself so that you can chain them.

Example:
    $query->alt('json-c')->limit(10,1)->strict('true')->prettyprint('false')->to_query_string();

The following setters are available:

=head2 strict

=over

If set to true (default),  setting a parameter not supported by a service will fail the request.


=head2 fields

=over

Allows you to query partial data. 

This is a Google data experimental feature as of this version.

Example:

	use WebService::GData::Query;

    #create an object that only has read access
	my $query = new WebService::GData::Query();

	$query->fields('id,entry(author)');#only get the id and the author in the entry tag

=head2 v

=over

Set the google Data API version number. Default to 2. 

WebService::GData related packages require a version number superior or equal to 2.


=head2 alt

=over

Specify the response format used. Default to json.

WebService::GData related packages require the response to be in json if you use the Feed related packages.

Possible values: json,jsonc,atom,rss


=head2 prettyprint

=over

If set to true (default false),the result from the service will contain indentation. 

=head2 author

=over

specify the author of the contents you are retrieving.

Each service derives the meaning for their own feed and it may vary accordingly.

=head2 updated_min

=over

Retrieve the contents which update date is a minimum equal to the one specified (inclusive).

Note that you should retrieve the value as 'updated-min' when used with get().

Format:2005-08-09T10:57:00-08:00

=head2 updated_max 

=over

Retrieve the contents which update date is at maximum equal to the one specified (exclusive).

Note that you should retrieve the value as 'updated-max' when used with get().

Format:2005-08-09T10:57:00-08:00

=head2 published_min 

=over

Retrieve the contents which publish date is a minimum equal to the one specified (inclusive).

Note that you should retrieve the value as 'published-min' when used with get().

Format:2005-08-09T10:57:00-08:00

=head2 published_max 

=over

Retrieve the contents which publish date is a maximum equal to the one specified (exclusive).

Note that you should retrieve the value as 'published-max' when used with get().

Format:2005-08-09T10:57:00-08:00

=head2 start_index 

=over

Retrieve the contents starting from a certain result. Start from 1.

Setting 0 will revert to 1.

Note that you should retrieve the value as 'start-index' when used with get().

=head2 max_results 

=over

Retrieve the contents up to a certain amount of entry (Most of the services set it to 25 by default).

Note that you should retrieve the value as 'max-results' when used with get().

=head2 limit (limit,offset)

=over

An extension that allows you to set start_index and max_results in one method call:

get('limit') will return undef.

Example:

	use WebService::GData::Query;

    #create an object that only has read access
	my $query = new WebService::GData::Query();

	$query->limit(10,5);
	#equivalent to
	$query->max_results(10)->start_index(5);	

=head2 q

=over

insensitive freewords search where:

words in quotation means exact match:"word1 word2"

words separated by a space means AND:word1 word2

words prefixed with an hyphen means NOT(containing):-word1

Example:

	use WebService::GData::Query;

    #create an object that only has read access
	my $query = new WebService::GData::Query();

	$query->q('"exact phrase" snowbaord sports -ski');

=head2 q

=over

insensitive freewords search where:

words in quotation means exact match:"word1 word2"

words separated by a space means AND:word1 word2

words prefixed with an hyphen means NOT(containing):-word1

Example:

	use WebService::GData::Query;

    #create an object that only has read access
	my $query = new WebService::GData::Query();

	$query->q('"exact phrase" snowbaord sports -ski');


=head2 category

=over

look up for specifics categories

words in quotation means exact match:"word1 word2"

words separated by a comma(,) means AND:word1,word2

words separated by a pipe(|) means OR:word1|word2

Example:

	use WebService::GData::Query;

    #create an object that only has read access
	my $query = new WebService::GData::Query();

	$query->q('"exact phrase" snowbaord sports -ski');

=head1  SEE ALSO

Documentation of the parameters:

L<http://code.google.com/intl/en/apis/gdata/docs/2.0/reference.html#Queries>

=head1  CONFIGURATION AND ENVIRONMENT

none


=head1  DEPENDENCIES

none

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