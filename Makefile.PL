use 5.008008;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'WebService::GData',
    VERSION_FROM      => 'lib/WebService/GData.pm', # finds $VERSION
    PREREQ_PM         => {
		'LWP'=>0,
		'JSON'=>2
	}, # e.g., Module::Name => 1.1
	BUILD_REQUIRES =>{
	  'Test::Mock::LWP' =>0.05,
	   'Test::More'=>0,
	},
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/WebService/GData.pm', # retrieve abstract from module
       AUTHOR         => 'shirirules<shirirulestheworld@gmail.com>') : ()),
);
