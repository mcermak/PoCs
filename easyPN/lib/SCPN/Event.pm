package SCPN::Event;

use Moo;
use Mojo::Exception;
use namespace::clean;
use Storable qw/dclone/;

has name => (
	is => 'ro',
	required => '1'
);
has title => (
	is => 'rw',
	default => ''
);
has input_edges => ( 
	is => 'rw',
	isa => sub {
		return unless defined $_[0];
		Mojo::Exception->throw("Event: input edges constraint fails.")
			if (not ref $_[0] eq 'ARRAY') || (grep { not $_->isa('SCPN::Edge::CE')} @{$_[0]});
	},
	default => sub {[]},
	trigger => \&clean_input_edges
);
has output_edges => (
	is => 'rw',
	isa => sub {
		return unless defined $_[0];
		Mojo::Exception->throw("Event: output edges constraint fails.")
			if (not ref $_[0] eq 'ARRAY') || (grep { not $_->isa('SCPN::Edge::EC') } @{$_[0]});
	},
	default => sub {[]},
	trigger => \&clean_output_edges
);
has values => (
	is => 'rw',
	default => sub{[]}
);
has execution_closure => (
	is => 'ro',
	default => sub { \&propagate_first }
);

sub clean_input_edges {
	my ($self, $edges) = @_;
	my (%edges, @edges);

	foreach my $edge (@$edges) {
		my $chash = join('|', @{$edge->colors});
		my $name = $edge->input_condition->name;
		if ($edges{$name}{$chash}) {
			my $new_width = $edges{$name}{$chash}->width + $edge->width;
			$edges{$name}{$chash}->width($new_width);
		} else {
			$edges{$name}{$chash} = $edge;
			push @edges, $edge;
		}
	}
	$self->{input_edges} = \@edges;
	return 1;
};

sub clean_output_edges {
	my ($self, $edges) = @_;
	my (%edges, @edges);

	foreach my $edge (@$edges) {
		my $name = $edge->output_condition->name;
		if ($edges{$name}) {
			my $new_width = $edges{$name}->width + $edge->width;
			$edges{$name}->width($new_width);
		} else {
			$edges{$name} = $edge;
			push @edges, $edge;
		}
	}
	$self->{output_edges} = \@edges;
	return 1;
};

sub is_active {
	my ($self) = @_;
	my @edges = @{$self->input_edges};

	foreach my $e (@edges) {
		return 0 unless $e->prepared_items;
	}

	return 1;
}

sub consume_input {
	my ($self) = @_;
	my @edges = @{$self->input_edges};
	my @source_structures;
	foreach my $e (@edges) {
		return 0 unless $e->prepared_items( $e->width );
		push @source_structures, $e->bring_items( $e->width );
	}
	$self->{values} = \@source_structures;

	return 1;
}

sub propagate_first {
	my (@values) = @_;
	return $values[0] || undef;
}

sub fire {
	my ($self) = @_;
	return 0 unless $self->consume_input;
	my ($first_val, $color) = $self->execution_closure->(@{$self->{values}});

	$self->send_result( $first_val || "bullet", $color );
	
	return 1;
}

sub send_result {
	my ($self, $result, $color) = @_;

	$_->send( $result, $color ) foreach @{$self->{output_edges}};

	return 1;
}

1;
