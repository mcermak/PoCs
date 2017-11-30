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

	!! map $self->input_condition->list_items( defined $_ ? (color => $_) : () ), ( @{$self->colors} || undef );
}

sub bring_items {
	my ($self) = @_;

	return unless $self->input_condition;

	my @item = map $self->input_condition->list_items( defined $_ ? (color => $_) : () ), ( @{$self->colors} || undef );

	Mojo::Exception->throw("Event: ".$self->input_condition->name." is not prepared.")
		unless scalar @item;

	my $item = $self->input_condition->get_item( item_id => $item[0] );
	$self->input_condition->delete_item( item_id => $item[0] );

	return $item;
}

1;
