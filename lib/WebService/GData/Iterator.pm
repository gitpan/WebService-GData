package WebService::GData::Iterator;

sub TIEARRAY {
    my $class = shift;
    
    my $this  =  bless {
        ARRAY    => shift || [],
        MODIFIER => shift
    }, $class;
    $this->pointer=0;
    
    return $this;
 }
 
sub FETCH {
    my ($this,$index) = @_;
    $this->pointer=$index;
    return $this->{MODIFIER}->next($this,$index);
}
 
sub pointer:lvalue {
     $this->{pointer};
}


sub STORE {
    my $this = shift;
    my( $index, $value ) = @_;
    
    ($index,$value)=$this->{MODIFIER}->set($this,$index,$value);
    
    $this->{ARRAY}->[$index] = $value;
}
 
sub FETCHSIZE {
    my $this = shift;

    if($this->pointer>=$this->total || $this->pointer<0){

        $this->pointer=0;
        return 0;
    }
    return $this->total;
}
 
sub total {
    my $this = shift;
    return scalar (@{$this->{ARRAY}});
}
 
sub STORESIZE {

}
sub EXTEND {

}
 
sub EXISTS {
    my ($this,$index) = @_;
    if(! defined $this->{ARRAY}->[$index]){
        $this->pointer=0;
        return 0;
    }
    return 1;
}
 
sub DELETE {
     my ($this,$index) = @_;
     return $this->STORE( $index, '' );
}
 
sub CLEAR {
     my $this = shift;
 #    return $this->{ARRAY} = [];
}
 
####ARRAY LIKE BEHAVIOR####
sub PUSH {
     my $this = shift;
     my @list = @_;
     my $last = $this->total();
     $this->STORE( $last + $_, $list[$_] ) foreach 0 .. $#list;
     return $this->total();
}
 
sub POP {
     my $this = shift;
     return pop @{$this->{ARRAY}};
}
 
sub SHIFT {
     my $this = shift;
     return shift @{$this->{ARRAY}};
} 

sub UNSHIFT {
    my $this = shift;
    my @list = @_;
    my $size = scalar @list;
   
    @{$this->{ARRAY}}[ $size .. $#{$this->{ARRAY}} + $size ]
    = @{$this->{ARRAY}};
   
    $this->STORE( $_, $list[$_] ) foreach 0 .. $#list;
}

sub SPLICE {
     my $this = shift;
     my $offset = shift || 0;
     my $length = shift || $this->FETCHSIZE() - $offset;
     my @list = ();
     if ( @_ ) {
         tie @list, ref $this;
         @list = @_;
     }
     return splice @{$this->{ARRAY}}, $offset, $length, @list;
}
 
'The earth is blue like an orange.';
