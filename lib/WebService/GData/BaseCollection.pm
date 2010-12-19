package WebService::GData::BaseCollection;

our $VERSION =0.01_02;
use WebService::GData::Iterator;
use base 'WebService::GData';

use overload '@{}'=>'__array',fallback=>1;

sub __to_string { my $this = shift;$this->{array}; };

sub __init {
	my ($this,$array,$onset,$onget,@array) = @_;

	tie @array,'WebService::GData::Iterator',$array,$this;
	$this->{array}=$array || \@array;
	$this->{onset}=$onset;
	$this->{onget}=$onget;

}

sub onset { return shift()->{onset} }
sub onget { return shift()->{onget} }

sub set {
	my ($this,$iterator,$index,$val) = @_;

	if(my $code = $this->onset){
	    my $ret = $code->($val);
	    return ($index,$ret);
	}
    return ($index,$val);
}

sub __array {
	my $this = shift;
	$this->{array};
}

sub row {
	my ($this,$iterator)=@_;
	return undef if($iterator->pointer >= $iterator->total);
	return $iterator->{ARRAY}->[$iterator->pointer];
}

sub next {
 	my ($this,$iterator) = @_;

	my $elm = $this->row($iterator);
	if(my $code = $this->onget){
	   $elm = $code->($elm);
	   $iterator->{ARRAY}->[$iterator->pointer]=$elm;
	}

	return $elm;
 }
 



'The earth is blue like an orange.';
