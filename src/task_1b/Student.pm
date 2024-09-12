

package Student {
    use Moose;

    has file_path => (
        is          => 'ro',
        isa         => 'Str',
        reader      => 'get_file_path',
        required    => 1,
    );

    has family_name => (
        is          => 'rw',
        isa         => 'Str',
        reader      => 'get_family_name',
        writer      => 'set_family_name',
        required    => 1
    );

    has first_name => (
        isa         => 'Str',
        reader      => 'get_first_name',
        writer      => 'set_first_name',
        required    => 1
    );

    has student_id => (
        is          => 'rw',
        isa         => 'Str',
        reader      => 'get_student_id',
        writer      => 'set_student_id',
        required    => 1
    );

    has items => (
        is      => 'ro',
        isa     => 'HashRef',
        reader  => 'get_items',
        writer  => 'set_items',
        default => sub {{}}, 
    );


    has selections => (
        is          => 'rw',
        isa         => 'HashRef',
        reader      => 'get_selections',
        required    => 1,
        default     => sub{{}},
    );

    has missing_question => (
        is         => 'rw',
        isa        => 'ArrayRef[Str]',
        reader     => 'get_missing_question',
        default    => sub {[]}, 
    );

    has missing_answer => (
        is         => 'rw',
        isa        => 'ArrayRef[Str]',
        reader     => 'get_missing_answer',
        default    => sub {[]}, 
    );

    has points => (
       is       => 'rw',
       isa      => 'HashRef',
       reader   => 'get_points',
       default  => sub {{}}, 
    );

    sub add_item {
        my ($self, $item) = @_;
        $self -> get_items() -> {$item -> get_question()} = $item;
        $self -> get_selections()->{$item -> get_question()} = $item -> get_chosen_answer();
    }

    sub get_item {
        my ($self, $question) = @_;
        return $self -> get_items() -> {$question};
    }

    sub add_missing_question {
        my ($self, $question) = @_;
        push @{$self -> get_missing_question()}, $question;
    }

    sub add_missing_answer {
        my ($self, $answer) = @_;
        push @{$self -> get_missing_answer()}, $answer;
    }

    sub add_point {
        my ($self, $question) = @_;
        $self -> get_points() -> {$question} = 1;
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
    
    sub get_performance {
        my $self = shift;
        my $total_points = $self -> get_total();
        my $num_question = keys %{$self -> get_selections()};
        my $total_width = 200;

        # concatenate missing Q&A
        my $question_prefix = "Missing question: ";
        my $answer_prefix = "Missing answer: ";
        my $missing_question = "";
        my $missing_answer = "";

        foreach my $question (@{$self -> get_missing_question()}) { 
            $missing_question .= $question_prefix . $question ."\n";
        }

        foreach my $answer (@{$self -> get_missing_answer()}) {
            $missing_answer .= $answer_prefix . $answer. "\n";
        }

        my $dots_count = $total_width - length($self -> get_file_path());
        my $dots = "." x ($dots_count > 0 ? $dots_count : 0);

        my $performance = $self -> get_file_path(). ".". $dots . $total_points . "/" . $num_question ."\n";
        return $self -> get_file_path().": \n" . $missing_question. $missing_answer. $performance ."\n";
    }

    __PACKAGE__->meta->make_immutable;
    1;
}