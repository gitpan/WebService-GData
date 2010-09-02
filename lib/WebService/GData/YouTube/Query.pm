package WebService::GData::YouTube::Query;
use base WebService::GData::Query;
our $VERSION  = 0.01_01;
	sub key {
		my ($this,$key)=@_;
		return $this->_set_query('key',$key);
	}

	sub caption {
		my ($this)=@_;
		return $this->_set_query('caption',undef);
	}

	sub uploader {
		my ($this,$uploader)=@_;
		return $this->_set_query('uploader',$uploader);
	}

	sub format {
		my ($this,$format)=@_;
		return $this->_set_query('format',$format);
	}
	
	sub time {
		my ($this,$val)=@_;
		return $this->_set_query('time',$val);
	}

	sub safeSearch {
		my ($this,$val)=@_;
		return $this->_set_query('safeSearch',$val);
	}

	sub restriction {
		my ($this,$val)=@_;
		return $this->_set_query('restriction',$val);
	}

	sub orderby {
		my ($this,$val)=@_;
		return $this->_set_query('orderby',$val);
	}

	sub lr {
		my ($this,$lr)=@_;
		return $this->_set_query('lr',$lr);		
	}

	sub location_radius {
		my ($this,$radius)=@_;
		return $this->_set_query('location-radius',$radius);	
	}

	sub location_plottable {
		my ($this,$location)=@_;
		return $this->_set_query('location',$location.'!');	
	}

	sub location {
		my ($this,$location)=@_;
		return $this->_set_query('location',$location);	
	}

	sub inline {
		my ($this,$inline)=@_;
		return $this->_set_query('inline',$inline);	
	}

1;