package WebService::GData::YouTube;
use WebService::GData;
use base 'WebService::GData';

use WebService::GData::Base;
use WebService::GData::YouTube::Query;
use WebService::GData::YouTube::Feed;
use WebService::GData::YouTube::Feed::PlaylistLink;

	our $PROJECTION     = 'api';
	our $BASE_URI       = 'http://gdata.youtube.com/feeds/';
	our $VERSION  = 0.01_02;

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

	#give write access
   	my $yt = new WebService::GData::YouTube($auth);

    #returns all the videos from the logged in user 
	#including private ones.
	my $videos  = $yt->get_user_videos();

	#update the videos by adding the common keywords if they are public
	#delete a certain video by checking its id.
	foreach my $video (@$videos) {

		if($video->video_id eq $myid) {
			$video->delete($myid);
		}else {
			if($video->is_listed_allowed){
				$video->keywords($video->title.','.$video->keywords);
				$video->save();
			}
		}
	}
	 

=head1 DESCRIPTION

inherits from WebService::GData;

This package is a point of entry giving access to general YouTube feeds you may want to access.

It also offers some helper methods to shorten up the code.

Most of the methods will return one of the following object:

=over 

=item L<WebService::GData::YouTube::Feed::Video>

This object handles the manipulation of the video data such as inserting/editing the metadata, uploading a video,etc.

=item L<WebService::GData::YouTube::Feed::Playlist>

This object inherits from WebService::GData::YouTube::Feed::Video.

The name may let you think that it is a playlist metadata information but it's not.

It contains a list of all the videos within this particular playlist.

The only difference with Video is that it offers the position tag that specifies the position of the video within the playlist.

=item L<WebService::GData::YouTube::Feed::PlaylistLink>

This object represents all the playlists metadata of a user.

It is not possible to get the metadata of one playlist. You need to query them all and then get the one you want to edit.

=back


=head2 CONSTRUCTOR


=head3 new

Create a L<WebService::GData::YouTube> instance.

I<Parameters>:

=over

=item C<auth:Scalar> (optional) 

Accept an optional authorization object.

Only L<WebService::GData::ClientLogin> is available for now but OAuth should come anytime soon.

Passing an auth object allows you to access private contents and insert/edit/delete data.

=back

I<Return>:

=over

=item L<WebService::GData::YouTube> instance 

=back


Example:

	use WebService::GData::ClientLogin;
	use WebService::GData::YouTube;

    #create an object that only has read access
   	my $yt = new WebService::GData::YouTube();

	#connect to a YouTube account
	my $auth = new WebService::GData::ClientLogin(
		email=>'...'
		password=>'...',
		key		=>'...'
	);

	#give write access with a $auth object that you created
   	my $yt = new WebService::GData::YouTube($auth);


=head2 GENERAL METHODS

=head3 query

Set/get a query object that handles the creation of the query string.
The query object will build the query string required to access the data.
Most of the time you will not need it unless you want to do a particular query.

I<Parameters>:

=over

=item C<query:Object> (Default : L<WebService::GData::YouTube::Query>)

=back

I<Return>:

=over

=item C<query:Object> (Default : L<WebService::GData::YouTube::Query>)

or 

=item C<void> 

=back

Example:

	use WebService::GData::YouTube;

   	my $yt = new WebService::GData::YouTube();

	$yt->query()->q("ski")->limit(10,0);
	#or set your own query object
	$yt->query($myquery);
	my $videos = $yt->search_video();


=head3 base_uri

Get the base uri used to query the data.

I<Parameters>:

=over

=item none

=back

I<Return>:

=over

=item C<url:Scalar> 

=back


=head3 base_query

Get the base query string used to query the data.

I<Parameters>:

=over

=item none

=back

I<Return>:

=over

=item C<url:Scalar> (Default: ?alt=json&prettyprint=false&strict=true)

=back


=head2 STANDARD FEED METHODS

All the standard feed methods are implemented:

I<methods>:

=head3 get_top_rated 

=head3 get_top_favorites

=head3 get_most_viewed

=head3 get_most_popular

=head3 get_most_recent

=head3 get_most_discussed

=head3 get_most_responded 

=head3 get_recently_featured

=head3 get_watch_on_mobile 

This allows you to grab feeds from YouTube main categories (top_rated,most_viewed,...).

All the above standard feed methods accept the following optional parameters:

I<Parameters>:

=over

=item <region_zone:Scalar> (ie,JP,US)

=item <category:Scalar> (ie,Comedy,Sports...)

=item <time:Scalar> (ie,today,this_week,this_month,all_time)

=back

I<Return>:

=over

=item L<WebService::GData::Youtube::Feed::Video> objects

=back

I<Throw>:

=over

=item L<WebService::GData::Error>

=back

Example:

    use WebService::GData::YouTube;
	
    my $yt   = new WebService::GData::YouTube();
    my $videos = $yt->get_top_rated();
    my $videos = $yt->get_top_rated('JP');#top rated videos in Japan
    my $videos = $yt->get_top_rated('JP','Comedy');#top rated videos in Japanese Comedy 
    my $videos = $yt->get_top_rated('JP','Comedy','today');#top rated videos of the day in Japanese Comedy 


I<See also>:

See L<http://code.google.com/intl/en/apis/youtube/2.0/reference.html#Standard_feeds>


=head2 VIDEO FEED METHODS

These methods allow you to access videos.
You do not need to be logged in to use these methods.

=head3 get_video_by_id

Get a video by its id.

I<Parameters>:

=over

=item C<video_id:Scalar>

=back

I<Return>:

=over

=item L<WebService::GData::YouTube::Feed::Video>

=back

I<Throw>:

=over

=item L<WebService::GData::Error>

=back

Example:

    use WebService::GData::YouTube;
	
    my $yt   = new WebService::GData::YouTube();

	my $video = $yt->get_video_by_id($myvideoid);


=head3 search_video

Search for videos responding to a particular query.

I<Parameters>:

=over

=item none

=back

I<Return>:

=over

=item L<WebService::GData::YouTube::Feed::Video>

=back

I<Throw>:

=over

=item L<WebService::GData::Error>

=back

Example:

    use WebService::GData::YouTube;
	
    my $yt   = new WebService::GData::YouTube();

	   $yt->query->q("ski")->limit(10,0);

	my $videos = $yt->search_video();

	#or
    my $yt     = new WebService::GData::YouTube();
	my $query  = $yt->query;
	   $query -> q("ski")->limit(10,0);
	my $videos = $yt->search_video();

	#or set a new query object
    my $yt     = new WebService::GData::YouTube();

	#it could be a sub class that has predefined value
	my $query  = new WebService::GData::YouTube::Query();
	   $query -> q("ski")->limit(10,0);
	my $videos = $yt->search_video($query);

I<See also>:

L<WebService::GData::YouTube::Query>


=head3 get_related_for_video_id

Get the related videos for a video.
These videos are returned by following YouTube own algorithm.

I<Parameters>:

=over

=item C<video_id:Scalar>

=back

I<Return>:

=over

=item L<WebService::GData::YouTube::Feed::Video> objects 

=back

I<Throw>:

=over

=item  L<WebService::GData::Error> 

=back



=head2 USER VIDEO FEED METHODS

All these methods allow you to access the videos of the logged in user.

If not logged in,you should set the user name you want to access.

=head3 get_user_video_by_id

Get a video for the logged in user or for the user name you specified.

I<Parameters>:

=over

=item C<video_id:Scalar>

=item C<user_name:Scalar> (optional)

=back

I<Return>:

=over

=item L<WebService::GData::YouTube::Feed::Video> objects 

=back

I<Throw>:

=over

=item  L<WebService::GData::Error> 

=back


=head3 get_user_favorite_videos

I<Parameters>:

=over

=item C<user_name:Scalar> (optional)

=back

I<Return>:

=over

=item L<WebService::GData::YouTube::Feed::Video> objects 

=back

I<Throw>:

=over

=item  L<WebService::GData::Error> 

=back


=head3 get_user_videos

Get the videos for the logged in user or for the user name you specified.

I<Parameters>:

=over

=item C<user_name:Scalar> (optional)

=back

I<Return>:

=over

=item L<WebService::GData::YouTube::Feed::Video> objects 

=back

I<Throw>:

=over

=item  L<WebService::GData::Error> 

=back


=head3 get_user_favorite_videos

I<Parameters>:

=over

=item C<user_name:Scalar> (optional)

=back

I<Return>:

=over

=item L<WebService::GData::YouTube::Feed::Video> objects 

=back

I<Throw>:

=over

=item  L<WebService::GData::Error> 

=back


=head2 USER PLAYLIST METHODS

These methods allow you to access the videos in a playlist or a list of the playlists for a certain user.

If you are not logged in,you must set the user name.

=head3 get_user_playlist_by_id

Retrieve the videos in a playlist by passing the playlist id.

I<Parameters>:

=over

=item C<playlist_id:Scalar>

=item C<user_name:Scalar> (optional)

=back

I<Return>:

=over

=item  L<WebService::GData::YouTube::Feed::Playlist>

A L<WebService::GData::YouTube::Feed::Playlist> contains the same information as a L<WebService::GData::YouTube::Feed::Video> instance

but adds the position information of the video within the playlist.

=back

I<Throw>:

=over

=item  L<WebService::GData::Error> 

=back

=head3 get_user_playlists

Get the playlists metadata for the logged in user or the user set as a parameter.

I<Parameters>:

=over

=item C<user_name:Scalar> (optional)

=back

I<Return>:

=over

=item L<WebService::GData::YouTube::Feed::PlaylistLink> objects

If you are logged in, you can access private playlists.

L<WebService::GData::YouTube::Feed::PlaylistLink> is a list of playlists. 
If you want to modify one playlist metadata, you must get them all, loop until you find the one you want and then edit.

=back

I<Throw>:

=over

=item  L<WebService::GData::Error> 

=back

=head2  HANDLING ERRORS

Google data APIs relies on querying remote urls on particular services.

Some of these services limits the number of request with quotas and may return an error code in such a case.

All queries that fail will throw (die) a WebService::GData::Error object. 

You should enclose all code that requires connecting to a service within eval blocks in order to handle it.


Example:

    use WebService::GData::Base;

	my $auth = new WebService::GData::ClientLogin(email=>...);
	
    my $yt   = new WebService::GData::YouTube($auth);
    
	#the server is dead or the url is not available anymore or you've reach your quota of the day.
	#boom the application dies and your program fails...
    my $videos = $yt->get_user_videos;

	#with error handling...

	#enclose your code in a eval block...
	eval {
   		    my $videos = $yt->get_user_videos;;
	}; 

	#if something went wrong, you will get a WebService::GData::Error object back:
	if(my $error = $@){

		#do whatever you think is necessary to recover (or not)
		#print/log: $error->content,$error->code
	}	


=head2  TODO

Many things are left to be implemented!

The YouTube API is very thorough and it will take some time but by priority:

=over

=item OAuth authorization system

=item Partial Upload

=item Channel search

=item Playlist search

=item Check the query parameters

=item Partial feed read/write

=item know the status of a video

=back

Certainly missing other stuffs...


=head1  CONFIGURATION AND ENVIRONMENT

none

=head1  DEPENDENCIES

=over

=item L<JSON>

=item L<LWP>

=back

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