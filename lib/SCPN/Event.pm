package SCPN::Event;

use Moo;
use Mojo::Exception;
use namespace::clean;

has name => (
	is => 'ro',
	required => '1'
);
has input_edges => ( 
	is => 'rw',
	isa => sub {
		return unless defined $_[0];
		Mojo::Exception->throw("Event: input edges constraint fails.")
			if not ref $_[0] eq 'ARRAY' or grep(not $_->isa('SCPN::Edge::CE'),@$_[0]);
	},
	default => sub {[]}
);
has output_edges => (
	is => 'rw',
	isa => sub {
		return unless defined $_[0];
		Mojo::Exception->throw("Event: output edges constraint fails.")
			if not ref $_[0] eq 'ARRAY' or grep(not $_->isa('SCPN::Edge::EC'),@$_[0]);
	},
	default => sub {[]}
);
has values => (
	is => 'rw',
	default => sub{[]}
);

sub consume_input {
	my ($self) = @_;
	my @edges = @{$self->input_edges};

	my @source_structures;

	foreach my $e (@edges) {
		return 0 unless $e->prepared_items;
		push @source_structures, $e->bring_items;
	}
	$self->{values} = \@source_structures;

	return 1;
}

sub do {
	my ($self) = @_;

	return @{$self->{values}};
}

sub fire {
	my ($self) = @_;
	return 0 unless $self->consume_input;
	my ($first_val) = $self->do;

	$self->send_result( $first_val || "bullet" );
	
	return 1;
}

sub send_result {
	my ($self, $result) = @_;

	$_->send( $result ) foreach @{$self->{output_edges}};

	return 1;
}

1;
