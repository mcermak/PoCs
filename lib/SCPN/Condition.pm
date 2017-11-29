package SCPN::Condition;

use Moo;
use Mojo::Exception;
use namespace::clean;

has name => (
	is => 'ro',
	required => '1'
);
has capacity => (
	is => 'ro',
	default => sub{ return undef }
);
has multiset => (
	is => 'rw',
	default => sub { return {} }
);

sub add_item {
	my( $self, %params ) = @_;

	my ($color, $item, $item_id) = map $params{$_}, qw/color item item_id/;
	$color //= 'default';

	Mojo::Exception->throw("Condition: $self->{name}, item_name '$item_id' already used.")
		if($self->{multiset}{$color}{$item_id});

	$self->{multiset}{$color}{$item_id} = $item;

	return $item;
}

sub list_items {
	my( $self, %params ) = @_;

	my ($color) = map $params{$_}, qw/color/;
	$color //= 'default';

	return keys %{$self->{multiset}{$color}};
}

sub list_colors {
	my( $self ) = @_;

	return keys %{$self->{multiset}};
}

sub get_item {
	my( $self, %params ) = @_;

	my ($color, $item_id) = map $params{$_}, qw/color item_id/;
	$color //= 'default';
	
	return $self->{multiset}{$color}{$item_id};
}

sub delete_item {
	my( $self, %params ) = @_;

	my ($color, $item_id) = map $params{$_}, qw/color item_id/;
	$color //= 'default';
	
	delete $self->{multiset}{$color}{$item_id};
	delete $self->{multiset}{$color} unless $self->{multiset}{$color};

	return 1;
}


1;
