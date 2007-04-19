use ExtUtils::MakeMaker;
WriteMakefile(
	NAME => 'Dyer::Autosort',
	VERSION_FROM => 'lib/Dyer/Autosort.pm',
	EXE_FILES => ['bin/autosort','bin/dyer-autosort'],
);
