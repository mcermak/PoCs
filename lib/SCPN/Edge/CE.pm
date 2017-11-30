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
	default => sub {[]}
);

sub prepared_items {
	my ($self) = @_;

	my @items;
	foreach my $color (@{$self->colors}) {
		push @items, $self->input_condition->list_items('color' => $color);
	}
	return !! @items if @{$self->colors};
	return !! $self->input_condition->list_items;
}

sub bring_items {
	my ($self) = @_;

	return unless $self->input_condition;

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

	my $item = $self->input_condition->get_item(
		item_id => $items[0][0],
		color => $items[0][1],
	 );
	$self->input_condition->delete_item(
		item_id => $items[0][0],
		color => $items[0][1],
	);

	return $item;
}

1;
