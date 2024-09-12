=pod
Here comes the comment documentation about the scorer
=cut


package Scorer {
    use Moose;
    use Student;
    use autodie qw( open close );
    use MCI;

    has master_file => (
        is          => 'ro',
        isa         => 'Master_File',
        reader      => 'get_master_file',
        required    => 1,
    );

    has students => (
        is          => 'rw',
        isa         => 'ArrayRef[Student]',
        reader      => 'get_students',
        writer      => 'set_students',
        default     => sub {[]},
        required    => 1,
    );
=pod
============================================================
                    Helper Functions
============================================================
=cut

sub check_item { 
    my ($self, $master_item, $student) = @_;
    my $question = $master_item -> get_question();
    my $student_item = $student -> get_item($question);

    if (!defined($student_item)) {
        $student -> add_missing_question($question);
        $student -> no_point($question);
        return 0;
    }

    foreach my $answer (@{$master_item -> get_answers()}) {
        if (!$student_item -> has_answer($answer)) {
            $student -> add_missing_answer($answer);
        }
    }

    return 1;
}

=pod
============================================================
                Main Tasks (Scoring)
============================================================
=cut

    sub score_student {
        my ($self, $student) = @_;
        foreach my $master_item (@{$self->get_master_file()->get_items()}) {
            next if !$self -> check_item($master_item, $student);
            my $question = $master_item -> get_question();
            my $student_answer = $student -> get_item($question) -> get_chosen_answer();
            my $right_answer = $master_item -> get_chosen_answer();

            # exact matching of question
            if ($student_answer eq $right_answer) {
                $student -> add_point($question);
            } else {
                $student -> no_point($question);
            }
        }
    }

    sub score_all_students {
        my ($self) = @_;
        foreach my $student (@{$self -> get_students()}) {
            $self -> score_student($student);
        }
    }

    sub add_student {
        my ($self, $student) = @_;
        push @{$self -> get_students()}, $student;
    }


=pod
============================================================
                    Statistics
============================================================
=cut

    sub print_student_performance {
        my ($self) = @_;
        $self -> score_all_students(); 
        open my $out_fh, '>', "grades.txt";
        for my $student (@{$self -> get_students()}) {
            print $out_fh $student -> get_performance();
        }
    }


=pod
============================================================
                    Extensions
============================================================
=cut



    __PACKAGE__->meta->make_immutable;
    1;
}