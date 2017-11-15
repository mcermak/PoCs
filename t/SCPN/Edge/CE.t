use Test::Spec;
use Test::Exception;

use strict;
use warnings;

use SCPN::Edge::CE;

describe 'SCPN::Edge::CE' => sub {
	describe 'method' => sub {
		my $edge;
		it 'should throw exception when not input condition'=> sub {
			throws_ok{ SCPN::Edge::CE->new() } qr/input_condition/;
		};
		it "should return one structure" => sub {
			my $condition = bless {}, "SCPN::Condition";
			SCPN::Condition->expects("list_items")->once->returns( ("A", "B") );
			SCPN::Condition->expects("get_item")->once->returns( sub {
				my ($self, %item) = @_;
				my $item_id = $item{item_id};
				is( $item_id eq "A" || $item_id eq "B", 1, "item should be A or B" );
				return "C"
			});
			SCPN::Condition->expects("delete_item")->once;
			$edge = SCPN::Edge::CE->new( input_condition => $condition );
			is( $edge->bring_items, "C" );
		};
		it "should return no result when no bullet in condition" => sub {
			my $condition = bless {}, "SCPN::Condition";
			SCPN::Condition->expects("list_items")->once->returns();
			SCPN::Condition->expects("name")->once->returns("condition_a");
			$edge = SCPN::Edge::CE->new( input_condition => $condition );
			throws_ok {  $edge->bring_items } qr/condition_a/;
		};
		it "should return no result when no bullet in condition" => sub {
			my $condition = bless {}, "SCPN::Condition";
			SCPN::Condition->expects("list_items")->once->returns("blah");
			SCPN::Condition->expects("get_item")->once->returns("blahblah");
			SCPN::Condition->expects("delete_item")->once->returns();
			$edge = SCPN::Edge::CE->new( input_condition => $condition );
			is( $edge->bring_items, "blahblah" );
		};
	};
};

runtests;
	
