use Test::Spec;
use Test::Exception;

use strict;
use warnings;

use SCPN::Edge::EC;

describe 'SCPN::Edge::EC' => sub {
	describe 'method' => sub {
		my $edge;
		before each => sub {
			$edge = SCPN::Edge::EC->new();
		};
		it "should send nothing" => sub {
			is( $edge->send("bullet"), undef);
		};
		#TODO
		it "should return one structure" => sub {
			my $condition = bless {}, "SCPN::Condition";
			SCPN::Condition->expects("add_item")->once->returns( sub {
				my ($self, %item) = @_;
				delete $item{item_id};
				is_deeply( \%item, { item => "bullet"}, "item should return item bullet" );
				return 1
			});
			$edge->output_condition($condition);
			is( $edge->send("bullet"), 1 );
		};
	};
};

runtests;
