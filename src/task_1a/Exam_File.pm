=pod

=head1 NAME
Exam_File - Multiple Choice Exam File Processor

=head1 SYNOPSIS
This class manages and processes multiple choice exam files. It is designed to facilitate the collection, 
organization, and randomization of exam questions and their answers for the generation of varied exam versions.

=head1 DESCRIPTION
The Exam_File class handles multiple choice exam content. Key functionalities include:

=over 4

=item * Collecting multiple choice questions into a manageable format.

=item * Mapping each question to its correct answer to ensure accurate scoring.

=item * Randomizing the order of questions to prepare diverse exam sets, thereby enhancing exam integrity.

=back

=head1 METHODS

=over 4

=item * add_item($item)
Adds a new Multiple Choice Item (MCI) to the exam. This method also maps the question to its correct answer for later scoring.

=item * _randomize_questions
Private method to shuffle both the questions and their answers. This method is used internally to ensure that each exam file 
generated has a unique arrangement of questions.

=item * get_answer($question)
Retrieves the correct answer for a given question. This method is essential for scoring purposes.

=item * create_exam_file
Generates a new exam file with randomized content. The file is named with a timestamp to ensure uniqueness. 
This method handles the writing of questions and answers to the new file in a randomized order.

=back

=head1 USAGE
Instances of this class are used to load questions from a designated master file, manipulate the question order,
and output new, randomized exam files tailored for different testing scenarios.

=head1 AUTHOR
[Hoang Viet Nguyen] - Developed for the Introduction to Perl for Programmers course final project.

=cut


package Exam_File {
    use Moose;
    use MCI;
    use strict;
    use List::Util 'shuffle';
    use POSIX qw(strftime);
    use autodie qw( open close );


    has master_file => (
        is          => 'ro',
        isa         => 'Str',
        reader      => 'get_master_file',
        required    => 1,
    );

    has rules => (
        is          => 'rw',
        isa         => 'Str',
        reader      => 'get_rules',
        writer      => 'set_rules',
        default     => 'Rules not set',
        required    => 1, 
    );

    has items => (
        is      => 'ro',
        isa     => 'ArrayRef[MCI]',
        reader  => 'get_items',
        writer  => 'set_items',
        default => sub {[]}, 
    );

    has solutions => (
        is      => 'ro',
        isa     => 'HashRef',
        reader  => 'get_solutions',
        default => sub {{}}, 
    );

    sub add_item {
        # add items to list for shuffling and file writing
        # map question and answer for scoring
        my ($self, $item) = @_;
        push @{$self -> get_items()}, $item;
        $self -> get_solutions()->{$item -> get_question()} = $item -> get_right_answer();
    }

    sub _randomize_questions {
        # this is a private method to shuffle the answers and questions
        my $self = shift;

        foreach my $item (@{$self -> get_items()}) {
            $item -> randomize_answers();
        }

        my @shuffled = shuffle(@{$self -> get_items()});
        $self -> set_items(\@shuffled);
    }

    sub get_answer {
        my ($self, $question) = @_;
        return $self -> get_solutions()->{$question};
    }


    sub create_exam_file {
        my $self = shift;
        my $current_date = strftime "%Y%m%d-%H%M%S-", localtime;
        my $file_name = $current_date. $self -> get_master_file() ."\n";

        # randomize the items
        $self -> _randomize_questions();


        open my $out_fh, '>', $file_name; 
        my $q_counter = 1;
        print $out_fh $self -> get_rules();


        # write items to file
        foreach my $item (@{$self -> get_items()}) {
            print $out_fh "_" x 80 ."\n\n";
            print $out_fh $item -> print_item($q_counter);
            print $out_fh "\n";
            $q_counter++;
        }

        close $out_fh;
    }

    __PACKAGE__->meta->make_immutable;
    1;
}
