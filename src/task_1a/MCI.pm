=pod

=head1 NAME
MCI - Multiple Choice Item Management

=head1 SYNOPSIS
The MCI (Multiple Choice Item) class encapsulates a single multiple-choice question and its associated answers. 
It provides functionalities for managing the question and its answers, including randomization of answer choices and setting 
the correct answer for scoring purposes.

=head1 DESCRIPTION
The MCI class acts as a container for individual multiple-choice questions and their possible answers. 
It supports several operations for exam creation, including randomizing answer choices and preparing questions for output. 
The class is used within the exam management system to handle each question-answer item independently.

This class supports the following operations:

=over 4

=item * Adding answers to a question and marking the correct one.

=item * Randomizing the order of answer choices to prevent answer pattern recognition.

=item * Formatting a question and its answers for display in an exam.

=back

=head1 METHODS

=over 4

=item * B<add_answer($answer)>
Adds a new answer choice to the list of answers for a given question.

=item * B<has_answer($answer)>
Checks if a given answer is part of the current question's answer choices.

=item * B<set_chosen_answer($chosen_answer)>
Specifies which of the added answers is the correct one and appends it to the list of answers.

=item * B<get_chosen_answer()>
Retrieves the correct answer for the current question.

=item * B<replace_answer($index, $answer)>
Replaces the answer at the specified index with a new one. This is useful when updating existing answers.

=item * B<randomize_answers()>
Shuffles the order of the answer choices to ensure that the answers are randomized in each generated exam.

=item * B<print_item($q_num)>
Formats the question and its associated answers for output.

=back

=head1 AUTHOR
Hoang Viet Nguyen - Developed as part of the Introduction to Perl for Programmers course final project.

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