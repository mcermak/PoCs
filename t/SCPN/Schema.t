use Test::Spec;

use strict;
use warnings;

use SCPN::Schema;

describe 'SCPN::Schema' => sub {
	describe 'deserialize' => sub {
		it 'from json' => sub {
			my $schema = SCPN::Schema->new;
			my ($events, $conditions, $bullets) =
				$schema->build_schema_from_json("schema_basic.json");
			is($events,1, 'should create one event');
			is($conditions,2, 'should create two conditions');
			is($bullets,1,'should have one bullet from case');
			my $start_condition = $schema->conditions->{entry_point_condition};
			is(
				$start_condition->get_item(item_id => "init_config"),
				"bullet",
				"should load bullet correctly"
			);
			my $output_condition = $schema->conditions->{copy_resutls};
			is(
				scalar $output_condition->list_items,
				0,
				"output condition should be empty"
			);

			my $event = $schema->events->{copier};
			ok($event->fire, "can fire event after load");
			my @items = map $output_condition->get_item(item_id => $_),
				$output_condition->list_items;

			is_deeply(
				[ @items ],
				[ qw/bullet bullet bullet/ ],
				"should has 3 coppies of input bullets"
			);
		};
	};
};

runtests;
