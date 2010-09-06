package WebService::GData::Constants;
use strict;
use warnings;
our $VERSION  = 1.02;

use constant  {
	#general...
	XML_HEADER			 => '<?xml version="1.0" encoding="UTF-8"?>',
	GDATA_MINIMUM_VERSION=> 2,

	#QUERY
	TRUE				=>'true',
	FALSE				=>'false',

	#URLS
	CLIENT_LOGIN_URL	=> 'https://www.google.com/accounts/ClientLogin',
	CAPTCHA_URL			=> 'http://www.google.com/accounts/',

	#SERVICES
	ANALYTICS_SERVICE	=> 'analytics',
	APPS_SERVICE		=> 'apps',
	BASE_SERVICE		=> 'gbase',
	SITES_SERVICE		=> 'jotspot',
	BLOGGER_SERVICE		=> 'blogger',
	BOOK_SERVICE		=> 'print',
	CALENDAR_SERVICE	=> 'cl',
	CODE_SERVICE		=> 'codesearch',
	CONTACTS_SERVICE	=> 'cp',
	DOCUMENTS_SERVICE   => 'writely',
	FINANCE_SERVICE		=> 'finance',
	GMAIL_SERVICE		=> 'mail',
	HEALTH_SERVICE		=> 'health',
	HEALTH_SB_SERVICE	=> 'weaver',
	MAPS_SERVICE		=> 'local',
	PICASA_SERVICE		=> 'lh2',
	SIDEWIKI_SERVICE	=> 'annotateweb',
	SPREADSHEETS_SERVICE=> 'wise',
	WEBMASTER_SERVICE	=> 'sitemaps',
	YOUTUBE_SERVICE		=> 'youtube',

	#FORMATS
	JSON                => 'json',
	JSONC               => 'jsonc',
	ATOM		        => 'atom',
	RSS		            => 'rss',
	
	#HTTP STATUS
    OK                    =>200,
    CREATED               =>201,
    NOT_MODIFIED          =>304,
    BAD_REQUEST           =>400,
    UNAUTHORIZED          =>401,
    FORBIDDEN             =>403,
    NOT_FOUND             =>404,
    CONFLICT              =>409,
    GONE                  =>410,
    INTERNAL_SERVER_ERROR =>500,

	#NAMESPACES
	ATOM_NAMESPACE		=> 'xmlns="http://www.w3.org/2005/Atom"',
	OPENSEARCH_NAMESPACE=> 'xmlns:openSearch="http://a9.com/-/spec/opensearch/1.1/"',
	GDATA_NAMESPACE     => 'xmlns:gd="http://schemas.google.com/g/2005"',
	GEORSS_NAMESPACE	=> 'xmlns:georss="http://www.georss.org/georss"',
	GML_NAMESPACE		=> 'xmlns:gml="http://www.opengis.net/gml"',
	MEDIA_NAMESPACE     => 'xmlns:media="http://search.yahoo.com/mrss/"',
	APP_NAMESPACE		=> 'xmlns:app="http://www.w3.org/2007/app"',

};
my  @general   = qw(XML_HEADER GDATA_MINIMUM_VERSION);

my  @query   = qw(TRUE FALSE);

my @http_status= qw(OK CREATED NOT_MODIFIED BAD_REQUEST UNAUTHORIZED FORBIDDEN NOT_FOUND CONFLICT GONE INTERNAL_SERVER_ERROR);

my  @format    = qw(JSON JSONC ATOM RSS);

my  @namespace = qw(ATOM_NAMESPACE OPENSEARCH_NAMESPACE GDATA_NAMESPACE GEORSS_NAMESPACE GML_NAMESPACE MEDIA_NAMESPACE APP_NAMESPACE);

my  @service   = qw(YOUTUBE_SERVICE WEBMASTER_SERVICE SPREADSHEETS_SERVICE SIDEWIKI_SERVICE PICASA_SERVICE MAPS_SERVICE HEALTH_SB_SERVICE HEALTH_SERVICE
					GMAIL_SERVICE FINANCE_SERVICE DOCUMENTS_SERVICE CONTACTS_SERVICE CODE_SERVICE CALENDAR_SERVICE CALENDAR_SERVICE BOOK_SERVICE 
					BLOGGER_SERVICE SITES_SERVICE BASE_SERVICE APPS_SERVICE ANALYTICS_SERVICE);
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK   = (@format,@namespace,@general,@service,@query,@http_status);
our %EXPORT_TAGS = (http_status=>[@http_status],
					service=>[@service],
					format => [@format],
					namespace=>[@namespace],
					general=>[@general],
					all=>[@format,@namespace,@general,@service,@query,@http_status]);


"The earth is blue like an orange.";

__END__


=pod

=head1 NAME

WebService::GData::Constants - constants (namespaces,format,services...) used for Google data APIs.


=head1 SYNOPSIS

    #don't important anything
    use WebService::GData::Constants; 

    #import the namespace related constants
    use WebService::GData::Constants qw(:namespace); #or :format or :general or :all

    use WebService::GData::Base;
    use WebService::GData::ClientLogin;

    my $auth = new WebService::GData::ClientLogin(service=> BOOK_SERVICE,....);


    my $base = new WebService::GData::Base();
	   $base->query()->alt(JSON);

    #if not imported
	
    $base->add_namespace(WebService::GData::Constants::MEDIA_NAMESPACE);
    $base->add_namespace(WebService::GData::Constants::ATOM_NAMESPACE);

    #if imported
	
    $base->add_namespace(MEDIA_NAMESPACE);
    $base->add_namespace(ATOM_NAMESPACE);


=head1 DESCRIPTION

This package contains some constants for Google data API available protocol formats, namespaces and general matters (version,xml header).
You can import all of them by using :all or import only a subset by using :format,:namespace or :general

=head2 GENERAL CONSTANTS

The general consants map the google data API version number and the xml header.
You can choose to import general related constants by writing use WebService::GData::Constants qw(:general);

=head3 GDATA_MINIMUM_VERSION

=head3 XML_HEADER


I<import with :general>


=head2 FORMAT CONSTANTS

The format consants map the available protocol format as of version 2 of the google data API.
You can choose to import format related constants by writing use WebService::GData::Constants qw(:format);

=head3 JSON

=head3 JSONC

=head3 RSS

=head3 ATOM

I<import with :format>

=head2 NAMESPACE CONSTANTS

The namespace consants map the available namespace used as of version 2 of the google data API.
You can choose to import namespace related constants by writing use WebService::GData::Constants qw(:namespace);
The namespace follow the following format: xmlns:namespace_name="uri"

=head3 ATOM_NAMESPACE

=head3 OPENSEARCH_NAMESPACE

=head3 GDATA_NAMESPACE

=head3 GEORSS_NAMESPACE

=head3 GML_NAMESPACE

=head3 MEDIA_NAMESPACE

=head3 APP_NAMESPACE

I<import with :namespace>

=head2 SERVICE CONSTANTS

The service consants map the available services used for the ClientLogin authentication system.
Some of the service name does not map very well the API name, ie Picasa API has a service name of 'lh2'.
The constants offer naming closer to the original API (PICASA_SERVICE). Not shorter but may be easier to remember.
In case the service name came to change, you won't need to change it in every peace of code either.
You can choose to import service related constants by writing use WebService::GData::Constants qw(:service);


=head3 ANALYTICS_SERVICE

=head3 APPS_SERVICE

=head3 BASE_SERVICE

=head3 SITES_SERVICE

=head3 BLOGGER_SERVICE
	
=head3 BOOK_SERVICE

=head3 CALENDAR_SERVICE

=head3 CODE_SERVICE

=head3 CONTACTS_SERVICE

=head3 DOCUMENTS_SERVICE
 
=head3 FINANCE_SERVICE
	
=head3 GMAIL_SERVICE
		
=head3 HEALTH_SERVICE
	
=head3 HEALTH_SB_SERVICE

=head3 MAPS_SERVICE

=head3 PICASA_SERVICE

=head3 SIDEWIKI_SERVICE

=head3 SPREADSHEETS_SERVICE

=head3 WEBMASTER_SERVICE
	
=head3 YOUTUBE_SERVICE

I<import with :service>

=head2 QUERY CONSTANTS

The query consants map the possible values for query parameters of version 2 of the google data API.
You can choose to import query related constants by writing use WebService::GData::Constants qw(:query);


=head3 TRUE

=head3 FALSE


I<import with :query>

=head2 HTTP STATUS CONSTANTS

The http status consants map the possible values for a response code from version 2 of the google data API.
You can choose to import http status related constants by writing use WebService::GData::Constants qw(:http_status);


=head3 OK

=head3 CREATED
	
=head3 NOT_MODIFIED
	
=head3 BAD_REQUEST
	
=head3 UNAUTHORIZED
	
=head3 FORBIDDEN
	
=head3 NOT_FOUND
	
=head3 CONFLICT
	
=head3 GONE
	
=head3 INTERNAL_SERVER_ERROR



=head1 BUGS AND LIMITATIONS

If you do me the favor to _use_ this module and find a bug, please email me
i will try to do my best to fix it (patches welcome)!

=head1 AUTHOR

shiriru E<lt>shirirulestheworld[arobas]gmail.comE<gt>

=head1 LICENSE AND COPYRIGHT

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut