use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Scaffold',
    AUTHOR              => 'Kevin L. Esteb <kesteb(at)wsipc.org>',
    VERSION_FROM        => 'lib/Scaffold.pm',
    ABSTRACT_FROM       => 'lib/Scaffold.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Scaffold-*' },
);
