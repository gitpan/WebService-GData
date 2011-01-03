package WebService::GData::YouTube::Feed::PlaylistLink;
use base 'WebService::GData::Feed::Entry';
our $VERSION  = 0.01_01;
#####READ##############

sub __init {
    my ($this,$feed,$req) = @_;
    
    if(ref($feed) eq 'HASH'){
        $this->SUPER::__init($feed,$req);
    }
    else {

        $this->SUPER::__init({},$feed);        
    }   
}

	sub count_hint {
		my $this = shift;
		$this->{_feed}->{'yt$countHint'}->{'$t'};
	}

	sub playlist_id {
		my $this = shift;
		if(@_==1){
			$this->{_feed}->{'yt$playlistId'}->{'$t'}=$_[0];
		}
		$this->{_feed}->{'yt$playlistId'}->{'$t'};
	}

	sub private {
		my $this = shift;
		if(@_==1){
			$this->{_feed}->{'yt$private'}=$_[0];
		}
		return ($this->{_feed}->{'yt$private'})?1:0;
	}

	sub keywords {
		my ($this,$entry) = @_;

		if($entry) {
			$this->{_feed}->{category}=[{scheme=>'http://schemas.google.com/g/2005#kind',term=>'http://gdata.youtube.com/schemas/2007#playlistLink'}];
			my @entries = split ',',$entry;
			my $i=1;
			foreach my $entry (@entries){
				$this->{_feed}->{category}->[$i]= {scheme=>'http://gdata.youtube.com/schemas/2007/tags.cat',term=>$entry};
				$i++;
			}
			return;
		}

		my $categories = $this->category;

		my @keywords=();
		foreach my $category (@$categories){
			if($category->{scheme}=~m/tags/){
				push @keywords,$category->{term};	
			}
		}
		return join ',',@keywords;
	}



#####WRITE###########

	sub get_videos {
		my $this = shift;

		my $res = $this->{_dbh}->get($this->{_feed}->{'content'}->{src} || 'http://gdata.youtube.com/feeds/api/playlists/'.$this->playlistId);

		$this->{videosInPlaylist} = new WebService::GData::YouTube::Feed($res,$this->{_request})->entry;
		return $this->{videosInPlaylist};
	}


	sub add {
		my ($this,%params) = @_;
		$this->edit(%params);
	}

	sub add_video {
		my ($this,%params) = @_;
		$this->{_request}->clean_namespaces();
		$this->{_request}->add_namespaces('xmlns:yt="http://gdata.youtube.com/schemas/2007"');
   	   	$this->{_request}->insert('http://gdata.youtube.com/feeds/api/playlists/'.$this->playlistId,"<id>$params{videoId}</id>");
	}

	sub delete {
		my $this = shift;
		my	$uri = 'http://gdata.youtube.com/feeds/api/users/'.$this->{_dbh}->{channel}.'/playlists/'.$this->playlistId;
		$this->{_request}->delete($uri,0);
	}

	sub delete_video {
		my ($this,%params) = @_;

		if($params{videoId}) {
			$params{playListVideoId}=$this->_find_playlist_video_id($params{videoId});
		}
		$this ->{_request}->delete('http://gdata.youtube.com/feeds/api/playlists/'.$this->playlistId.'/'.$params{playListVideoId},0);

	}

	sub set_video_position {
		my ($this,%params) = @_;

		if($params{videoId}) {
			$params{playListVideoId}=$this->_find_playlist_video_id($params{videoId});
		}
		$this->{_request}->clean_namespaces();
		$this->{_request}->add_namespaces('xmlns:yt="http://gdata.youtube.com/schemas/2007"');
		$this->{_request}->update('http://gdata.youtube.com/feeds/api/playlists/'.$this->playlistId.'/'.$params{playListVideoId},"<yt:position>$params{position}</yt:position>");

	}


	sub save {
		my $this = shift;

		my $isPrivate = $this->private==1?'<yt:private/>':'';
		my $title     = $this->title;	
		my $summary   = $this->summary;
		my $keywords  = $this->_keywords_serialize;	
		my $content = <<XML;
<title type="text">$title</title>
<summary>$summary</summary>
$isPrivate
$keywords
XML
		$this->{_request}->clean_namespaces();
		$this->{_request}->add_namespaces('xmlns:yt="http://gdata.youtube.com/schemas/2007"');

		if($this->playlistId){
			$this->{_request}->update('http://gdata.youtube.com/feeds/api/users/'.$this->{_dbh}->{channel}.'/playlists/'.$this->playlistId,$content);
		}
		else {
   	   		$this->{_request}->insert('http://gdata.youtube.com/feeds/api/users/default/playlists',$content);
		}

	}


##private###

	sub _find_playlist_video_id {
		my ($this,$videoid) = @_;

		my $id="";
		if(!$this->{videosInPlaylist}){
			$this->getVideos;
		}
		foreach my $vid (@{$this->{videosInPlaylist}}){
			if($vid->videoId eq $videoid){
				$id= (split(':',$vid->id))[-1];
			}
		}
		return $id;
	}

	sub _keywords_serialize {
		my $this = shift;
		my $categories = $this->category;
		my @keywords=();

		foreach my $category (@$categories){

			if($category->{scheme}=~m/tags/){
				push @keywords,qq[<category scheme='http://gdata.youtube.com/schemas/2007/tags.cat' term='$category->{term}'/>];
			}
		}
		return join '',@keywords;
	}

1;