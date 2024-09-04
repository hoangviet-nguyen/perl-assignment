=pod
This class serves as a container for a single exam question and its corresponding answer choices. 
It facilitates the management of questions and their associated answers by supporting functionalities 
such as randomization and the removal of correct answer indicators. The class is designed to be used 
in the context of generating randomized exam files from a master examination file.
=cut

package MCI {
    use Moose;

    has question => (
        is          => 'ro',
        isa         => 'Str',
        reader      => 'get_question',
        required    => 1,  
    );

    has right_answer => ( 
        is          => 'rw',
        isa         => 'Str',
        writer      => 'set_right_answer',
        default     => 'Right answer has not been set yet',
    );

    sub display_question {
        my $self = shift;
        print $self -> get_question(), "\n";
    }

    sub add_answer {

    }

    sub randomize_answers {

    }

    sub print_item {

    }

    sub get_right_answer {
        my $self = shift;
        return $self -> right_answer;
    }

}

my $example = MCI -> new(question => "How are you ?");
my $right_answer = "Good, what about you";
$example -> set_right_answer($right_answer);
$example -> display_question();
print $example -> get_right_answer(), "\n";
