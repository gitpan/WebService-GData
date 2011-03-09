package WebService::GData::YouTube::Feed::Video;

use WebService::GData;
use base 'WebService::GData::Feed::Entry';
use WebService::GData::Constants qw(:all);
use WebService::GData::YouTube::Constants qw(:all);
use WebService::GData::Error;
use WebService::GData::Node::PointEntity();
use WebService::GData::YouTube::YT::GroupEntity();
use WebService::GData::YouTube::YT::AccessControl();
use WebService::GData::Node::Media::Category();
use WebService::GData::Collection;

our $VERSION = 0.01_07;

our $UPLOAD_BASE_URI = UPLOAD_BASE_URI . PROJECTION . '/users/default/uploads/';

our $BASE_URI = BASE_URI . PROJECTION . '/users/default/uploads/';

use constant {
	DIRECT_UPLOAD  => 'DIRECT_UPLOAD',
	BROWSER_UPLOAD => 'BROWSER_UPLOAD'
};

sub __init {
	my ( $this, $feed, $req ) = @_;

	if ( ref($feed) eq 'HASH' ) {
		$this->SUPER::__init( $feed, $req );
		$this->_media(
			new WebService::GData::YouTube::YT::GroupEntity(
				$feed->{'media$group'} || {}
			)
		);
	}
	else {
		$this->SUPER::__init( {}, $feed );#$feed ==$req here
		$this->_media( new WebService::GData::YouTube::YT::GroupEntity( {} ) );
	}
	$this->_entity->child( $this->_media );
}

sub next_url {
	my $this = shift;
	if ( @_ == 1 ) {
		$this->{next_url} = _urlencode( shift() );
	}
	return $this->{next_url};
}

sub location {
	my ( $this, $pos ) = @_;
	my $where = $this->{_feed}->{'georss$where'};
	if ( ref($where) eq 'HASH' && !$this->{_where} ) {
		$this->_location(
			new WebService::GData::Node::PointEntity(
				$where->{'gml$Point'}->{'gml$pos'}
			)
		);
	}
	else {
		$this->{_feed}->{'georss$where'} = {};
		$this->_location( new WebService::GData::Node::PointEntity() );
	}
	if ($pos) {
		$this->_location->pos($pos);
	}
	return ref $this->_location->pos ? '' : $this->_location->pos;

}

sub _location {
	my ( $this, $instance ) = @_;
	if ($instance) {
		$this->{_where} = $instance;
		$this->_entity->child($instance);
	}
	$this->{_where};
}

sub view_count {
	my $this = shift;
	$this->{_feed}->{'yt$statistics'}->{'viewCount'};
}

sub favorite_count {
	my $this = shift;
	$this->{_feed}->{'yt$statistics'}->{'favoriteCount'};
}

sub _media {
	my ( $this, $instance ) = @_;
	if ($instance) {
		$this->{_media} = $instance;
	}
	$this->{_media};
}

sub media_player {
	my $this = shift;
	$this->_media->player({})->url;
}

sub aspect_ratio {
	my $this = shift;
	$this->_media->aspect_ratio;
}

sub video_id {
	my ( $this, $id ) = @_;
	$this->_media->videoid($id) if $id;
	ref $this->_media->videoid ? '': $this->_media->videoid;
}

sub duration {
	my $this = shift;
	$this->_media->duration({})->seconds;
}

sub content {
	my $this = shift;
	$this->_media->content;
}

sub thumbnails {
	my $this = shift;
	$this->_media->thumbnail;
}

sub uploaded {
	my $this = shift;
	$this->_media->uploaded;
}

sub category {
	my $this = shift;

	if ( @_ == 1 ) {
		if ( !$this->_media->category->isa('WebService::GData::Collection') ) {
			$this->_media->swap( $this->_media->category,
				new WebService::GData::Collection() );
		}
		push @{ $this->_media->category },
		  new WebService::GData::Node::Media::Category(
			{
				'$t'    => $_[0],
				'label' => $_[0],
				'scheme' =>
				  'http://gdata.youtube.com/schemas/2007/categories.cat'
			}
		  );
	}
	$this->_media->category;
}

sub description {
	my $this = shift;
	if ( @_ == 1 ) {
		$this->_media->description( $_[0] );
		$this->_media->description({})->type("plain");
	}
	$this->_media->description || '';
}

sub title {
	my $this = shift;
	if ( @_ == 1 ) {
		$this->_media->title( $_[0] );

		$this->_media->title({})->type("plain");
	}
	$this->_media->title || '';
}

sub keywords {
	my $this = shift;
	if ( @_ >= 1 ) {
		return $this->_media->keywords( join( ',', @_ ) );
	}
	$this->_media->keywords || '';
}

sub is_private {
	my $this = shift;
	if ( @_ == 1 ) {
		$this->_media->{'_private'} =
		  new WebService::GData::YouTube::YT::Private();
		$this->_media->_entity->child( $this->_media->{'_private'} );
	}
	return ( $this->_media->private ) ? 1 : 0;
}

sub comments {
	my $this = shift;
	$this->{_feed}->{'gd$comments'}->{'gd$feedLink'}->{'href'};
}

sub appcontrol_state {
	my $this = shift;
	return $this->{_feed}->{'app$control'}->{'yt$state'}->{reasonCode};
}

#####WRITE FUNCTIONS########################

sub _access_control {
	my ( $this, $instance ) = @_;
	if ($instance) {
		$this->{_access_control} = $instance;
		$this->_entity->child($instance);
	}
	$this->{_access_control};
}

sub access_control {
	my $this = shift;
	if ( !$this->_access_control ) {
		$this->_access_control( new WebService::GData::Collection() );
		my $access = $this->{_feed}->{'yt$accessControl'} || [];
		foreach my $control (@$access) {
			push @{ $this->_access_control },
			  new WebService::GData::YouTube::YT::AccessControl($control);
		}
	}
	if ( @_ == 2 ) {

		#first check if the action is already set and if so update
		my $ret = $this->_access_control->action( $_[0] );
		if ( @$ret > 0 ) {
			$ret->[0]->permission( $_[1] );
		}

		#if not, just push a new entry;
		else {
			push @{ $this->_access_control },
			  new WebService::GData::YouTube::YT::AccessControl(
				{ action => $_[0], permission => $_[1] } );
		}
	}
	if ( @_ == 1 ) {

		return $this->_access_control->action( $_[0] )->[0];

	}
	$this->_access_control;
}

sub delete {
	my $this = shift;
	my $uri  = $BASE_URI . $this->video_id;
	$this->{_request}->delete( $uri, 0 );
}

sub save {
	my ($this) = @_;
	my $content = XML_HEADER . $this->serialize();

	if ( $this->video_id ) {

		my $ret =
		  $this->{_request}->update( $BASE_URI . $this->video_id, $content );
	}
	else {

		if ( $this->upload_mode eq DIRECT_UPLOAD ) {
			$this->direct_uploading( $UPLOAD_BASE_URI, $content );
		}
		else {
			return $this->browser_uploading( $UPLOAD_BASE_URI, $content );
		}
	}
}

#video upload

sub filename {
	my $this = shift;
	return $this->{_filename} = $_[0] if ( @_ == 1 );
	$this->{_filename};
}

#TODO: stream
sub _binary_data {
	my $this = shift;

	if ( @_ == 1 ) {
		my $fh = $_[0];
		binmode($fh);
		my $data = '';
		while ( read $fh, my $buf, 1024 ) {
			$data .= $buf;
		}
		close $fh;
		return $this->{_binary_data} = $data;
	}
	$this->{_binary_data};
}

sub upload_mode {
	my $this = shift;
	if ( @_ == 1 ) {
		$this->{_UPLOAD_MODE} = shift;
		$this->{_UPLOAD_MODE} = undef
		  if ( $this->{_UPLOAD_MODE} ne DIRECT_UPLOAD
			|| $this->{_UPLOAD_MODE} ne BROWSER_UPLOAD );
	}
	$this->{_UPLOAD_MODE} = BROWSER_UPLOAD if ( !$this->{_UPLOAD_MODE} );
	$this->{_UPLOAD_MODE};
}

sub browser_uploading {
	my ( $this, $uri, $content ) = @_;
	my $response =
	  $this->{_request}
	  ->insert( 'http://gdata.youtube.com/action/GetUploadToken', $content );

	my ( $url, $token ) =
	  $response =~ m/<url>(.+?)<\/url><token>(.+?)<\/token>/;
	if ( $this->next_url ) {
		$url .= '?' . $this->next_url;
	}
	return ( $url, $token, $response );
}

#TODO:move this and rewrite from scratch!
sub direct_uploading {
	my ( $this, $uri, $content ) = @_;

	my $binary = $this->_binary_data;

	my $content2 = <<XML;

--f93dcbA3
Content-Type: application/atom+xml; charset=UTF-8

<?xml version="1.0"?>
<entry xmlns="http://www.w3.org/2005/Atom"
  xmlns:media="http://search.yahoo.com/mrss/"
  xmlns:yt="http://gdata.youtube.com/schemas/2007">
XML

	$content2 .= $content . '</entry>';

	$content2 .= <<XML;

--f93dcbA3
Content-Type: video/quicktime
Content-Transfer-Encoding: binary

$binary

--f93dcbA3--
XML

	my $req = HTTP::Request->new( POST => $uri );

	if ( $this->{_request}->auth ) {
		$this->{_request}->auth->set_authorization_headers( $this, $req );
		$this->{_request}->auth->set_service_headers( $this, $req );
	}
	$req->header( 'GData-Version' => $this->{_request}->query->get('v') );
	$req->header( 'Slug'          => $this->filename );
	$req->content_type('multipart/related; boundary="f93dcbA3"');
	$req->header( 'Content-Length' => length($content2) );
	$req->header( 'Connection'     => 'close' );
	$req->content($content2);

	my $res = $this->{_request}->{__UA__}->request($req);
	if ( $res->is_success ) {
		return $this;
	}
	else {
		die new WebService::GData::Error( $res->code, $res->content );
	}

}

{
	no strict 'refs';
	
	my %controlList = (
		videoRespond => 'video_response',
		rate         => 'rating',
		embed        => 'embedding',
		list         => 'listing',
		syndicate    => 'syndication'
	);
	my @ytControls = ( keys %controlList, 'comment', 'comment_vote' );
	
	foreach my $access (@ytControls) {
		my $name = $access;
		   $name =~ s/_([a-z])/\U$1/g;
		my $func = $controlList{$access} || $access;
		*{ __PACKAGE__ . '::is_' . $func . '_allowed' } = sub {
			my $this = shift;
			my $ret  = $this->_access_control->action($name)->[0];
			return ( $ret && $ret->permission eq 'allowed' ) ? 1 : 0;
		  }
	}
}

private _urlencode => sub {
	my ($string) = shift;
	$string =~ s/(\W)/"%" . unpack("H2", $1)/ge;
	return $string;
};

"The earth is blue like an orange.";

__END__


=pod

=head1 NAME

WebService::GData::YouTube::Feed::Video - a Video YouTube contents(read/write) for data API v2.

=head1 SYNOPSIS

    use WebService::GData::YouTube;

    #create an object that only has read access
    my $yt = new WebService::GData::YouTube();

    #get a feed response from YouTube;
    my $videos  = $yt->get_top_rated;
    #more specific:
    my $videos  = $yt->get_top_rated('JP','Comedy');

    foreach my $video (@$videos) {
        $video->video_id;
        $video->title;
        $video->content;
		$video->view_count;
		$video->favorite_count;
		$video->duration;
		#...etc
    }

    #connect to a YouTube account
    my $auth = new WebService::GData::ClientLogin(
        email=>'...'
        password=>'...',
        key        =>'...'
    );

    #give write access with a $auth object that you created
    my $yt = new WebService::GData::YouTube($auth);

    my $videos  = $yt->get_user_videos();#returns videos from the loggedin user even if private

    #update the playlist by adding the playlist title as a keyword
    foreach my $video (@$videos) {

        if($video->video_id eq $myid) {

            $video->delete();

        }else {

            if($video->is_listing_allowed){

                $video->kewords($playlist->title.','.$video->keywords);
                $video->save();
            }
        }
    }
	 



=head1 DESCRIPTION

!WARNING! Documentation in progress.

!DEVELOPER RELEASE! API may change, program may break or be under optimized.


I<inherits from L<WebService::GData::Feed::Entry>>.

This package represents a Youtube Video. If you are logged in you can edit existing video metadata,create new metadata, upload videos.

Most of the time you will not instantiate this class directly but use some of the helpers in the L<WebService::GData::YouTube> class.

See also:

=over 

=item * L<WebService::GData::YouTube::Doc::BrowserBasedUpload> - overview of the browser based upload mechanism

=back

=head2 CONSTRUCTOR


=head3 new

=over

Create a L<WebService::GData::YouTube::Feed::Video> instance. 

=back

B<Parameters>:

=over

=item C<jsonc_video_entry_feed:Object> (Optional)

=item C<authorization:Object> (Optional)

or 

=item C<authorization:Object> (Optional)

=back

If an authorization object is set (L<WebService::GData::ClientLogin>), 

it will allow you to access private contents and insert/edit/delete/upload videos.

=head2 GET METHODS

All the following read only methods give access to the information contained in a video feed.


=head3 view_count

=head3 favorite_count

=head3 media_player

=head3 aspect_ratio

=head3 duration

=head3 content

=head3 comments

=head3 thumbnails

=head3 uploaded

=head3 etag

=head3 appcontrol_state


=head2 GENERAL SET/GET METHODS

All these methods represents information about the video but you have read/write access on them.

It is therefore necessary to be logged in programmaticly to be able to use them in write mode 
(if not, saving the data will not work).

=head3 title

=head3 video_id

=head3 category

=head3 description

=head3 keywords

=head3 location


=head2 ACCESS CONTROL SET/GET METHODS

These methods allow to grant access to certain activity.

You can decide to unlist the video from the search, make it private or forbid comments,etc.

=head3 is_private

=head3 access_control
 
=over

The access control gives you access to the list of access for a video.

B<Parameters>

=over 

=item C<none> - getter context

=back

B<Returns> 

=over 

=item L<WebService::GData::Collection> - collection of L<WebService::GData::YouTube::YT::AccessControl> instances

=back

B<Parameters>

=over 

=item C<access_name:Scalar> - a particular access object

=back

B<Returns> 

=over 

=item L<WebService::GData::YouTube::YT::AccessControl> instance

=back

B<Parameters>

=over 

=item C<access_name:Scalar> - a particular access object

=item C<control_type:Scalar> - the value to set the permission

=back

B<Returns> 

=over 

=item void

=back

Example:

    
    my $controls   = $video->access_control;
    foreach my $control (@$controls) {
    	$control->action.'->'.$control->permission;
    }
    
    my $control   = $video->access_control('comment')->permission;#default:allowed
    
    $video->access_control('comment','denied');
    
    $video->access_control('comment')->permission; #denied
    
=back
 
 
 

The following methods are helpers that allows know which access control is allowed.
It is therefore a shortcut for the following checking:

    $video->access_control('comment')->permission eq 'allowed'
    
=head3 is_listing_allowed

=head3 is_comment_allowed

=head3 is_comment_vote_allowed

=head3 is_video_response_allowed

=head3 is_rating_allowed

=head3 is_embedding_allowed

=head3 is_syndication_allowed


=head2 QUERY METHODS

These methods actually query the service to save your edits.

You must be logged in programmaticly to be able to use them.

The L<save> method will do an insert if there is no video_id or an update if there is one.

=head3 delete

=head3 save


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

shiriru E<lt>shirirulestheworld[arobas]gmail.comE<gt>

=head1 LICENSE AND COPYRIGHT

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
