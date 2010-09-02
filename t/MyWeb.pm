package MyWeb;
use WebService::GData;
use base 'WebService::GData';

	#extend __init method
	sub __init {
		my $this = shift;
		$this->SUPER::__init(@_);
		$this->{extra}=1;
	}

WebService::GData::install_in_package(
	[qw(firstname lastname)],
	sub {
		my $funcname = shift;
		return sub {
			my $this = shift;
			if(@_){
				$this->{$funcname}=$_[0];
			}
			return $this->{$funcname};
		}
	}
);

1;
