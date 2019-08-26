use strict;
use warnings;

use Module::Build;

my $build = Module::Build->new(
	module_name => 'SCPN',
	license => 'perl',
	dist_abstract => 'SCPN',
	dist_author => 'Martin Cermak <martin.cermak2@gooddata.com>',
	dist_version => '0.01',
	requires => {
		'perl' => 5.010,
		'File::Slurp' => 0,
		'JSON::XS' => 0,
		'Moo' => 0,
		'Mojo::Exception' => 0,
	},
	test_requires => {
		'Test::Exception' => 0,
		'Test::Spec' => 0,
	},
	configure_requires => {
		'Module::Build' => 0.42,
	},
	meta_merge => {
		resources => {
			repository => 'https://github.com/gooddata/mce-personal',
		},
	},
	recursive_test_files => 1,
);

$build->create_build_script;
