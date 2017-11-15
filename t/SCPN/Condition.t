use Test::Spec;
use Test::Exception;

use strict;
use warnings;

use SCPN::Condition;

describe 'SCPN::Condition' => sub {
	describe 'method' => sub {
		my $condition;
		before 'each' => sub {
			$condition = SCPN::Condition->new({
				name => 'test'
			});
		};
		it 'add_item' => sub {
			ok( $condition->add_item(
				item_id => 'pid',
				item => '1'
			));
		};
		it 'add_item with used names' => sub {
			$condition->add_item(
				item_id => 'pid',
				item => '13'
			);
			throws_ok{
				$condition->add_item(
					item_id => 'pid',
					item => '1'
				)
			} qr/already used/;
		};
		it 'add_item with used names and colors' => sub {
			$condition->add_item(
				item_id => 'pid',
				item => '13',
				color => 'red'
			);
			ok( $condition->add_item(
				item_id => 'pid',
				item => '1',
				color => 'blue'
			));
		};
		it 'list_items should return items_ids' => sub {
			$condition->add_item(
				item_id => 'pid1',
				item => '13',
			);
			$condition->add_item(
				item_id => 'pid2',
				item => '1',
			);
			is_deeply(
				[ sort $condition->list_items ],
				[ qw/pid1 pid2/ ]
			);
		};
		it 'list colors' => sub {
			$condition->add_item(
				item_id => 'pid1',
				item => '13',
				color => 'red',
			);
			$condition->add_item(
				item_id => 'pid2',
				item => '1',
				color => 'blue'
			);
			is_deeply(
				[ sort $condition->list_colors ],
				[ qw/blue red/ ]
			);

		};
		it 'list_items should return blue colored items_ids' => sub {
			$condition->add_item(
				item_id => 'pid1',
				item => '13',
			);
			$condition->add_item(
				item_id => 'pid2',
				item => '1',
				color => 'blue'
			);
			is_deeply(
				[ sort $condition->list_items( color => 'blue' ) ],
				[ qw/pid2/ ]
			);
		};
		it 'get_item should return correct item' => sub {
			$condition->add_item(
				item_id => 'pid1',
				item => '13',
			);
			$condition->add_item(
				item_id => 'pid2',
				item => '1',
			);
			is_deeply(
				[ $condition->get_item( item_id => 'pid2' ) ],
				[ qw/1/ ]
			);
		};
		it 'get_item should return correct colored item' => sub {
			$condition->add_item(
				item_id => 'pid1',
				item => '13',
				color => 'blue'
			);
			$condition->add_item(
				item_id => 'pid2',
				item => '1',
				color => 'black'
			);
			is_deeply(
				[ $condition->get_item( item_id => 'pid1', color => 'blue' ) ],
				[ qw/13/ ]
			);
		};
		it 'delete_item item' => sub {
			$condition->add_item(
				item_id => 'pid1',
				item => '13',
			);
			$condition->add_item(
				item_id => 'pid2',
				item => '1',
			);
			$condition->delete_item(
				item_id => 'pid1',
			);
			is_deeply(
				[ $condition->list_items ],
				[ qw/pid2/ ]
			);
		};
	};
};

runtests;
