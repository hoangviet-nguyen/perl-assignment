=pod

=head1 NAME
MCI - Multiple Choice Item Management

=head1 SYNOPSIS
This class encapsulates a single multiple choice question and its associated answer choices. 
It provides functionalities for the effective management of questions and their answers, including capabilities 
for answer randomization and the anonymization of correct answers in preparation for exam generation.

=head1 DESCRIPTION
The MCI (Multiple Choice Item) class acts as a container for individual exam questions along with their possible answers. 
It supports the following operations:

=over 4

=item * Adding answers to questions and marking the correct one.

=item * Randomizing the order of answer choices to prevent answer pattern recognition during exams.

=back

=head1 METHODS

=over 4

=item * add_answer($answer) - Adds a new answer choice to a question.

=item * set_right_answer($right_answer) - Specifies which of the added answers is correct.

=item * randomize_answers - Shuffles the order of the answer choices.

=item * print_item($q_num) - Formats the question and its answers for output, including prepending each answer with an unchecked checkbox.

=item * get_right_answer - Retrieves the correct answer for scoring purposes.

=back

=head1 USAGE
Instances of the MCI class are used throughout the exam file creation process to manage individual questions and their answers. 
They are crucial for the functionality of the Exam_File class, which compiles these items into complete exam documents.

=head1 AUTHOR
[Hoang Viet Nguyen] - Developed for the Introduction to Perl for Programmers course final project.

=cut


package MCI {
    use Moose;
    use List::Util 'shuffle';
    use strict;

    has question => (
        is          => 'rw',
        isa         => 'Str',
        reader      => 'get_question',
        writer      => 'set_question',
        required    => 1,  
    );

    has chosen_answer => ( 
        is          => 'rw',
        isa         => 'Str',
        default     => 'Chosen answer has not been set yet',
    );

    has answers => (
        is      => 'rw',
        isa     => 'ArrayRef[Str]',
        reader  => 'get_answers', 
        writer  => 'set_answers',
        default => sub {[]},
    );

    sub display_question {
        my $self = shift;
        print $self -> get_question(), "\n";
    }

    sub add_answer {
        my ($self, $answer) = @_;
        push @{$self -> get_answers()}, $answer;
    }

    sub has_answer {
        my ($self, $answer) = @_;
         return grep {$_ eq $answer} @{ $self->get_answers() };
    }

    sub set_chosen_answer {
        my ($self, $chosen_answer) = @_;
        $self -> chosen_answer($chosen_answer);
        push @{$self -> get_answers()}, $chosen_answer;
    }

    sub get_chosen_answer {
        my $self = shift;
        return $self -> chosen_answer;
    }

    sub replace_answer {
        # this method is inteded to replace mult
        my ($self, $index, $answer) = @_;
        $self -> get_answers() -> [$index] = $answer;
    }

    sub randomize_answers {
        my $self = shift;
        my @shuffled = shuffle(@{$self -> get_answers()});
        $self -> set_answers(\@shuffled);
    }

    sub print_item {
        my ($self, $q_num) = @_;

        my $item = $q_num.". ".$self -> get_question()."\n\n";

        foreach my $answer (@{$self -> get_answers()}) {
            $item = $item."[ ]    ".$answer."\n";
        }

        return $item;
    }

    __PACKAGE__->meta->make_immutable;
    1;
}