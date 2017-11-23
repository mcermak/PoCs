use Test::Spec;

use strict;
use warnings;

use SCPN::Engine::Simple;

describe 'SCPN::Engine::Simple' => sub {
	describe 'run' => sub {
		it 'should make three steps' => sub {
			my $engine = SCPN::Engine::Simple->new(
				schema_fpath => 'engine_simple.json',
				verbose => 1
			);
			$engine->run(5);
			my $c1 = $engine->petri_net->conditions->{moved_1}->list_items;
			my $c2 = $engine->petri_net->conditions->{moved_2}->list_items;

			is($c1 + 2 * $c2, 5, "should make five steps");
		};
	};
};

runtests;
