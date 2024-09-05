=pod
This class serves as a container for a single exam question and its corresponding answer choices. 
It facilitates the management of questions and their associated answers by supporting functionalities 
such as randomization and the removal of correct answer indicators. The class is designed to be used 
in the context of generating randomized exam files from a master examination file.
=cut

package MCI {
    use Moose;
    use List::Util 'shuffle';

    has question => (
        is          => 'ro',
        isa         => 'Str',
        reader      => 'get_question',
        required    => 1,  
    );

    has right_answer => ( 
        is          => 'rw',
        isa         => 'Str',
        default     => 'Right answer has not been set yet',
    );

    has answers => (
        is      => 'ro',
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

    sub set_right_answer {
        my ($self, $right_answer) = @_;
        $self -> right_answer($right_answer);
        push @{$self -> get_answers()}, $right_answer;
    }

    sub randomize_answers {
        my $self = shift;
        my @shuffled = shuffle(@{$self -> get_answers()});
        $self -> set_answers(\@shuffled);
    }

    sub print_item {
        my ($self, $q_num) = @_;

        my $item = $q_num.". ".$self -> get_question()."\n";

        foreach my $answer (@{$self -> get_answers()}) {
            $item = $item."[ ]    ".$answer."\n";
        }

        return $item."\n";
    }

    sub get_right_answer {
        my $self = shift;
        return $self -> right_answer;
    }

}

my $example = MCI -> new(question => "How are you ?");
my $right_answer = "Good, what about you";

$example -> add_answer("You have been a good boy");
$example -> add_answer("The keys are on the table");
$example -> add_answer("You are an idiot");
$example -> add_answer("This is for the shuffle");


$example -> set_right_answer($right_answer);
$example -> display_question();

print "\nThe original sequence of answers: \n";
print $example -> print_item(1);

print "After randomiziation: \n";
$example -> randomize_answers();
print $example -> print_item(1);