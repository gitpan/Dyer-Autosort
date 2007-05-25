use ExtUtils::MakeMaker;
WriteMakefile(
	NAME => 'Dyer::Autosort',
	VERSION_FROM => 'lib/Dyer/Autosort.pm',
	EXE_FILES => ['bin/autosort'],
	PREREQ_PM => {
		'Smart::Comments' => 0,
		'File::PathInfo::Ext' => '1.13',
		'IO::Dir' => 0,
		'File::Copy' => 0,
		'File::Find::Rule' => 0,
		'File::Path' => 0,
		'YAML' => 0,
		'Carp' => 0,
	}
);
