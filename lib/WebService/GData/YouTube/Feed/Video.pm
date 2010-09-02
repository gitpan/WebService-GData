package WebService::GData::YouTube::Feed::Video;
use base WebService::GData::Feed::Entry;
our $VERSION  = 0.01_01;
use constant {
	DIRECT_UPLOAD  =>'DIRECT_UPLOAD',
	BROWSER_UPLOAD =>'BROWSER_UPLOAD'
};

	sub upload_mode {
		my $this = shift;
		if(@_==1){
			$this->{_UPLOAD_MODE}=shift;
			$this->{_UPLOAD_MODE}=undef if($this->{_UPLOAD_MODE} ne DIRECT_UPLOAD || $this->{_UPLOAD_MODE} ne BROWSER_UPLOAD);
		}
		$this->{_UPLOAD_MODE}=BROWSER_UPLOAD if(!$this->{_UPLOAD_MODE});
		$this->{_UPLOAD_MODE};
	}

	sub view_count {
		my $this = shift;
		$this->{_feed}->{'yt$statistics'}->{'viewCount'};
	}

	sub favorite_count {
		my $this = shift;
		$this->{_feed}->{'yt$statistics'}->{'favoriteCount'};
	}

	sub media_player {
		my $this = shift;
		$this->{_feed}->{'media$group'}->{'media$player'}->{url};
	}

	sub aspect_ratio {
		my $this = shift;
		$this->{_feed}->{'media$group'}->{'yt$aspectRatio'}->{'$t'};
	}

	sub video_id {
		my $this = shift;
		$this->{_feed}->{'media$group'}->{'yt$videoid'}->{'$t'};
	}

	sub duration {
		my $this = shift;
		$this->{_feed}->{'media$group'}->{'yt$duration'}->{'seconds'};
	}

	sub content {
		my $this = shift;
		$this->{_feed}->{'media$group'}->{'media$content'};
	}

	sub comments {
		my $this = shift;
		$this->{_feed}->{'gd$comments'}->{'gd$feedLink'}->{'href'};
	}

	sub thumbnails {
		my $this = shift;
		$this->{_feed}->{'media$group'}->{'media$thumbnail'};
	}

	sub uploaded {
		my $this = shift;
		$this->{_feed}->{'media$group'}->{'yt$uploaded'}->{'$t'};
	}

	sub etag {
		my $this = shift;
		$this->{_feed}->{'gd$etag'};
	}

	sub appcontrol_state {
		my $this = shift;
		return $this->{_feed}->{'app$control'}->{'yt$state'}->{reasonCode};
	}


#####WRITE FUNCTIONS########################

	sub access_controll {
		my $this = shift;
		if(@_==1){
			$this->{_feed}->{'yt$accessControl'}=[] if(!$this->{_feed}->{'yt$accessControl'});
			push @{$this->{_feed}->{'yt$accessControl'}},{action=>$_[0],permission=>$_[1]};
		}
		$this->{_feed}->{'yt$accessControl'};
	}

	sub _access_controll_serialize {
		my $this = shift;
		my $accessControll="";
		my @accesses=@{$this->{_feed}->{'yt$accessControl'}};
		foreach my $access (@accesses){
			$accessControll.=qq[<yt:accessControl action="$access->{action}" permission="$access->{permission}"/>];
		}
		return $accessControll;
	}

	sub category {
		my $this = shift;
		if(@_==1){
			$this->{_feed}->{'media$group'}->{'media$category'}=[] if(!ref($this->{_feed}->{'media$group'}->{'media$category'}) eq 'ARRAY');
			push @{$this->{_feed}->{'media$group'}->{'media$category'}},{'$t'=>$_[0],'label'=>$_[0],'scheme'=>'http://gdata.youtube.com/schemas/2007/categories.cat'};
			$this->{_feed}->{'media$group'}->{'media$category'}->{'$t'}=$_[0];
		}
		$this->{_feed}->{'media$group'}->{'media$category'};
	}

	sub _category_serialize {
		my $this = shift;
		my $categories = $this->category;
		my $cats='';
		foreach my $cat (@$categories){
			$cats.= qq[<media:category scheme="$cat->{scheme}">$cat->{label}</media:category>];
		}
		return $cats;
	}



	sub description {
		my $this = shift;
		if(@_==1){
			return $this->{_feed}->{'media$group'}->{'media$description'}->{'$t'}=$_[0];
		}
		$this->{_feed}->{'media$group'}->{'media$description'}->{'$t'};
	}

	sub keywords {
		my $this = shift;
		if(@_==1){
			$this->{_feed}->{'media$group'}->{'media$keywords'}->{'$t'}=$_[0];
		}
		$this->{_feed}->{'media$group'}->{'media$keywords'}->{'$t'};
	}

	sub is_listing_allowed {
		my $this = shift;
		if(@_==1){
			$this->access_controll->[0]->{permission}=$_[0];
		}
		return ($this->access_controll->[0]->{permission} eq 'allowed')?1:0;
	}

	sub is_comment_allowed {
		my $this = shift;
		if(@_==1){
			$this->access_controll->[1]->{permission}=$_[0];
		}
		return ($this->access_controll->[1]->{permission} eq 'allowed')?1:0;
	}

	sub is_comment_vote_allowed {
		my $this = shift;
		if(@_==1){
			$this->access_controll->[2]->{permission}=$_[0];
		}
		return ($this->access_controll->[2]->{permission} eq 'allowed')?1:0;
	}

	sub is_video_response_allowed {
		my $this = shift;
		if(@_==1){
			$this->access_controll->[3]->{permission}=$_[0];
		}
		return ($this->access_controll->[3]->{permission} eq 'allowed')?1:0;
	}

	sub is_rating_allowed {
		my $this = shift;
		if(@_==1){
			$this->access_controll->[4]->{permission}=$_[0];
		}
		return ($this->access_controll->[4]->{permission} eq 'allowed')?1:0;
	}

	sub is_embedding_allowed {
		my $this = shift;
		if(@_==1){
			$this->access_controll->[5]->{permission}=$_[0];
		}
		return ($this->access_controll->[5]->{permission} eq 'allowed')?1:0;
	}

	sub is_syndication_allowed {
		my $this = shift;
		if(@_==1){
			$this->access_controll->[6]->{permission}=$_[0];
		}
		return ($this->access_controll->[6]->{permission} eq 'allowed')?1:0;
	}


	sub private {
		my $this = shift;
		if(@_==1){
			$this->{_feed}->{'media$group'}->{'yt$private'}=$_[0];
		}
		return ($this->{_feed}->{'media$group'}->{'yt$private'})?1:0;
	}

	sub delete {
		my $this = shift;
		my	$uri = 'http://gdata.youtube.com/feeds/api/users/default/uploads/'.$this->video_id;
		$this->{_auth}->delete($uri,0);
	}


	sub _serialize {
		my ($this) = @_;

		my $title       = $this->title;
		my $description = $this->description;
		my $keywords    = $this->keywords;
		my $isPrivate   = $this->private==1?'<yt:private/>':'';

		my $accessControll=($this->access_controll) ? $this->_access_controll_serialize():"";
		my $category      =($this->category) ? $this->_category_serialize():"";

		my $content = <<XML;
<media:group>
 <media:title type="plain">$title</media:title>
 <media:description type="plain">$description</media:description>
 $category
 <media:keywords>$keywords</media:keywords>
$isPrivate
</media:group>
$accessControll
XML

		return $content;
	}

	sub save {
		my ($this) = @_;

		my $content = $this->_serialize();

		if($this->video_id){
			$this->{_auth}->clean_namespace();
			$this->{_auth}->add_namespace('xmlns:media="http://search.yahoo.com/mrss/"');
			$this->{_auth}->add_namespace('xmlns:yt="http://gdata.youtube.com/schemas/2007"');
			$this->{_auth}->update('http://gdata.youtube.com/feeds/api/users/default/uploads/'.$this->video_id,$content);
		}
		else {
			if($this->upload_mode eq DIRECT_UPLOADING){
   	   			$this->direct_uploading('http://uploads.gdata.youtube.com/feeds/api/users/default/uploads/',$content);
			}
			else {
   	   			return $this->browser_uploading('http://uploads.gdata.youtube.com/feeds/api/users/default/uploads/',$content);
			}
		}
	}

#video upload

	sub filename {
		my $this = shift;
		if(@_==1){
			return $this->{_filename}=$_[0];
		}
		$this->{_filename};
	}

	sub _binary_data {
		my $this = shift;

		if(@_==1){
			my $fh=$_[0];
			binmode($fh);
			my $data = '';
			while (read $fh, my $buf, 4) {
  				$data .= $buf;
			}
			close $fh;
			return $this->{_binary_data}=$data;
		}
		$this->{_binary_data};
	}

	sub upload_mode {
		my $this = shift;
		if(@_==1){
			$this->{_UPLOAD_MODE}=shift;
			$this->{_UPLOAD_MODE}=undef if($this->{_UPLOAD_MODE} ne DIRECT_UPLOAD || $this->{_UPLOAD_MODE} ne BROWSER_UPLOAD);
		}
		$this->{_UPLOAD_MODE}=BROWSER_UPLOAD if(!$this->{_UPLOAD_MODE});
		$this->{_UPLOAD_MODE};
	}

	sub browser_uploading {
		my ($this,$uri,$content) = @_;
   	    my $res  = $this->{_auth}->insert('http://gdata.youtube.com/action/GetUploadToken',$content);

		my $response = $res->content();
		my ($url,$token) = $response=~m/<url>(.+?)<\/url><token>(.+?)<\/token>/;
		return ($url,$token);
	}


	sub direct_uploading {
		my ($this,$uri,$content) = @_;

		my $binary = $this->_binary_data;

		my $content2= <<XML;

--f93dcbA3
Content-Type: application/atom+xml; charset=UTF-8

<?xml version="1.0"?>
<entry xmlns="http://www.w3.org/2005/Atom"
  xmlns:media="http://search.yahoo.com/mrss/"
  xmlns:yt="http://gdata.youtube.com/schemas/2007">
XML

		$content2.=$content.'</entry>';

			$content2.=<<XML;

--f93dcbA3
Content-Type: video/quicktime
Content-Transfer-Encoding: binary

$binary

--f93dcbA3--
XML

		my $req  = HTTP::Request->new(POST => $uri);

		if($this->{_auth}->{Auth}){
  		   	$this->{_auth}->{Auth}->set_authorization_headers($this,$req);
  		   	$this->{_auth}->{Auth}->set_service_headers($this,$req);
		}
  		$req->header('GData-Version' => $this->{_auth}->query->{v});
		$req->header('Slug'=> $this->filename);
  	    $req->content_type('multipart/related; boundary="f93dcbA3"');
  		$req->header('Content-Length'=> length($content2));
  		$req->header('Connection' => 'close');
    	$req->content($content2);

    	my $res = $this->{_auth}->{ua}->request($req);
    	if ($res->is_success) {
			return $this;
		}
		else {
			print $res->content;
		}

		return $this;	
	}


"The earth is blue like an orange.";

__END__


=pod

=head1 NAME

WebService::GData::YouTube::Feed::Video - a Video YouTube contents(read/write) for data API v2.

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

inherits from WebService::GData::Feed::Entry;

This package represents a Youtube Video. If you are logged in you can edit existing video metadata,create new metadata, upload videos.

Most of the time you will not instantiate this class directly but use some of the helpers in the WebService::GData::YouTube class.


=head1 CONSTRUCTOR


=head2 new

=over

inherited from WebService::GData::Feed::Entry. Accepts the same parameters: 

- a video entry feed in json format

- an optional authorization object (ClientLogin only implemented for now).

If authorization object is set, it will allow you to access private contents and insert/edit/delete/upload videos.

=head1 GET METHODS

=head2 view_count
=head2 favorite_count
=head2 media_player
=head2 aspect_ratio
=head2 duration
=head2 content
=head2 comments
=head2 thumbnails
=head2 uploaded
=head2 etag
=head2 appcontrol_state

=head1 SET/GET METHODS

=head2 video_id
=head2 access_controll
=head2 category
=head2 description
=head2 keywords
=head2 is_listing_allowed
=head2 is_comment_allowed
=head2 is_comment_vote_allowed
=head2 is_video_response_allowed
=head2 is_rating_allowed
=head2 is_embedding_allowed
=head2 is_syndication_allowed
=head2 private
=head2 delete
=head2 save
=head2 filename
=head2 upload_mode


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