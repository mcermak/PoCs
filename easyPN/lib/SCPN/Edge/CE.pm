package SCPN::Edge::CE;

use Moo;
use namespace::clean;
use Mojo::Exception;

has input_condition => (
	is => 'rw',
	isa => sub {
		return unless defined $_[0];

		Mojo::Exception->throw("CE: input_contion is not SCPN::Condition.")
			unless $_[0]->isa("SCPN::Condition")
	},
	required => 1,
);
has colors => (
	is => 'rw',
	isa => sub {
		return unless defined $_[0];
		Mojo::Exception->throw("CE: colors constraint fails.")
			if ref $_[0] ne 'ARRAY';
	},
	default => sub {[]},
);
has width => (
	is => 'rw',
	default => 1
);

sub prepared_items {
	my ($self, $count) = @_;
	$count //= 1;

	my @items;
	foreach my $color (@{$self->colors}) {
		push @items, $self->input_condition->list_items('color' => $color);
	}
	return scalar @items >= $count if @{$self->colors};
	return scalar $self->input_condition->list_items >= $count;
}

sub bring_items {
	my ($self, $count) = @_;

	return unless $self->input_condition;
	$count //= 1;

	my @items;
	if (@{$self->colors}) {
		foreach my $color (@{$self->colors}) {
			push @items, map { [$_, $color] } $self->input_condition->list_items('color' => $color);
		}
	} else {
		push @items, map { [$_, 'default'] } $self->input_condition->list_items;
	}

	Mojo::Exception->throw("Event: ".$self->input_condition->name." is not prepared.")
		unless scalar @items;

	my @r_items;
	foreach (0..$count-1) {
		push @r_items, $self->input_condition->get_item(
			item_id => $items[$_][0],
			color => $items[$_][1],
		 );
		$self->input_condition->delete_item(
			item_id => $items[$_][0],
			color => $items[$_][1],
		);
	}

	return @r_items;
}

1;
