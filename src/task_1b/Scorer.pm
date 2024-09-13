=pod

=head1 NAME
Scorer - Class for Scoring Student Submissions in Multiple Choice Exams

=head1 SYNOPSIS
This class provides the functionality to score student submissions against a master exam file. It interacts with the 
Student, Master_File, and MCI classes to compare answers, calculate scores, and record performance results.

=head1 DESCRIPTION
The Scorer class is designed to automate the scoring of student responses in multiple choice exams. It compares 
each student's answers to the correct answers in the master file, records missing or incorrect answers, and outputs 
a performance report. 

It offers the following functionalities:

=over 4

=item * Scoring individual or multiple students against the master exam file.

=item * Checking for correct and missing answers.

=item * Generating a performance report for each student.

=back

=head1 METHODS

=over 4

=item * B<add_student($student)>: 
Adds a student to the Scorer object. The student is then included in the scoring process.

=item * B<score_student($student)>: 
Scores the given student by comparing their responses to the correct answers in the master exam file. Records 
points for correct answers and marks missing answers.

=item * B<score_all_students()>: 
Scores all students that have been added to the Scorer object. This method loops through each student and 
invokes the score_student method.

=item * B<check_item($master_item, $student)>: 
Checks if the student's answer for a specific question matches the correct answer in the master file. Records 
any missing or incorrect answers.

=item * B<print_student_performance()>: 
Scores all students and generates a performance report for each student, which is written to a file (grades.txt).

=back

=head1 AUTHOR

Hoang Viet Nguyen - Developed as part of the Introduction to Perl for Programmers course final project.

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

    sub add_student {
        my ($self, $student) = @_;
        push @{$self -> get_students()}, $student;
    }

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

    sub print_student_performance {
        my ($self) = @_;
        $self -> score_all_students(); 
        open my $out_fh, '>', "grades.txt";
        for my $student (@{$self -> get_students()}) {
            print $out_fh $student -> get_performance();
        }
    }

    __PACKAGE__->meta->make_immutable;
    1;
}