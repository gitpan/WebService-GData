package WebService::GData::ClientLogin;
use WebService::GData;
use base 'WebService::GData';
use WebService::GData::Error;
use WebService::GData::Constants;
use LWP;

#do a client login

our $VERSION  = 0.01_01;
our $CLIENT_LOGIN_URI = WebService::GData::Constants::CLIENT_LOGIN_URL;
our $CAPTCHA_URL	  = WebService::GData::Constants::CAPTCHA_URL;

WebService::GData::install_in_package(
	[qw(type password service source captcha_token captcha_answer email key)],
	sub {
		my $subname = shift;
		return sub {
			my $this = shift;
			$this->{$subname};
		}
	}
);

	sub __init {
		my ($this,%params) = @_;

		$this->{email}          = $params{email};
		$this->{password}       = $params{password};
		$this->{service}        = $params{service}  || WebService::GData::Constants::YOUTUBE_SERVICE;
		$this->{type}           = $params{type}     || 'HOSTED_OR_GOOGLE';
		$this->{source}         = (defined $params{source}) ? $params{source}.__PACKAGE__.'-'.$VERSION : __PACKAGE__.'-'.$VERSION;
		$this->{captcha_token}  = $params{captcha_token};
		$this->{captcha_answer} = $params{captcha_answer};

		#youtube related?
		$this->{key}       = $params{key};

		$this->{ua} = $this->_create_ua();

		return $this->_clientLogin();
	}

 	sub captcha_url {
		my $this = shift;
		if($this->{captcha_url}){
			return $CAPTCHA_URL.$this->{captcha_url};
		}
		return undef;
	}

	sub authorization_key {
		my $this = shift;
		return $this->{Auth};
	}

	#for developer only
	sub set_authorization_headers {
		my ($this,$subject,$req) = @_;
		$req->header('Authorization'=>'GoogleLogin auth='.$this->authorization_key);
	}

	#youtube
	sub set_service_headers {
		my ($this,$subject,$req) = @_;
		$req->header('X-GData-Key'=>'key='.$this->key);
	}

	#private

	sub _create_ua {
		my $this = shift;
		my $ua = LWP::UserAgent->new;
		$ua->agent($this->source);
		return $ua;
	}

	sub _post {
		my ($this,$uri,$content)    = @_;
		my $req = HTTP::Request->new(POST => $uri);
			$req-> content_type('application/x-www-form-urlencoded');
		$req-> content($content);
		my $res = $this->{ua}->request($req);
		if ($res->is_success || ($res->code==403 && $res->content()=~m/CaptchaRequired/)) {
			return $res->content();
		}
		else {
			die new WebService::GData::Error($res->code,$res->content);
		}	
	}

	sub _clientLogin {
		my $this = shift;

		my $content = 'Email='._urlencode($this->email);
		   $content.= '&Passwd='._urlencode($this->password);
		   $content.= '&service='.$this->service;
		   $content.= '&source='._urlencode($this->source);
		   $content.= '&accountType='.$this->type;

		   #when failed the first time, add the captcha
		   $content.='&logintoken='.$this->captcha_token    if($this->captcha_token);
		   $content.='&logincaptcha='.$this->captcha_answer if($this->captcha_answer);

	 	my $ret = $this->_post($CLIENT_LOGIN_URI,$content);

		$this->{Auth}= (split(/Auth\s*=(.+?)\s{1}/,$ret))[1];

		$this->{captcha_token}= (split(/CaptchaToken\s*=(.+?)\s{1}/m,$ret))[1];
		$this->{captcha_url}  = (split(/CaptchaUrl\s*=(.+?)\s{1}/m,$ret))[1];
		return $this;

	}

	sub _urlencode {
    	my ($string) = shift;
    	$string =~ s/(\W)/"%" . unpack("H2", $1)/ge;
    	return $string;
 	}

"The earth is blue like an orange.";

__END__


=pod

=head1 NAME

WebService::GData::ClientLogin - implements ClientLogin authorization for google data related APIs v2.

=head1 VERSION

0.01

=head1 SYNOPSIS

	#you will want to use a service instead such as WebService::GData::YouTube;
	use WebService::GData::Base;
	use WebService::GData::ClientLogin;

    #create an object that only has read access
   	my $base = new WebService::GData::Base();

	eval {
		my $auth = new WebService::GData::ClientLogin(
			email    => '...',
			password => '...',
			service  => '...', #default to youtube,
			source   => '...' #default to WebService::GData::ClientLogin-$VERSION,
			type    => '...'  #default to HOSTED_OR_GOOGLE
		);
	};
	if(my $error = $@){
		#$error->code,$error->content...
	}
	if($auth->captcha_url){
		#display the image and get the answer from the user
		#then try to login again
	}

	#everything is fine...
	#give write access to the above user...
	$base->auth($auth);

	#now you can... (url are here for examples!)

	#create a new entry with application/x-www-form-urlencoded content-type
	my $ret = $base->post('http://gdata.youtube.com/feeds/api/users/default/playlists',$content);

	#if it fails a first time, you will need to add captcha related parameters:
		my $auth = new WebService::GData::ClientLogin(
			email          => '...',
			password       => '...',
			captcha_token  => '...',
			captcha_answer => '...'
		);
	#youtube specific developer key 
		my $auth = new WebService::GData::ClientLogin(
			email    => '...',
			password => '...',
			key      => '...',
		);


=head1 DESCRIPTION

inherits from WebService::GData;

Google services supports different authorization systems allowing you to write data programmaticly. ClientLogin is one of such system.

This package tries to get an authorization key to the service specified by logging in with user account information: email and password.

If the loggin succeeds, the authorization key generated for you grants you access to write actions as long as you pass the key with each requests.

ClientLogin authorization key does expire but the expire time is set on a per service basis.

You should use this authorization system for installed applications.

Web application should use the OAuth (to be implemented) or AuthSub (will be deprecated and will not be implemented) authorization systems.

ClientLogin information can be found here:

L<http://code.google.com/intl/en/apis/accounts/docs/AuthForInstalledApps.html>


=head1 CONSTRUCTOR


=head2 new

=over

Takes an hash with the following parameters(parameters ended with * are optionals):

=item B<email>

Specify the user email account.  


=item B<password>

Specifies the user password account. 
    
=item B<service>

Specify the service you want to loggin. youtube for youtube, cl for calendar,etc. 

List available here:L<http://code.google.com/intl/en/apis/base/faq_gdata.html#clientlogin>

Default to youtube.

=item B<source>

Specify the name of your application in the following format "company_name-application_name-version_id".

Default to WebService::GData::ClientLogin-$VERSION but you should provide a real source to avoid getting blocked

because Google thought you are a bot...
     
=item B<type*>

Specify the type of account: GOOGLE,HOSTED or HOSTED_OR_GOOGLE.

Default to HOSTED_OR_GOOGLE.

=item B<captcha_token*>

Specify the captcha_token you received in response to a failure to log in. 

=item B<captcha_answer*>

Specify the answer of the user for the CAPTCHA. 


Throws a WebService::GData::Error in case of failure.

=back

=head1 GETTER METHODS

=head2 email

=over

Returns the email address set to log in.

=head2 password

=over

Returns the password set to log in.

=head2 source

=over

Returns the source set to log in.

=head2 service

=over

Returns the service set to log in.

=head2 type

=over

Returns the account type set to log in.

=head2 captcha_token

=over

Returns the captcha token sent back in case of failure with CaptchaRequired message.

=head2 captcha_url

=over

Returns the captcha url sent back in case of failure with CaptchaRequired message.
This url links to an image containing the challenge.

=head2 captcha_answer

=over

Returns the captcha answer made by the user.

=head2 authorization_key

=over

Returns the authorization key sent back in case of success.

=head2 key 

=over

Returns the developer key (youtube only).



=head1  HANDLING ERRORS/CAPTCHA

Google data APIs relies on querying remote urls on particular services.

All queries that fail will throw (die) a WebService::GData::Error object. 

the CaptchaRequired does not throw an error.

Here is an example of how to implement the logic for a captcha in a web context.

(WARNING:shall not be used in a web context though but easy to grasp!)


Example:

    use WebService::GData::ClientLogin;

    my $auth;	
	eval {
    	 $auth   = new WebService::GData::ClientLogin(
			email => '...',#from the user
			password =>'...',#from the user
			service =>'youtube',
			source =>'MyCompany-MyApp-2'
		);
	};

	if(my $error = $@) {
		#something went wrong, display some info to the user
		#$error->code,$error->content
	}

	#else it seems ok but...

	#check to see if got back a captcha_url

	if($auth->captcha_url){
		#ok, so there was something wrong, we'll try again.
		my $img = $auth->captcha_url;
		my $key = $auth->captcha_token;
		
		#here an html form as an example
		#(WARNING:shall not be used in a web context but easy to grasp!)
		print q[<form action="/cgi-bin/...mycaptcha.cgi" method="POST">];
		print qq[<input type="hidden" value="$key" name="captcha_token"/>];
		print qq[<input type="text" value="" name="email"/>];
		print qq[<input type="text" value="" name="password"/>];
		print qq[<img src="$img" />];
		print qq[<input type="text" value=""  name="captcha_answer"/>];
		#submit button here
	}
    
	#once the form is submitted, in your mycaptcha.cgi program:
    my $auth;	
	eval {
    	 $auth   = new WebService::GData::ClientLogin(
			email => '...',#from the user
			password =>'...',#from the user
			service =>'youtube',
			source =>'MyCompany-MyApp-2',
			captcha_token => '...',#from the above form
			captcha_answer => '...'#from the user
		);
	};

	##error checking again...


=head1  CONFIGURATION AND ENVIRONMENT

none


=head1  DEPENDENCIES

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