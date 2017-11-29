package SCPN::Schema;

use Moo;
use Mojo::Exception;
use namespace::clean;
use JSON::XS;
use File::Slurp;

use SCPN::Condition;
use SCPN::Event;

use SCPN::Edge::CE;
use SCPN::Edge::EC;

has events => ( 
	is => 'rw',
	isa => sub {
		return unless defined $_[0];
		Mojo::Exception->throw("SCPN::Schema: event constraint fails.")
			if not ref $_[0] eq 'HASH' or grep(not $_->isa('SCPN::Event'), values %{$_[0]});
	},
	default => sub {return {}}
);

has conditions => ( 
	is => 'rw',
	isa => sub {
		return unless defined $_[0];
		Mojo::Exception->throw("SCPN::Schema: input event constraint fails.")
			if not ref $_[0] eq 'HASH' or grep(not $_->isa('SCPN::Condition'), values %{$_[0]});
	},
	default => sub {return {}}
);

has actions => (
	is => 'rw',
	default => sub { {} }
);

sub build_schema_from_json {
	my ($self, $fpath) = @_;

	my $hash_schema = deserialize_from_file($fpath) || {};

	my ($events, $conditions) = $self->build_schema_from_hash($hash_schema->{events});
	my ($bullets) = $self->load_case_from_hash($hash_schema->{case});

	return ($events, $conditions, $bullets);
}

sub load_case_from_hash {
	my ($self, $case) = @_;

	return 0 unless $case or ref $case ne 'HASH';

	my $counter = 0;
	foreach my $condition_name (keys %$case) {
		Mojo::Exception->throw("SCPN::Load case: condition '$condition_name' was not declared.")
			unless exists $self->conditions->{$condition_name};

		foreach my $item_id (keys %{$case->{$condition_name}}) {
			$self->conditions->{$condition_name}->add_item(
				item_id => $item_id,
				item => $case->{$condition_name}{$item_id}{value}
			);
			$counter++;
		}
	}

	return $counter;
}
# TODO watch PIPE2 -> http://pipe2.sourceforge.net/
#TODO Serialize schema to DOT
#TODO Serialize case

sub add_condition {
	my( $self, $name ) = @_;

	return $self->conditions->{$name} if exists $self->conditions->{$name};

	my $condition = SCPN::Condition->new({name => $name});
}

sub build_schema_from_hash {
	my ($self, $schema) = @_;

	return unless $schema or ref $schema ne 'HASH';

	my (%condition,%event);
	foreach my $event_name ( keys %$schema ) {
		$event{$event_name} = SCPN::Event->new(
			name => $event_name,
			$schema->{$event_name}{class} ? (execution_closure => $self->{actions}{$schema->{$event_name}{class}}) : ()
		);
		my (@inputs, @outputs);
		foreach my $edge (@{$schema->{$event_name}{input_edges}}) {
			$condition{$edge->{condition}} = SCPN::Condition->new(name=>$edge->{condition})
				unless exists $condition{$edge->{condition}};
			push @inputs, SCPN::Edge::CE->new(input_condition => $condition{$edge->{condition}})
				foreach (1..$edge->{count} || 1);

		}
		foreach my $edge (@{$schema->{$event_name}{output_edges}}) {
			$condition{$edge->{condition}} = SCPN::Condition->new(name=>$edge->{condition})
				unless exists $condition{$edge->{condition}};
			push @outputs, SCPN::Edge::EC->new(output_condition => $condition{$edge->{condition}})
				foreach (1..$edge->{count} || 1);

		}
		$event{$event_name}->input_edges(\@inputs);
		$event{$event_name}->output_edges(\@outputs);
	}
	$self->conditions(\%condition);
	$self->events(\%event);
	return (scalar keys %event, scalar keys %condition);
}

sub deserialize_from_file {
	my ($fpath) = @_;
	return JSON::XS->new->decode(scalar File::Slurp::read_file($fpath));
}

1;
