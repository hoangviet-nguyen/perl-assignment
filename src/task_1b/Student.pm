=pod

=head1 NAME
Student - Class for Managing Student Data in Multiple Choice Exam System

=head1 SYNOPSIS
The Student class manages information about a student taking the exam, including their personal details, 
their exam items (questions and answers), and their performance. This class is crucial in tracking individual student answers, 
recording missing or incorrect answers, and calculating the overall score for each student.

This class provides the following functionalities:

=over 4

=item * Store and manage personal details such as first name, family name, and student ID.

=item * Track and store the student's answers to exam questions, including items they answered and missed.

=item * Calculate the student's total score based on their responses.

=item * Generate a performance report detailing the student's total score and any missing or incorrect responses.

=back

=head1 ATTRIBUTES

=over 4

=item * B<file_path> (Str, read-only):
The file path of the student's exam file.

=item * B<family_name> (Str, read-write):
The student's family name.

=item * B<first_name> (Str, read-write):
The student's first name.

=item * B<student_id> (Str, read-write):
The student's ID.

=item * B<items> (HashRef, read-write):
A hash reference that stores the student's exam items (questions and their corresponding answers).

=item * B<selections> (HashRef, read-write):
A hash reference that keeps track of the student's selected answers for each question.

=item * B<missing_question> (ArrayRef[Str], read-write):
An array reference that stores any questions the student missed.

=item * B<missing_answer> (ArrayRef[Str], read-write):
An array reference that stores any answers the student missed or got wrong.

=item * B<points> (HashRef, read-write):
A hash reference that stores the points the student earned for each question.

=back

=head1 METHODS

=over 4

=item * B<add_item($item)>
Adds a multiple choice item (question and answer) to the student's collection of answered items.

=item * B<get_item($question)>
Retrieves the multiple choice item for a specific question from the student's answered items.

=item * B<has_question($question)>
Checks if the student has answered a specific question.

=item * B<add_missing_question($question)>
Records a missing question that the student failed to answer.

=item * B<add_missing_answer($answer)>
Records a missing or incorrect answer from the student's responses.

=item * B<add_point($question)>
Records a point for the student's correct answer to a specific question.

=item * B<no_point($question)>
Records no points for a question where the student's answer was incorrect.

=item * B<get_total()>
Calculates the student's total score by summing up the points for all answered questions.

=item * B<get_performance()>
Generates a performance report for the student, including their score, missing questions, and missing answers. 
The report is formatted and ready to be written to an output file.

=back

=head1 AUTHOR

Hoang Viet Nguyen - Developed as part of the Introduction to Perl for Programmers course final project.

=cut


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

    
    sub has_question {
        my ($self, $question) = @_;
         return grep {$_ eq $question} @{ $self->get_answers() };
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
        my $total_width = 100;

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

        my $dots_count = $total_width - length($self -> get_file_path()) - length("$total_points / $num_question");
        my $dots = "." x ($dots_count > 0 ? $dots_count : 0);

        my $performance = $self -> get_file_path(). ".". $dots . $total_points . "/" . $num_question ."\n";
        return $self -> get_file_path().": \n" . $missing_question. $missing_answer. $performance. "=" x $total_width ."\n\n";
    }

    __PACKAGE__->meta->make_immutable;
    1;
}