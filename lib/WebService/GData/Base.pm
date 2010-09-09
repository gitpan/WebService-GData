package WebService::GData::Base;
use WebService::GData 'private';
use base 'WebService::GData';

use WebService::GData::Query;
use WebService::GData::Error;
use WebService::GData::Constants qw(:all);

use JSON;
use LWP;

#the base class specifies the basic get/post/insert/update/delete methods

our $VERSION = 0.01_07;

sub __init {
    my ( $this, %params ) = @_;

    $this->{__NAMESPACES__} = [ATOM_NAMESPACE];
    $this->{__OVERRIDE__}   = FALSE;
    $this->{__AUTH__}       = undef;
    $this->query( new WebService::GData::Query() );

    $this->auth( $params{auth} )
      if ( _is_auth_object_compliant( $params{auth} ) );
}

sub auth {
    my ( $this, $auth ) = @_;

    if ( _is_auth_object_compliant($auth) ) {
        $this->{__AUTH__} = $auth;

        #done a request with no authentification.
        #update the ua agent string
        $this->{ua}->agent( _create_ua_base_name() . $auth->source() )
          if ( $this->{ua} );
    }
    return $this->{__AUTH__};
}

sub query {
    my ( $this, $query ) = @_;
    $this->{_basequery} = $query
      if ( _is_query_object_compliant($query) );
    return $this->{_basequery};
}

sub override_method {
    my ( $this, $override ) = @_;

    return $this->{__OVERRIDE__} if ( !$override );

    if ( $override eq TRUE ) {
        $this->{__OVERRIDE__} = TRUE;
    }
    if ( $override eq FALSE ) {
        $this->{__OVERRIDE__} = FALSE;
    }
}

#hacky for now, until I switch to JSONC where this won't be necessary anymore
sub get_namespaces {
    my $this = shift;
    return join( " ", @{ $this->{__NAMESPACES__} } );
}

sub add_namespace {
    my ( $this, $namespace ) = @_;
    push @{ $this->{__NAMESPACES__} }, $namespace;
}

sub clean_namespaces {
    my ($this) = @_;
    $this->{__NAMESPACES__} = [];
}

sub get {
    my ( $this, $uri ) = @_;

    #the url from the feeds contain the version but not the one we pass directly
    $uri = _delete_query_string($uri);

    my $req = HTTP::Request->new( GET => $uri . $this->query->to_query_string );
    $req->content_type('application/x-www-form-urlencoded');

    $this->_prepare_request($req);

    my $ret = $this->_request($req);
    return $this->query->get('alt') =~ m/json/ ? from_json($ret) : $ret;

}

sub post {
    my ( $this, $uri, $content ) = @_;
    my $req = HTTP::Request->new( POST => $uri );
    $req->content_type('application/x-www-form-urlencoded');
    $this->_prepare_request( $req, length($content) );
    $req->content($content);
    return $this->_request($req);
}

sub insert {
    my ( $this, $uri, $content, $callback ) = @_;
    return $this->_save( 'POST', $uri, $content, $callback );
}

sub update {
    my ( $this, $uri, $content, $callback ) = @_;
    return $this->_save( 'PUT', $uri, $content, $callback );
}

sub delete {
    my ( $this, $uri, $length ) = @_;
    my $req;
    if ( $this->override_method eq TRUE ) {
        $req = HTTP::Request->new( POST => $uri );
        $req->header( 'X-HTTP-Method-Override' => 'DELETE' );
    }
    else {
        $req = HTTP::Request->new( DELETE => $uri );
    }
    $req->content_type('application/atom+xml; charset=UTF-8');
    $this->_prepare_request($req);

    return $this->_request($req);
}

###PRIVATE###

#methods#

private _create_ua_base_name => sub {
    return __PACKAGE__ . "/" . $VERSION;
};

private _request => sub {
    my ( $this, $req ) = @_;

    if ( !$this->{ua} ) {
        my $name = _create_ua_base_name();
        if ( $this->auth ) {
            $name = $this->auth->source . $name;
        }
        $this->{ua} = _create_ua($name);
    }

    my $res = $this->{ua}->_request($req);
    if ( $res->is_success ) {
        return $res->content();
    }
    else {
        die new WebService::GData::Error( $res->code, $res->content );
    }
};

private _save => sub {
    my ( $this, $method, $uri, $content, $callback ) = @_;
    my $req;
    if ( $this->override_method eq TRUE && $method eq 'PUT' ) {
        $req = HTTP::Request->new( POST => $uri );
        $req->header( 'X-HTTP-Method-Override' => 'PUT' );
    }
    else {
        $req = HTTP::Request->new( "$method" => $uri );
    }
    $req->content_type('application/atom+xml; charset=UTF-8');

    my $xml_header = XML_HEADER;
    my $xmlns      = $this->get_namespaces();

    my $xml_content = qq[$xml_header<entry $xmlns>$content</entry>];

    $this->_prepare_request( $req, length($xml_content) );
    $req->content($xml_content);
    if ($callback) {
        &$callback($req);
    }

    return $this->_request($req);
};

private _prepare_request => sub {
    my ( $this, $req, $length ) = @_;
    $req->header( 'GData-Version' => $this->query->get('v') );
    $req->header( 'Content-Length' => $length ) if ($length);
    if ( $this->auth ) {
        $this->auth->set_authorization_headers( $this, $req );
        $this->auth->set_service_headers( $this, $req );
    }
};

#sub#

private _create_ua => sub {
    my $name = shift;
    my $ua   = LWP::UserAgent->new;
    $ua->agent($name);
    return $ua;
};

private _is_object => sub {
    my $val = shift;
    eval { $val->can('can'); };
    return undef if ($@);
    return 1;

};

#duck typing has I don't want to enfore inheritance
private _is_auth_object_compliant => sub {
    my $auth = shift;
    return 1
      if ( _is_object($auth)
        && $auth->can('set_authorization_headers')
        && $auth->can('set_service_headers')
        && $auth->can('source') );
    return undef;
};

private _is_query_object_compliant => sub {
    my $query = shift;
    return 1
      if ( _is_object($query)
        && $query->can('to_query_string')
        && $query->can('get')
        && int( $query->get('v') ) >= GDATA_MINIMUM_VERSION );
    return undef;
};

private _delete_query_string => sub {
    my $uri = shift;
    $uri =~ s/\?.//;
    return $uri;
};

"The earth is blue like an orange.";

__END__


=pod

=head1 NAME

WebService::GData::Base - core read/write methods for google data API v2.

=head1 SYNOPSIS

    use WebService::GData::Base;

    #read only
	
    my $base = new WebService::GData::Base();

    my $ret  = $base->get('http://gdata.youtube.com/feeds/api/standardfeeds/top_rated');
    my $feed = $ret->{feed};

    #give write access
	
    $base->auth($auth);

    #now you can
    #get hidden/private contents
	
    my $ret = $base->get('http://gdata.youtube.com/feeds/api/users/default/playlists');

    #new entry with application/x-www-form-urlencoded content-type
	
    my $ret = $base->post('http://gdata.youtube.com/feeds/api/users/default/playlists',$content);

    my $ret = $base->delete('http://gdata.youtube.com/feeds/api/users/playlist/'.$someid);

    #content is decorated with the xml entry basic tags
    #the content type is application/atom+xml; charset=UTF-8
	
    my $ret = $base->insert($uri,$content,$callback);

    #does a PUT. The content is decorated with the xml entry basic tags
    #the content type is application/atom+xml; charset=UTF-8
	
    my $ret = $base->update($uri,$content,$callback);

    #modify the query string query string: ?alt=jsonc&v=2&prettyprint=false&strict=true
	
    $base->query->alt('jsonc')->prettyprint('false');

    #overwrite WebService::GData::Query with youtube query parameters
	
    $base->query(new WebService::GData::YouTube::Query);

    #now the query will have the following query string: 
    #?alt=json&v=2&prettyprint=false&strict=true&safeSearch=none
	
    $base->query->safe_search('none');




=head1 DESCRIPTION

I<inherits from L<WebService::GData>>

This package grants you access to the main read/write methods available for the google data APIs by wrapping LWP methods.
You gain access to: get,post,insert,update,delete.
These methods calls the authentification objects to add extra headers.
This package should be inherited by services (youtube,analytics,calendar) to offer higher level of abstraction.

Every request (get,post,insert,update,delete) will throw a L<WebService::GData::Error> in case of failure.
It is therefore recommanded to enclose your code in eval blocks to catch and handle the error as you see fit.

The google data based APIs offer different format for the core protocol: atom based, rss based,json based, jsonc based.
In order to offer good parsing performance, we use the json based response as a default to L<WebService::GData::Base>::get() the feeds.
Unfortunately, if we can set to read the feeds in json,the write methods require atom based data.
The server also sends back an atom response too. We have therefore a hugly mixed of atom/json logic for now.

but...

The JSONC format which is now being incorporated in google data based services will offer 
the same level of interaction as the atom based protocol.


=head2 CONSTRUCTOR

=head3 new

=over

Create an instance.

B<Parameters>

=over 

=item C<auth:__AUTH__Object> (optional) - You can set an authorization object like L<WebService::GData::ClientLogin>

=back

B<Returns> 

=over 

=item L<WebService::GData::Base>

=back


Example:

    use WebService::GData::Base;
	
    my $base   = new WebService::GData::Base(auth=>$auth);
	
=back

=head2 SETTER/GETTER METHODS

=head3 auth

=over

Set/get an auth object that handles acess to protected contents.
The auth object will be used by post/insert/update/delete methods by calling two methods: 

=over

=item * C<set_authorization_headers(base:WebService::GData::Base,req:HTTP::Request)> 

- Headers required by the authentication protocol.

=item * C<set_service_headers(base:WebService::GData::Base,req:HTTP::Request)> 

- Extra headers required by a particular service.

=item * C<source()> 

- The name of the application. Will be used for the user agent string.

=back

These methods will receive the instance calling them and the request instance.
They shall add any extra headers required to implement their own authentication protocol (ie,ClientLogin,OAuth,SubAuth).
If the object can not handle the above methods it will not be set.

B<Parameters>

=over

=item C<none> - use as a getter

=item C<auth:Object> - use as a setter: a auth object defining the necessary methods.

=back

B<Returns> 

=over 

=item C<auth:Object> in a setter/getter context.

=back

Example:

    use WebService::GData::Base;
	
    #should be in a eval {... }; block to catch an error...
	
    my $auth = new WebService::GData::ClientLogin(email=>...);

    my $base = new WebService::GData::Base(auth=>$auth);
	
    #or
	
    my $base   = new WebService::GData::Base();	
       $base  -> auth($auth);
	   
=back

=head3 query

=over

Set/get a query object that handles the creation of the query string. 
The query object will be used to add extra query parameters when calling L<WebService::GData::Base>::get().

The query object should only implement the following methods (do not need to inherit from L<WebService::GData::Query>):

=over 

=item * C<get('value-name')> - Gives access to a parameter value

=item * C<to_query_string()> - return the query string.

=item * C<get('v')> - should return a version number >=L<WebService::GData::Constants>::GDATA_MINIMUM_VERSION

=back

B<Parameters>

=over

=item C<none> - use as a getter

=item C<query:Object> - use as a setter: a query object defining the necessary methods.

=back

B<Returns> 

=over 

=item C<query:Object> in a setter/getter context.

=back

The L<WebService::GData::Query> returns by default:

    '?alt=json&prettyprint=false&strict=true&v=2'
	
when C<to_query_string()> is called.

When you call L<WebService::GData::Base>::get(), you should only set an url with no query string:

Example:
   
    use WebService::GData::Constants qw(:all);
    use WebService::GData::Base;
	
    #should be in a eval { ... }; block...
    my $auth   = new WebService::GData::ClientLogin(email=>...);

    my $base   = new WebService::GData::Base(auth=>$auth);

    $base->query->alt(JSONC);
    
    $base->get('http://gdata.youtube.com/feeds/api/standardfeeds/top_rated');
    #is in fact calling:
    #http://gdata.youtube.com/feeds/api/standardfeeds/top_rated?alt=jsonc&prettyprint=false&strict=true&v=2

    #or set a new query object:
    $base->query(new WebService::GData::YouTube::Query());

=back

=head3 override_method

=over

Set/get the override method. 

Depending on your server configurations, you might not be able to set the method to PUT/DELETE/PATCH. This will forbid you to do any updates or deletes.
In such a case, you should set override_method to TRUE so that it uses the POST method but override it by the proper value (ie,PUT/DELETE/PATCH) using X-HTTP-Method-Override.


B<Parameters>

=over

=item C<none> - use as a getter

=item C<true_or_false:Scalar> - use as a setter: L<WebService::GData::Constants>::TRUE or L<WebService::GData::Constants>::FALSE (default)

=back

B<Returns> 

=over 

=item C<void> in a setter context. 

=item C<override_state:Scalar> in a getter context, either L<WebService::GData::Constants>::TRUE or L<WebService::GData::Constants>::FALSE.

=back

Example:

    use WebService::GData::Constants qw(:all);
    use WebService::GData::Base;
	
	
	#using override_method makes sense only if you are logged in
	#and want to do some write methods.

    my $auth = new WebService::GData::ClientLogin(email=>...);

    my $base = new WebService::GData::Base(auth=>$auth);

	$base->override_method(TRUE);
	
	$base->update($url,$content);
	   
=back

=head3 add_namespace

=over

When inserting/updating contents, you will use an atom entry tag.
This entry tag may contain tags that are not in the atom original namespace schema.
You will need therefore to specify the extra namespaces used so that it gets parsed properly.
Note that the atom namespace is already set by default and that L<WebService::GData::Constants> already contains some predefined namespaces
that you might want to use, less typing and if an update is necessary, it will be in this package, not in your source code.

B<Parameters>

=over

=item C<namespace:Scalar> - the xml representation of a namespace,ie xmlns:media='http://search.yahoo.com/mrss/'

=back

B<Returns> 

=over

=item C<void>

=back

Example:

    use WebService::GData::Base qw(:namespace);
    use WebService::GData::Base;

	
    #you must be authorized to do any write actions.
    my $base   = new WebService::GData::Base(auth=>...);
    
    $base->add_namespace(MEDIA_NAMESPACE);
    $base->add_namespace(GDATA_NAMESPACE);
	
    #the content will be decorated with the above namespaces...
    my $ret = $base->insert($url,$content);
	
=back

=head3 get_namespace 

=over

This method returns as a string separated by a space the namespaces set so far.

B<Parameters>

=over

=item C<none>

=back

B<Returns> 

=over 

=item C<namespaces:Scalar>  - all the namespaces set separated by a space. (Default to L<WebService::GData::Constants>::ATOM_NAMESPACE)

=back

Example:

    use WebService::GData::Constants qw(:namespace);
    use WebService::GData::Base;
		
    my $base   = new WebService::GData::Base();
    
    $base->add_namespace(MEDIA_NAMESPACE);
    $base->add_namespace(GDATA_NAMESPACE);
	
    #the content will be decorated with the above namespaces...
	
    my $namespaces = $base->get_namespace();

    #$namespaces = xmlns="http://www.w3.org/2005/Atom" xmlns:media='http://search.yahoo.com/mrss/'+
    # xmlns:gd="http://schemas.google.com/g/2005"
	
=back

=head3 clean_namespaces 

=over

This method resets all the namespaces set so far, including the default L<WebService::GData::Constants>::ATOM_NAMESPACE.

B<Parameters>

=over

=item C<none>

=back

B<Returns> 

=over 

=item C<void>

=back

Example:

    use WebService::GData::Constants qw(:namespace);
    use WebService::GData::Base;
		
    my $base   = new WebService::GData::Base();
    
    $base->add_namespace(MEDIA_NAMESPACE);
    $base->add_namespace(GDATA_NAMESPACE);
	
    #the content will be decorated with the above namespaces...
	
    my $namespaces = $base->get_namespace();

    #$namespaces = xmlns="http://www.w3.org/2005/Atom" xmlns:media='http://search.yahoo.com/mrss/'+
    # xmlns:gd="http://schemas.google.com/g/2005"
	
    $base->clean_namespaces();
    my $namespaces = $base->get_namespace();#""
	
=back


	
=head2 READ METHODS

=head3 get

=over

Get the content of a feed in any format. If the format is json or jsonc, it will send back a perl object.
If an auth object is specified, it will call the required methods to set the authentication headers.
It will also set the 'GData-Version' header by calling $this->query->get('v');
You should put the code in a eval { ... }; block to catch any error.

B<Parameters>

=over 

=item C<url:Scalar> - an url to fetch that do not contain any query string.

Query string will be removed before sending the request.

=back

B<Returns> 

=over 

=item C<response:Object|Scalar> - a perl object if it is a json or jsonc request else the raw content.

=back

B<Throws> 

=over 

=item L<WebService::GData::Error> if it fails to reach the contents.

=back

Example:

    use WebService::GData::Base;
	
    my $base   = new WebService::GData::Base();
    
    $base->get('http://gdata.youtube.com/feeds/api/standardfeeds/top_rated');
	
    #is in fact calling:
    #http://gdata.youtube.com/feeds/api/standardfeeds/top_rated?alt=json&prettyprint=false&strict=true&v=2

    #the query string will be erased...
	
    $base->get('http://gdata.youtube.com/feeds/api/standardfeeds/top_rated?alt=atom');
	
    #is in fact calling:
    #http://gdata.youtube.com/feeds/api/standardfeeds/top_rated?alt=json&prettyprint=false&strict=true&v=2

=back

=head2 WRITE METHODS

All the following methods will set the 'GData-Version' header by calling $this->query->get('v');
You should put the code in a eval { ... }; block to catch any error these methods may throw.

=head3 post

=over

Post data to an url with application/x-www-form-urlencoded content type.
An auth object must be specified. it will call the required methods to set the authentication headers.

B<Parameters>

=over

=item C<url:Scalar> - the url to query

=item C<content:Scalar|Binary> - the content to post

=back

B<Returns> 

=over 

=item C<response:Scalar> - the response to the query in case of success.

=back

B<Throws> 

=over 

=item L<WebService::GData::Error> if it fails to reach the contents.

=back


Example:

    use WebService::GData::Base;
	
    #you must be authorized to do any write actions.
    my $base   = new WebService::GData::Base(auth=>...);
    
    #create a new entry with application/x-www-form-urlencoded content-type
    my $ret = $base->post($url,$content);
	
=back

=head3 insert

=over

Insert data to an url with application/atom+xml; charset=UTF-8 content type (POST).
An auth object must be specified. it will call the required methods to set the authentication headers.


B<Parameters>

=over

=item C<url:Scalar> - the url to query

=item C<content:Scalar> - the content to post in xml format will be decorated with:

    <?xml version="1.0" encoding="UTF-8"?><entry $xmlns>$content</entry>

where $xmlns is the result of C<get_namespace>.

=back

B<Returns> 

=over

=item C<response:Scalar> - the response to the query in case of success.

=back

B<Throws> 

=over 

=item L<WebService::GData::Error> if it fails to reach the contents.

=back

Example:

    use WebService::GData::Base;
	
    #you must be authorized to do any write actions.
    my $base   = new WebService::GData::Base(auth=>...);
    
    #create a new entry with application/atom+xml; charset=UTF-8 content-type
    my $ret = $base->insert($url,$content);

=back

=head3 update

=over

Update data to an url with application/atom+xml; charset=UTF-8 content type (PUT).
An auth object must be specified. it will call the required methods to set the authentication headers.

B<Parameters>

=over

=item C<url:Scalar> - the url to query

=item C<content:Scalar> - the content to put in xml format will be decorated with:

    <?xml version="1.0" encoding="UTF-8"?><entry $xmlns>$content</entry>

where $xmlns is the result of C<get_namespace>.

=back

B<Returns> 

=over 

=item C<response:Scalar> - the response to the query in case of success.

=back

B<Throws> 

=over

=item L<WebService::GData::Error> if it fails to reach the contents.

=back

Example:

    use WebService::GData::Base;
	
    #you must be authorized to do any write actions.
    my $base   = new WebService::GData::Base(auth=>...);
    
    #create a new entry with application/atom+xml; charset=UTF-8 content-type
    my $ret = $base->upate($url,$content);
	
=back

=head3 delete

=over

Delete data from an url with application/atom+xml; charset=UTF-8 content type (DELETE).

B<Parameters>

=over

=item C<url:Scalar> - the url to query

=back

B<Returns> 

=over

=item C<response:Scalar> - the response to the query in case of success.

=back

B<Throws> 

=over

=item L<WebService::GData::Error> if it fails to reach the contents.

=back


Example:

    use WebService::GData::Base;
	
    #you must be authorized to do any write actions.
    my $base   = new WebService::GData::Base(auth=>...);
    
    #create a new entry with application/atom+xml; charset=UTF-8 content-type
    my $ret = $base->delete($url);
	
=back


=head2  HANDLING ERRORS

Google data APIs relies on querying remote urls on particular services.

Some of these services limits the number of request with quotas and may return an error code in such a case.

All queries that fail will throw (die) a L<WebService::GData::Error> object. 

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


=head1  DEPENDENCIES

L<JSON>

L<LWP>

=head1 BUGS AND LIMITATIONS

If you do me the favor to _use_ this module and find a bug, please email me
i will try to do my best to fix it (patches welcome)!

=head1 AUTHOR

shiriru E<lt>shirirulestheworld[arobas]gmail.comE<gt>

=head1 LICENSE AND COPYRIGHT

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
