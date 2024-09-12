=pod
Here comes the comment documentation about the scorer
=cut


package Scorer {

    has master_file => (
        is          => 'ro',
        isa         => 'Master_File',
        reader      => 'get_master_file',
        required    => 1,
    )

    has students => (
        is          => 'rw',
        isa         => 'ArrayRef[Student]',
        reader      => 'get_students',
        writer      => 'set_students',
    )

=pod
============================================================
                Main Tasks (Scoring)
============================================================
=cut

    sub add_student {
        my ($self, $student) = @_;
        push @{$self -> get_students()}, $student;
    }

    sub score_student {
        my ($self, $student) = @_;

        foreach my $item (@{$self -> get_master_file() -> get_items()}) {
            my $question = $item -> get_question();
            my $right_answer = $item -> get_right_answer();
            my $student_answer = $student -> get_answer($question);

            # exact matching of question
            if ($student_answer eq $right_answer) {
                $student -> add_point($question);
            } else {
                $student -> no_point($question);
            }
        }
    }

    sub score_all_students {
        my $self = shift;
        foreach my $student (@{$self -> get_students()}) {
            score_student($student);
        }
    }


=pod
============================================================
                    Statistics
============================================================
=cut

sub print_student_performance {
    
}


=pod
============================================================
                    Extensions
============================================================
=cut

}