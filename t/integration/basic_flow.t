use Test::Spec;
use Test::Exception;

use strict;
use warnings;

use SCPN::Condition;
use SCPN::Event;
use SCPN::Edge::CE;
use SCPN::Edge::EC;

describe 'Petri Net basic flow' => sub {
	describe 'Condition->Event should' => sub {
		it 'not fire when condition is not fulfilled' => sub {
			my $condition = SCPN::Condition->new(
				name => 'intput_condition'
			);

			my $edge = SCPN::Edge::CE->new(
				input_condition => $condition
			);

			my $event = SCPN::Event->new(
				name => 'event'
			);

			$event->input_edges([ $edge ]);
			is( $event->fire, 0);
		};
		it 'fire when condition is saitisfied' => sub {
			my $condition = SCPN::Condition->new(
				name => 'intput_condition'
			);
			$condition->add_item(
				item_id => 'item_1',
				item => 'bullet'
			);
			my $edge = SCPN::Edge::CE->new(
				input_condition => $condition
			);

			my $event = SCPN::Event->new(
				name => 'event'
			);

			$event->input_edges([ $edge ]);
			is( $event->fire, 1);
		};
		it 'not fire when one from two conditions is not fulfilled' => sub {
			my $condition = SCPN::Condition->new(
				name => 'intput_condition'
			);

			$condition->add_item(
				item_id => 'item_1',
				item => 'bullet'
			);

			my $edge = SCPN::Edge::CE->new(
				input_condition => $condition
			);

			my $condition_2 = SCPN::Condition->new(
				name => 'intput_condition'
			);

			my $edge_2 = SCPN::Edge::CE->new(
				input_condition => $condition_2
			);

			my $event = SCPN::Event->new(
				name => 'event'
			);

			$event->input_edges([ $edge, $edge_2 ]);
			is( $event->fire, 0);
		};
		it 'fire when both conditions are satisfied' => sub {
			my $condition = SCPN::Condition->new(
				name => 'intput_condition'
			);

			$condition->add_item(
				item_id => 'item_1',
				item => 'bullet'
			);

			my $edge = SCPN::Edge::CE->new(
				input_condition => $condition
			);

			my $condition_2 = SCPN::Condition->new(
				name => 'intput_condition'
			);

			$condition_2->add_item(
				item_id => 'item_1',
				item => 'bullet'
			);

			my $edge_2 = SCPN::Edge::CE->new(
				input_condition => $condition_2
			);

			my $event = SCPN::Event->new(
				name => 'event'
			);

			$event->input_edges([ $edge, $edge_2 ]);
			is( $event->fire, 1);
		};
	};
	describe 'Event->Condition should' => sub {
		it 'fire even without input conditions' => sub {
			my $condition = SCPN::Condition->new(
				name => 'output_condition'
			);

			my $edge = SCPN::Edge::EC->new(
				output_condition => $condition
			);

			my $event = SCPN::Event->new(
				name => 'event'
			);

			$event->output_edges([ $edge ]);
			is( $event->fire, 1);
			is( scalar $condition->list_items, 1, 'output condition should has bullet' );
		};
	};
	describe 'Condition->Event->Condition should' => sub {
		it 'fire and move bullets' => sub {
			my $output_condition = SCPN::Condition->new(
				name => 'output_condition'
			);
			my $output_edge_1 = SCPN::Edge::EC->new(
				output_condition => $output_condition
			);
			my $output_edge_2 = SCPN::Edge::EC->new(
				output_condition => $output_condition
			);

			my $input_condition = SCPN::Condition->new(
				name => 'input_condition'
			);
			my $input_edge = SCPN::Edge::CE->new(
				input_condition => $input_condition
			);
			$input_condition->add_item(
				item_id => 'item_1',
				item => 'item_1_bullet'
			);

			my $event = SCPN::Event->new(
				name => 'event'
			);
			$event->input_edges([ $input_edge ]);
			$event->output_edges([ $output_edge_1, $output_edge_2 ]);

			is( $event->fire, 1);
			is( scalar $output_condition->list_items, 2, 'output condition should has two bullets' );
			my ($item_1_id, $item_2_id) = $output_condition->list_items;

			is_deeply(
				[
					$output_condition->get_item( item_id => $item_1_id),
					$output_condition->get_item( item_id => $item_2_id)
				],
				[ "item_1_bullet", "item_1_bullet" ],
				"should produce two copies of input bullet"
			);
		};
	};
};

runtests;
