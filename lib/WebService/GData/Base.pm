package WebService::GData::Base;
use WebService::GData;
use base 'WebService::GData';

use WebService::GData::Query;
use WebService::GData::Error;
use WebService::GData::Constants;

use JSON;
use LWP;

#the base class specifies the basic get/post/insert/update/delete methods


our $VERSION  = 0.01_01;

	sub __init {
		my ($this,%params) = @_;

		$this->{__NAMESPACES__}= [];

		$this->query(new WebService::GData::Query());

		$this->{Auth}   = $params{auth} if(_is_auth_object_compliant($params{auth}));	
	}

	sub auth {
		my ($this,$auth)=@_;

		if(_is_auth_object_compliant($auth)) {
			$this->{Auth} = $auth;
			#done a request with no authentification.
			#update the ua agent string
			$this->{ua}->agent(_create_ua_base_name().$auth->source()) if($this->{ua});
		}
		return $this->{Auth};
	}

	sub query {
		my ($this,$query)=@_;
		$this->{_basequery} = $query if(_is_query_object_compliant($query));
		return $this->{_basequery};
	}

	#hacky for now, until I switch to JSON-C where this won't be necessary anymore
	sub get_namespaces {
		my $this = shift;
		return join (" ", @{$this->{__NAMESPACES__}});
	}

	sub add_namespace {
		my ($this,$namespace)= @_;
		push @{$this->{__NAMESPACES__}},$namespace;
	}

	sub clean_namespace {
		my ($this)= @_;
		$this->{__NAMESPACES__}=[];
	}

	sub get {
		my ($this,$uri) = @_;

		#the url from the feeds contain the version but not the one we pass directly
		$uri= _delete_query_string($uri);

    	my $req = HTTP::Request->new(GET => $uri.$this->query->to_query_string);
  	       $req-> content_type('application/x-www-form-urlencoded');

		$this->_prepare_request($req);
		
		my $ret = $this->_request($req);
		return $this->query->get('alt')=~m/json/ ? from_json($ret) : $ret;

	}

	sub post {
		my ($this,$uri,$content)    = @_;
    	my $req = HTTP::Request->new(POST => $uri);
  	       $req-> content_type('application/x-www-form-urlencoded');
			$this->_prepare_request($req,length($content));
           $req-> content($content);
		return $this->_request($req);
	}

	sub insert {
		my ($this,$uri,$content,$callback) = @_;
		return $this->_save('POST',$uri,$content,$callback);	
	}

	sub update {
		my ($this,$uri,$content,$callback) = @_;
		return $this->_save('PUT',$uri,$content,$callback);
	}

	sub delete {
		my ($this,$uri,$length) = @_;

		my	$req = HTTP::Request->new(DELETE => $uri);
  		$req-> content_type('application/atom+xml; charset=UTF-8');
		$this->_prepare_request($req);

		return $this->_request($req);
	}


###PRIVATE###

#sub
#

	sub _create_ua {
		my $name = shift;
		my $ua = LWP::UserAgent->new;
		   $ua->agent($name);
		return $ua;
	}

	#duck typing has I don't want to enfore inheritance
	sub _is_auth_object_compliant {
		my $auth=shift;
		return 1 if($auth && $auth->can('set_authorization_headers') && $auth->can('set_service_headers') && $auth->can('source'));
		return undef;
	}

	sub _is_query_object_compliant {
		my $query=shift;
		return 1 if($query && $query->can('to_query_string') && $query->can('get') && int($query->get('v'))>=WebService::GData::Constants::GDATA_MINIMUM_VERSION);
		return undef;
	}

	sub _delete_query_string {
		my $uri = shift;
		$uri=~s/\?.//;	
		return $uri;
	}

#methods

	sub _create_ua_base_name {
		return __PACKAGE__."/".$VERSION;
	}

	sub _request {
		my($this,$req)=@_;

		if(!$this->{ua}) {
			my $name = _create_ua_base_name;
			if($this->auth){
				$name = $this->auth->source.$name;
			}
        	$this->{ua} = _create_ua($name);
		}

        my $res = $this->{ua}->request($req);		
    	if ($res->is_success) {
			return $res->content();
		}
		else {
			die new WebService::GData::Error($res->code,$res->content);
		}
	}

	sub _save {
		my ($this,$method,$uri,$content,$callback) = @_;

		my $req = HTTP::Request->new("$method"=> $uri);
  		$req-> content_type('application/atom+xml; charset=UTF-8');

		my $atom       = WebService::GData::Constants::ATOM_NAMESPACE;
		my $xml_header = WebService::GData::Constants::XML_HEADER;
		my $xmlns      = $this->get_namespaces();

		my $xmlcontent = qq[$xml_header<entry $atom $xmlns>$content</entry>];


		$this -> _prepare_request($req,length($xmlcontent));
    	$req  -> content($xmlcontent);
		if($callback){
			&$callback($req);
		}

		return $this->_request($req);
	}

	sub _prepare_request {
		my ($this,$req,$length)=@_;
  		$req->header('GData-Version' => $this->query->get('v'));
  		$req->header('Content-Length'=> $length) if($length);
		if($this->auth){
  		   	$this->auth->set_authorization_headers($this,$req);
  		   	$this->auth->set_service_headers($this,$req);
		}		
	}

"The earth is blue like an orange.";

__END__


=pod

=head1 NAME

WebService::GData::Base - core read/write methods for google data API v2.

=head1 VERSION

0.01

=head1 SYNOPSIS

	use WebService::GData::Base;

    #create an object that only has read access
   	my $base = new WebService::GData::Base();

	#get a feed response from google
	#by default the alt is set to 'json',it will change the JSON response to a perl object.
	my $ret  = $base->get('http://gdata.youtube.com/feeds/api/standardfeeds/top_rated');
	my $feed = $ret->{feed};

	#give write access with a $auth object that you created somewhere
	$base->auth($auth);

	#now you can (url are here for examples!)

	#get contents even hidden for public access
	my $ret = $base->get('http://gdata.youtube.com/feeds/api/users/default/playlists');

	#create a new entry with application/x-www-form-urlencoded content-type
	my $ret = $base->post('http://gdata.youtube.com/feeds/api/users/default/playlists',$content);

	#delete
	my $ret = $base->delete('http://gdata.youtube.com/feeds/api/users/playlist/'.$someid);

	#the same as post but the content is decorated with the xml entry basic tags
	#the content type is application/atom+xml; charset=UTF-8
	my $ret = $base->insert($uri,$content,$callback);

	#does a put to the server. The content is decorated with the xml entry basic tags
	#the content type is application/atom+xml; charset=UTF-8
	my $ret = $base->update($uri,$content,$callback);

	#now the query will have the following query string: ?alt=json-c&v=2&prettyprint=false&strict=true
	$base->query->alt('json-c')->prettyprint('false');

    #overwrite WebService::GData::Query with youtube query parameters
	$base->query(new WebService::GData::YouTube::Query);

	#now the query will have the following query string: ?alt=json&v=2&prettyprint=true&strict=true&safeSearch=none
	$base->query->safeSearch('none');




=head1 DESCRIPTION

inherits from WebService::GData;

This package grants you access to the main read/write methods available for the google data APIs by wrapping LWP methods.

You gain access to:

get,post,insert,update,delete.

These methods set extra headers necessary to authenticate or extra headers required by the service you want to use.

This package should be inherited by services (youtube,analytics) to offer higher level of abstraction.

Every request (get,post,insert,update,delete) will throw (well, die) a WebService::GData::Error in case of failure.

It is therefore recommanded to enclose your code in eval blocks to catch and handle the error as you see fit.

The google data based APIs offer different format for the core protocol: atom based, rss based,json based, jsonc based.

In order to offer good parsing performance, we use the json based response as a default to get() the feeds.

Unfortunately, if we can set to read the feeds in json,the write methods require atom based data.

The server also sends back an atom response too.

We have therefore a hugly mixed of atom/json logic for now.

but...

The JSON-C format which is now being incorporated in google data based services will offer the same level of interaction as the atom based protocol.

Meaning that getting,inserting shall all be in JSON-C.

To avoid a dependency to an XML package (shall be deprecated soon) and keep the process reasonably fast

the packages handle all writing/updating methods and response from the servers with raw XML data.

This will change once JSON-C implementation is available in the most asked services.


=head1 METHODS


=head2 new

=over

Accept a hash that specify the auth object handling acess to protected contents.


Example:

    use WebService::GData::Base;
	
    my $base   = new WebService::GData::Base(auth=>$auth);

=head2 auth

=over

set/get an auth object that handles acess to protected contents.

The auth object will be used by post/insert/update/delete methods by calling two methods: 

- set_authorization_headers

headers required by the authentication protocol

- set_service_headers

extra headers required by a particular service.

ie: WebService::GData::ClientLogin only implements the set_authorization_headers (set_service_headers being a stub doing nothing).

But the WebService::GData::YouTube::ClientLogin extends and implement the set_service_headers to add the developer key header.

These methods will receive the object calling them and the request object.

They shall add any extra headers required to implement their own authentication protocol (ie,ClientLogin,OAuth,SubAuth).

If the object can not handle these methods it will not be set.

Example:

    use WebService::GData::Base;
	
	#should be in a eval {... }; block to catch an error...
	my $auth = new WebService::GData::ClientLogin(email=>...);

    my $base = new WebService::GData::Base(auth=>$auth);
	#or
    my $base   = new WebService::GData::Base();	
	   $base->auth($auth);

=head2 query

=over

set/get a query object that handles the creation of the query string. Default : WebService::GData::Query.

The query object will be used to add extra query parameters when calling WebService::GData::Base::get.

The query object should only implement the following methods (do not need to inherit from WebService::GData::Query):

- get

gives access to a particular parameter

- to_query_string

creates the query string.

- get('v')>=2

Query objects should all have a parameter specifying a version number parameter 'v' set to at least 2.

The WebService::GData::Query returns by default '?alt=json&prettyprint=false&strict=true&v=2' when to_query_string is called.

when you call WebService::GData::Base::get(), you should only set an url with no query string:

Example:

    use WebService::GData::Base;
	
	#should be in a eval { ... }; block...
	my $auth   = new WebService::GData::ClientLogin(email=>...);

    my $base   = new WebService::GData::Base(auth=>$auth);

	$base->query->alt('json-c');
    
    $base->get('http://gdata.youtube.com/feeds/api/standardfeeds/top_rated');
	#is in fact calling:
	#http://gdata.youtube.com/feeds/api/standardfeeds/top_rated?alt=json-c&prettyprint=false&strict=true&v=2

	#or set a new query object:
	$base->query(new WebService::GData::YouTube::Query());

=head2 get (url:Scalar)

=over

Get the contents of a feed in a any format. If the format is json or jsonc, it will send back a perl object.

Accept an url with no query string. Query string will be removed before sending the request.

If an auth object is specified, it will call the required methods to set the authentication headers.

It will also set the 'GData-Version' header by calling $this->query->get('v');

When you call WebService::GData::Base::get(), you should only set an url with no query string.

Throws (die) a WebService::GData::Error if it fails to reach the contents.

You should put the code in a eval { ... }; block to catch any error.

Example:

    use WebService::GData::Base;
	
    my $base   = new WebService::GData::Base();
    
    $base->get('http://gdata.youtube.com/feeds/api/standardfeeds/top_rated');
	#is in fact calling:
	#http://gdata.youtube.com/feeds/api/standardfeeds/top_rated?alt=json-c&prettyprint=true&strict=true&v=2

	#the query string will be erased...
    $base->get('http://gdata.youtube.com/feeds/api/standardfeeds/top_rated?v=2');
	#is in fact calling:
	#http://gdata.youtube.com/feeds/api/standardfeeds/top_rated?alt=json-c&prettyprint=true&strict=true&v=2

	

=head2 post (url:Scalar,content:Scalar)

=over

Post data to an url with application/x-www-form-urlencoded content type.

Accept an url and the content to post.

If an auth object is specified, it will call the required methods to set the authentication headers.

It will also set the 'GData-Version' header by calling $this->query->get('v');

Throws (die) a WebService::GData::Error if it fails to reach the contents.

You should put the code in a eval { ... }; block to catch any error.

Example:

    use WebService::GData::Base;
	
	#you must be authorized to do any write actions.
    my $base   = new WebService::GData::Base(auth=>...);
    
	#create a new entry with application/x-www-form-urlencoded content-type
	my $ret = $base->post($url,$content);

=head2 insert (url:Scalar,content:Scalar)

=over

Insert data to an url with application/atom+xml; charset=UTF-8 content type (POST).

Accept an url and the content that will be decorated with the raw xml tags:


<?xml version="1.0" encoding="UTF-8"?><entry xmlns="http://www.w3.org/2005/Atom" $xmlns>$content</entry>

The $xmlns part is specified by using the add_namespace method.

All the write methods require the contents formated as an atom feed.

We therefore must specify the namespaces that the content is using.

This shall be deprecated when everything switch to JSON-C format.

If an auth object is specified, it will call the required methods to set the authentication headers.

It will also set the 'GData-Version' header by calling $this->query->get('v');

Throws (die) a WebService::GData::Error if it fails to reach the contents.

You should put the code in a eval { ... }; block to catch any error.

Example:

    use WebService::GData::Base;
	
	#you must be authorized to do any write actions.
    my $base   = new WebService::GData::Base(auth=>...);
    
	#create a new entry with application/atom+xml; charset=UTF-8 content-type
	my $ret = $base->insert($url,$content);

=head2 update (url:Scalar,content:Scalar)

=over

Update data to an url with application/atom+xml; charset=UTF-8 content type (PUT).

Accept an url and the content, that will be decorated with the raw xml tags:


<?xml version="1.0" encoding="UTF-8"?><entry xmlns="http://www.w3.org/2005/Atom" $xmlns>$content</entry>

The $xmlns part is specified by using the add_namespace method.

We therefore must specify the namespaces that the content is using.

This shall be deprecated when everything switch to JSON-C format.

If an auth object is specified, it will call the required methods to set the authentication headers.

It will also set the 'GData-Version' header by calling $this->query->get('v');

Throws (die) a WebService::GData::Error if it fails to reach the contents.

You should put the code in a eval { ... }; block to catch any error.

Example:

    use WebService::GData::Base;
	
	#you must be authorized to do any write actions.
    my $base   = new WebService::GData::Base(auth=>...);
    
	#create a new entry with application/atom+xml; charset=UTF-8 content-type
	my $ret = $base->upate($url,$content);

=head2 delete (url:Scalar)

=over

Delete data from an url with application/atom+xml; charset=UTF-8 content type (DELETE).

If an auth object is specified, it will call the required methods to set the authentication headers.

It will also set the 'GData-Version' header by calling $this->query->get('v');

Throws (die) a WebService::GData::Error if it fails to reach the contents.

You should put the code in a eval { ... }; block to catch any error.

Example:

    use WebService::GData::Base;
	
	#you must be authorized to do any write actions.
    my $base   = new WebService::GData::Base(auth=>...);
    
	#create a new entry with application/atom+xml; charset=UTF-8 content-type
	my $ret = $base->delete($url);


=head2 add_namespace (namespace:Scalar)

=over

When inserting/updating contents, you will use an atom entry tag.

This entry tag may contain tags that are not in the atom original namespace schema.

You will need therefore to specify the extra namespaces used so that it gets parsed properly.

Will be deprecated as soon as we can switch to JSON-C.

Example:

    use WebService::GData::Base;
	
	#you must be authorized to do any write actions.
    my $base   = new WebService::GData::Base(auth=>...);
    
	    $base->add_namespace("xmlns:media='http://search.yahoo.com/mrss/'");
		$base->add_namespace("xmlns:yt='http://gdata.youtube.com/schemas/2007'");
	#the content will be decorated with the above namespaces...
	my $ret = $base->insert($url,$content);

=head2 get_namespace 

=over

This method returns the namespaces set so far as a string.

Will be deprecated as soon as we can switch to JSON-C.

Example:

    use WebService::GData::Base;
	
	#you must be authorized to do any write actions.
    my $base   = new WebService::GData::Base(auth=>...);
    
	    $base->add_namespace("xmlns:media='http://search.yahoo.com/mrss/'");
		$base->add_namespace("xmlns:yt='http://gdata.youtube.com/schemas/2007'");
	#the content will be decorated with the above namespaces...
	my $namespaces = $base->get_namespace();
	#xmlns:media='http://search.yahoo.com/mrss/' xmlns:yt='http://gdata.youtube.com/schemas/2007'

=head2 clean_namespace 

=over

This method resets the namespaces set so far.

Will be deprecated as soon as we can switch to JSON-C.

Example:

    use WebService::GData::Base;
	
	#you must be authorized to do any write actions.
    my $base   = new WebService::GData::Base(auth=>...);
    
	    $base->add_namespace("xmlns:media='http://search.yahoo.com/mrss/'");
		$base->add_namespace("xmlns:yt='http://gdata.youtube.com/schemas/2007'");
	#the content will be decorated with the above namespaces...
	my $namespaces = $base->get_namespace();
	#xmlns:media='http://search.yahoo.com/mrss/' xmlns:yt='http://gdata.youtube.com/schemas/2007'
	$base->clean_namespace();
	my $namespaces = $base->get_namespace();#nothing


=head1  HANDLING ERRORS

Google data APIs relies on querying remote urls on particular services.

Some of these services limits the number of request with quotas and may return an error code in such a case.

All queries that fail will throw (die) a WebService::GData::Error object. 

You should enclose all code that requires connecting to a service within eval blocks in order to handle it.


Example:

    use WebService::GData::Base;
	
    my $base   = new WebService::GData::Base();
    
	#the server is dead or the url is not available anymore or you've reach your quota of the day.
	#boom the application dies and your program fails...
    $base->get('http://gdata.youtube.com/feeds/api/standardfeeds/top_rated');

	#with error handling...

	#enclose your code in a eval block...
	eval {
   		$base->get('http://gdata.youtube.com/feeds/api/standardfeeds/top_rated');
	}; 

	#if something went wrong, you will get a WebService::GData::Error object back:
	if(my $error = $@){

		#do whatever you think is necessary to recover (or not)
		#print/log: $error->content,$error->code
	}	


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