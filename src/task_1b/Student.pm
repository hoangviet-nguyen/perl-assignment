

package Student {
    use Moose;

    has family_name => (
        is          => 'rw',
        isa         => 'Str',
        reader      => 'get_family_name',
        writer      => 'set_family_name',
        required    => 1
    )

    has first_name => (
        isa         => 'Str',
        reader      => 'get_first_name',
        writer      => 'set_first_name',
        required    => 1
    )

    has student_id => (
        is          => 'rw',
        isa         => 'Str',
        reader      => 'get_student_id',
        writer      => 'set_student_id',
        required    => 1
    )

    has selections => (
        is          => 'rw',
        isa         => 'HashRef',
        reader      => 'get_selections',
        writer      => 'set_selections',
        required    => 1,
        default     => sub{{}},
    )

    has points => (
       is       => 'rw',
       isa      => 'HashRef',
       reader   => 'get_points',
       default  => sub {{}}, 
    )

    sub add_selection {
        my ($self, $question, $answer) = @_;
        $self -> get_selections() -> {$question} = $answer;
    }

    sub get_answer {
        my ($self, $question) = @_;
        return $self -> get_selections() -> {$question};
    }

    sub add_point {
        my ($self, $question) = @_;
        $self -> get_points() -> {$questions} = 1;
    }

    sub no_point {
        my ($self, $question) = @_;
        $self -> get_points() -> {$question} = 0;
    }

    sub get_total {
        my $self = shift;
        my $num_points = 0;
        foreach my $point (values %{$self -> get_points()}) {
            $num_points += $point;
        }
        return $num_points;
    }
    
    sub print_performance {
        my $self = shift;
        my $total_points = $self -> get_total();
        
         
    }

    __PACKAGE__->meta->make_immutable;
    1;
}