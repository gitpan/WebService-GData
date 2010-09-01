package WebService::GData::YouTube;
use WebService::GData;
use base 'WebService::GData';

use WebService::GData::Base;
use WebService::GData::YouTube::Query;
use WebService::GData::YouTube::Feed;
use WebService::GData::YouTube::Feed::PlaylistLink;

	our $PROJECTION     = 'api';
	our $BASE_URI       = 'http://gdata.youtube.com/feeds/';
our $VERSION  = 0.01_01;

	sub __init {
		my ($this,$auth) = @_;

		$this->{_baseuri}   = $BASE_URI.$PROJECTION.'/';
		$this->{_dbh}       = new WebService::GData::Base(auth=>$auth);

		#overwrite default query engine to support youtube extra feature
		my $query = new WebService::GData::YouTube::Query();
		$query->key($auth->key) if($auth->key);
		$this->query($query);
	}

	sub query {
		my ($this,$query) = @_;
		if($query){
			$this->{_dbh}->query($query);
		}
		return $this->{_dbh}->query;
	}

	sub base_uri {
		my $this = shift;
		return $this->{_baseuri};
	}

	sub base_query {
		my $this = shift;
		return $this->query->to_query_string;
	}

	#playlist related

	sub get_user_playlist_by_id {
		my ($this,$playlistid,$full) = @_;

		my $res = $this->{_dbh}->get($this->{_baseuri}.'playlists/'.$playlistid);

		my $playlists = new WebService::GData::YouTube::Feed($res,$this->{_dbh});

		return $playlists if($full);

	 	return $playlists->entry->[0];	
	}


	sub get_user_playlists {
		my ($this,$channel,$full) = @_;

		#by default, the one connected is returned
		my $uri = $this->{_baseuri}.'users/default/playlists';
		   $uri = $this->{_baseuri}.'users/'.$channel.'/playlists' if($channel);

		my $res = $this->{_dbh}->get($uri);

		my $playlists = new WebService::GData::YouTube::Feed($res,$this->{_dbh});

		return $playlists if($full);

	 	return $playlists->entry;	
	}

	#video related


	sub video_search {
		my ($this,$query) = @_;
		$this->query($query) if($query);
		my $res = $this->{_dbh}->get($this->{_baseuri}.'videos/');
		my $playlists = new WebService::GData::YouTube::Feed($res,$this->{_dbh});
	 	return $playlists->entry;	
	}

	sub get_video_by_id {
		my ($this,$id) = @_;

		my $uri = $this->{_baseuri}.'videos/'.$id;

		my $res = $this->{_dbh}->get($uri);

		my $playlists = new WebService::GData::YouTube::Feed($res,$this->{_dbh});

	 	return $playlists->entry->[0];	
	}

	sub get_user_video_by_id {
		my ($this,$id,$channel) = @_;

		my $uri = $this->{_baseuri}.'users/default/uploads/'.$id;
		   $uri = $this->{_baseuri}.'users/'.$channel.'/uploads/'.$id if($channel);

		my $res = $this->{_dbh}->get($uri);

		my $playlists = new WebService::GData::YouTube::Feed($res,$this->{_dbh});

	 	return $playlists->entry->[0];	
	}

 	sub get_user_videos {
		my ($this,$channel) = @_;

		my $uri = $this->{_baseuri}.'users/default/uploads';
		   $uri = $this->{_baseuri}.'users/'.$channel.'/uploads' if($channel);

		my $res = $this->{_dbh}->get($uri);

		my $playlists = new WebService::GData::YouTube::Feed($res,$this->{_dbh});

	 	return $playlists->entry;	
	}

	sub get_user_favorite_videos {
		my ($this,$channel) = @_;

		my $uri = $this->{_baseuri}.'users/default/favorites/';
		   $uri = $this->{_baseuri}.'users/'.$channel.'/favorites/' if($channel);

		my $res = $this->{_dbh}->get($uri);

		my $playlists = new WebService::GData::YouTube::Feed($res,$this->{_dbh});

	 	return $playlists->entry;
	}

	sub move_video {
		my ($this,%params)=@_;

		   my $playlistLink = new WebService::GData::YouTube::Feed::PlaylistLink({},$this->{_dbh});
			  #delete old one
		      $playlistLink-> playlistId($params{'from'});
		      $playlistLink-> deleteVideo(videoId=>$params{'videoid'});
			  #put in new one
		      $playlistLink-> playlistId($params{'to'});
		      $playlistLink-> addVideo(videoId=>$params{'videoid'});
	}


	#standard feeds
	no strict 'refs';
	foreach my $stdfeed (qw(top_rated top_favorites most_viewed most_popular most_recent most_discussed most_responded recently_featured watch_on_mobile)){

		*{__PACKAGE__.'::get_'.$stdfeed} = sub {
			my ($this,$region,$category,$time) = @_;

			my $uri = $this->{_baseuri}.'standardfeeds/';
			   $uri.= $region.'/' if($region);
			   $uri.= $stdfeed;
			   $uri.= '_'.$category if($category);
				$this->query->time($time) if($time);
		   my $res = $this->{_dbh}->get($uri);

		    my $playlists = new WebService::GData::YouTube::Feed($res,$this->{_dbh});
	 	    return $playlists->entry;			
		}
	}

	#to do: comments returns comments feeds! responses,related sends back video feed so are ok!
	foreach my $feed (qw(comments responses related)){

		*{__PACKAGE__.'::get_'.$feed.'_for_video_id'} = sub {
			my ($this,$id) = @_;

			my $uri = $this->{_baseuri}.'video/'.$id.'/'.$feed;
		    my $res = $this->{_dbh}->get($uri);

		    my $playlists = new WebService::GData::YouTube::Feed($res,$this->{_dbh});
	 	    return $playlists->entry;			
		}
	}

"The earth is blue like an orange.";

__END__


=pod

=head1 NAME

WebService::GData::YouTube - Access YouTube contents(read/write) with API v2.

=head1 VERSION

0.01

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
	}

	#connect to a YouTube account
	my $auth = new WebService::GData::ClientLogin(
		email=>'...'
		password=>'...',
		key		=>'...'
	);

	#give write access with a $auth object that you created
   	my $yt = new WebService::GData::YouTube($auth);

	my $playlists  = $yt->get_user_videos();#returns videos from the loggedin user even if private

	#update the playlist by adding the playlist title as a keyword
	foreach my $playlist (@$playlists) {

		if($video->video_id eq $myid) {
			$video->delete($myid);
		}else {
			if($video->is_listed_allowed){
				$playlist->kewords($playlist->title.','.$playlist->keywords);
				$playlist->save();
			}
		}
	}
	 



=head1 DESCRIPTION

inherits from WebService::GData;

This package is a point of entry giving access to general YouTube feeds you may want to access.

It also offers some helper methods to shorten up the code.

Most of the methods will return one of the following object:

- WebService::GData::YouTube::Feed::Video

This object handles the manipulation of the video data such as inserting/editing the metadata, uploading a video,etc.

- WebService::GData::YouTube::Feed::Playlist

This object inherits from WebService::GData::YouTube::Feed::Video.

The name may let you think that it is a playlist metadata information but it's not.

It contains a list of all the videos within this particular playlist.

The only difference with Video is that it offers the position tag that specifies the position of the video within the playlist.

- WebService::GData::YouTube::Feed::PlaylistLink

This object represents all the playlists metadata of a user.

It is not possible to get the metadata of one playlist. You need to query them all and then get the one you want to edit.


=head1 CONSTRUCTOR


=head2 new

=over

Accept an optional authorization object (ClientLogin only implemented for now) which if set

will allow you to access private contents and insert/edit/delete them.

=head1 GENERAL METHODS

=head2 query

=over

set/get a query object that handles the creation of the query string. Default : WebService::GData::YouTube::Query.

=head2 base_uri

=over

get the base uri used to query the data.

=head2 base_query

=over

get the base query string used in all get methods. Default: ?alt=json&prettyprint=false&strict=true

=head1 STANDARD FEED METHODS

All the standard feed methods are implemented.

This allow you to grab feeds from YouTube main categories feed (top_rated,most_viewed,...).

All the following methods accept optional arguments:

- region zone (ie,JP,US)

- category (Comedy,Sports...)

- time (today,this_week,this_month,all_time)

All these methods send back WebService::GData::Youtube::Feed::Video objects.

Example:

    use WebService::GData::YouTube;
	
    my $yt   = new WebService::GData::YouTube();
    my @videos = $yt->get_top_rated();
    my @videos = $yt->get_top_rated('JP');#top rated videos in Japan
    my @videos = $yt->get_top_rated('JP','Comedy');#top rated videos in Japanese Comedy 
    my @videos = $yt->get_top_rated('JP','Comedy','today');#top rated videos of the day in Japanese Comedy 



See L<http://code.google.com/intl/en/apis/youtube/2.0/reference.html#Standard_feeds>


=head2 get_top_rated 

=head2 get_top_favorites

=head2 get_most_viewed

=head2 get_most_popular

=head2 get_most_recent

=head2 get_most_discussed

=head2 get_most_responded 

=head2 get_recently_featured

=head2 get_watch_on_mobile 

=head1 VIDEO FEED METHODS

All these methods allow you to access a video.
You do not need to be logged in.

=head2 get_video_by_id

Return a WebService::GData::YouTube::Feed::Video object for the specified video id.
You must specify the video id.

=head2 search_video

Return WebService::GData::YouTube::Feed::Video objects for the specified query.

Example:

    use WebService::GData::YouTube;
	
    my $yt   = new WebService::GData::YouTube();
		$yt->query->q("ski")->limit(10,0);
	my $videos = $yt->search_video();

	#or the same
    my $yt   = new WebService::GData::YouTube();
	my $query = $yt->query;
		$query->q("ski")->limit(10,0);
	my $videos = $yt->search_video();

	#or set a new query object:
    my $yt   = new WebService::GData::YouTube();
	my $query = new WebService::GData::YouTube::Query();#it could be a sub class that has predefined value
		$query->q("ski")->limit(10,0);
	my $videos = $yt->search_video($query);


=head2 get_video_by_id

Return a WebService::GData::YouTube::Feed::Video object for the specified video id.

=head2 get_related_for_video_id

Return WebService::GData::YouTube::Feed::Video objects for the specified video id.

The related videos are returned by the YouTube program by following its own algorythm.


=head1 USER VIDEO FEED METHODS

All these methods allow you to access the video of the user logged in or for a certain user that you set as an argument.

If you are not logged in,you should set the user name you want to access.

=head2 get_user_video_by_id

Return a WebService::GData::YouTube::Feed::Video object for the specified video id.

If you are logged in, you can get access to private videos or to the latest uploads.

If you are not logged in, you can set a user name as the first parameter but will not get access to private contents.

=head2 get_user_videos

Return WebService::GData::YouTube::Feed::Video objects for the logged in user or for the user name you specified.

If you are logged in, you can get access to private videos or to the latest uploads.

If you are not logged in, you will not get access to private videos.

=head2 get_user_favorite_videos

Return WebService::GData::YouTube::Feed::Video objects for the logged in user or for the user name you specified.


=head1 USER PLAYLIST METHODS

All these methods allow you to access the videos in a playlist or a list of the playlists of a user.

If you are not logged in,you should set the user name you want to access.

=head2 get_user_playlist_by_id

=over

Return a WebService::GData::YouTube::Feed::Playlist object for the specified playlist id.

A WebService::GData::YouTube::Feed::Playlist contains the same information as a Video Feed but adds the position of the video within the feed.

=head2 get_user_playlists

=over

Return a WebService::GData::YouTube::Feed::PlaylistLink object for the logged in user or for the user name you specified.

If you are logged in, you can get access to private playlists.

WebService::GData::YouTube::Feed::PlaylistLink is a list of playlists. If you want to modify one playlist information,
you need to get all of them, loop until you find the one you want and then edit the playlist.


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