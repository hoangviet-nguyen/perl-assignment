=pod

=head1 NAME
Master_File - Class for Managing and Processing Multiple Choice Exam Files

=head1 SYNOPSIS
This class manages and processes multiple-choice exam files, facilitating the collection, organization, 
and randomization of exam questions and their answers for generating diverse exam versions.

=head1 DESCRIPTION
The Master_File class handles the core functionality of managing multiple-choice exam content. It supports:

=over 4

=item * Collecting multiple-choice questions into a manageable format.

=item * Mapping each question to its correct answer for accurate scoring.

=item * Randomizing the order of questions and answers to generate varied exam sets, enhancing exam integrity.

=item * Creating new exam files with randomized content, ensuring each file is unique.

=back

=head1 METHODS

=over 4

=item * B<add_item($item)>
Adds a new Multiple Choice Item (MCI) to the exam. This method also maps the question to its correct answer for later scoring.

=item * B<get_item($question)>
Retrieves the Multiple Choice Item (MCI) for a specific question.

=item * B<_randomize_questions>
Private method that randomizes the order of both the questions and their answers to ensure unique exam arrangements.

=item * B<get_answer($question)>
Returns the correct answer for a given question, which is essential for scoring purposes.

=item * B<create_exam_file>
Generates a new exam file with randomized content. The file is named with a timestamp to ensure uniqueness and contains 
randomized questions and answers.

=back


=head1 AUTHOR
Hoang Viet Nguyen - Developed as part of the Introduction to Perl for Programmers course final project.

=cut


package Master_File {
    use Moose;
    use MCI;
    use strict;
    use List::Util 'shuffle';
    use POSIX qw(strftime);
    use autodie qw( open close );


    has file_name => (
        is          => 'ro',
        isa         => 'Str',
        reader      => 'get_file_name',
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
        $self -> get_solutions()->{$item -> get_question()} = $item -> get_chosen_answer();
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
        my ($file_name) = $self->get_file_name() =~ m|([^/]+)$|;
        $file_name = $current_date. $file_name ."\n";

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

        print $out_fh "=" x 80, "\n";
        print $out_fh " " x 34, "END OF EXAM\n";
        print $out_fh "=" x 80, "\n"; 
        close $out_fh;
    }

    __PACKAGE__->meta->make_immutable;
    1;
}
