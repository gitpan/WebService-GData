package WebService::GData::YouTube::Constants;
our $VERSION  = 0.01_01;
use constant {

	MOBILE_H263=>1,
	H263	   =>1,
	MPEG4      =>6,
	MOBILE_MPEG4=>6,
	EMBEDDABLE=>5,

	TODAY => 'today',
	WEEK  => 'this_week',
	MONTH => 'this_month',
	ALL_TIME=>'all_time',

	NONE	=>'none',
	MODERATE=>'moderate',
	STRICT  =>'strict',
	L0		=>'none',
	L1		=>'moderate',
	L2		=>'strict',

	RELEVANCE=>'relevance',
	PUBLISHED=>'published',
	VIEW_COUNT=>'viewCount',
	RATING	=>'rating',
	POSITION=>'position',
	COMMENT_COUNT=>'commentCount',
	DURATION=>'duration'
};

my  @format = qw(MOBILE_H263 H263 MPEG4 MOBILE_MPEG4 EMBEDDABLE);
my  @time   = qw(TODAY WEEK MONTH ALL_TIME);
my  @safe   = qw(NONE MODERATE STRICT L0 L1 L2);
my  @order   = qw(RELEVANCE PUBLISHED VIEW_COUNT RATING POSITION COMMENT_COUNT DURATION);

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK   = (@format,@time,@safe,@order);
our %EXPORT_TAGS = (format => [@format],time=>[@time],safe=>[@safe],order=>[@order]);

"The Earth is blue like an orange.";