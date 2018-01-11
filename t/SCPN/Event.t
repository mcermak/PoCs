use Test::Spec;

use strict;
use warnings;

use SCPN::Event;
use SCPN::Edge::CE;
use SCPN::Condition;

describe 'SCPN::Event' => sub {
	describe 'method' => sub {
		my $event;
		before 'each' => sub {
			$event = SCPN::Event->new({
				name => 'test_event'
			});
		};
		it 'fire' => sub {
			ok( $event->fire );
		};
		it 'fire with input edge' => sub {
			SCPN::Edge::CE->expects("prepared_items")->exactly(1)->returns(1);
			SCPN::Edge::CE->expects("bring_items")->once->returns("bullet");
			SCPN::Condition->expects("name")->exactly(2)->returns("name");
			SCPN::Edge::CE->expects("colors")->exactly(2)->returns(['color']);
			SCPN::Edge::CE->expects("input_condition")->exactly(2)->returns(bless{}, "SCPN::Condition");
			my $width = 1;
			SCPN::Edge::CE->expects("width")->exactly(6)->returns( sub{ my ($self, $value) = @_; $value ? $width = $value : return $width; } );
			my $ce1 = bless {}, "SCPN::Edge::CE";
			my $ce2 = bless {}, "SCPN::Edge::CE";
			$event->input_edges([$ce1, $ce2]);
			is( scalar @{$event->input_edges}, 1, 'only one input edge is set' );
			is( $event->input_edges->[0]->width, 2, 'width of the edge is 2' );
			ok( $event->fire );
		};
		it 'fire with output edges' => sub {
			SCPN::Edge::EC->expects("send")->exactly(2)->returns( sub { 
					my ( $self, $item ) = @_;
					is( $item, "bullet", "output should be ok" );
					return "bullet";
			});
			my $ce1 = bless {}, "SCPN::Edge::EC";
			my $ce2 = bless {}, "SCPN::Edge::EC";
			$event->output_edges([$ce1,$ce2]);
			ok( $event->fire );
		};
		it 'fire with input and output edges' => sub {
			SCPN::Edge::CE->expects("prepared_items")->once->returns(1);
			SCPN::Edge::CE->expects("bring_items")->once->returns("my_bullet");
			SCPN::Condition->expects("name")->once->returns("name");
			SCPN::Edge::CE->expects("colors")->once->returns(['color']);
			SCPN::Edge::CE->expects("input_condition")->once->returns(bless{}, "SCPN::Condition");
			my $ce = bless {}, "SCPN::Edge::CE";

			$event->input_edges([$ce]);

			SCPN::Edge::EC->expects("send")->exactly(2)->returns( sub { 
					my ( $self, $item ) = @_;
					is_deeply( $item, "my_bullet", "output should be ok" );
					return "bullet";
			});
			my $ec1 = bless {}, "SCPN::Edge::EC";
			my $ec2 = bless {}, "SCPN::Edge::EC";
			$event->output_edges([$ec1,$ec2]);
			ok( $event->fire );
		};
	};
};

runtests;
