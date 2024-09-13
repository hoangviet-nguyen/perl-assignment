=pod

=head1 NAME
Exam_Manager.pl - Script for Managing and Scoring Multiple Choice Exams

=head1 SYNOPSIS
This script provides a command-line interface for generating randomized multiple choice exam files from a master file 
and scoring student submissions. It utilizes the Master_File and MCI classes to manage questions, randomize them, and 
produce new exam versions. Additionally, it scores student submissions and generates performance reports. 

=head1 DESCRIPTION
The Exam_Manager.pl script is designed to streamline the creation and assessment of multiple-choice exams. 
It offers the following functionalities:

=over 4

=item * Generation of randomized exam files from a specified master file, including the randomization of both questions and their answers.

=item * Utilization of the Master_File and MCI classes to handle exam questions and their answers, ensuring integrity and randomness for new exam files.

=item * Capability to score student submissions against the master file, including reporting missing or incorrect answers.

=item * Command-line interface (CLI) interaction, allowing users to choose between generating exams and scoring student submissions.

=back

The script can be executed directly from the command line and is part of a broader suite of tools developed for the 
Introduction to Perl for Programmers course.

=head1 USAGE
1. **Initialization**:

    Start by loading a master exam file. This file contains the base questions and answers which will be used to 
    generate randomized versions or to score against student submissions.

    Usage:
    ```bash
    perl Exam_Manager.pl master_exam_file.txt student_exam1.txt student_exam2.txt ...
    ```

2. **Operation Options**:

    After loading the master file, the script provides a command-line interface (CLI) with options 
    to either generate a new randomized exam file or score student responses. Follow the prompts on the CLI 
    to select the desired operation:

    - B<e>: Generate a new randomized exam file.
    - B<s>: Score student submissions and output performance reports.

=head1 AUTHOR

Hoang Viet Nguyen - Developed as part of the Introduction to Perl for Programmers course final project.

=cut

use strict;
use warnings;
use lib './src/task_1a';
use lib './src/task_1b';
use Master_File;
use MCI;
use autodie qw( open close );
use Student;
use Scorer;

# regex matching pattern
my $separator_pattern = qr/^[_]+$/;
my $exam_end_pattern = qr/^(=+|.*\bEND OF EXAM\b.*)$/;
my $answer_pattern = qr/^\s*\[\s*[Xx]?\s*\]/;
my $empty_line_pattern = qr/^\s*$/;
my $chosen_answer_pattern = qr/\[\s*[a-zA-Z]\s*\]/;
my $student_id_pattern  = qr/.*Student\s+ID:\s+\[?(\d+)\]?.*/i;
my $family_name_pattern = qr/.*Family\s+Name:\s+\[?([^\]]+)\]?.*/i;
my $first_name_pattern  = qr/.*First\s+Name:\s+\[?([^\]]+)\]?.*/i;
    
# command dialog
my $master_file_path = shift @ARGV;
my @student_paths = @ARGV;
my $master_file = create_master_file($master_file_path);
my @students = create_students(@student_paths);
my $scorer = Scorer -> new(master_file => $master_file, students => @students);
print "Would you like to create new exams (e) or to score (s) the students?\n";
my $command = <STDIN>
my $validCommand = 0;
chomp($command);

while(!$validCommand) {
    $command = lc($command);
    if ($command eq "s") {
        $scorer -> print_student_performance();
        print "Creating grades.txt\n";
        $validCommand = 1;
    } elsif ($command eq "e") {
        $master_file -> create_exam_file();
        print "Creating new exam file\n"
        $validCommand = 1;
    } else {
        print "Please enter a valid command (e/s)";
        $command = chomp(<STDIN>);
    }
}

sub create_students {
    my (@paths) = @_;
    my @students;

    foreach my $path (@paths) {
        open my $file, '<', $path;
        my $student = create_student($path, $file);
        while (defined(my $line = <$file>)) {
            next if $line =~ $empty_line_pattern;
            last if $line =~ $exam_end_pattern;
            my $item = create_item($line, $file);
            $student -> add_item($item);
        }

        push @students, $student;
    }

    return \@students;
}

sub create_student {
    my ($path, $file) = @_;
    my $first_name = "";
    my $family_name = "",
    my $student_id = "";

    #extract student info and skip to the first item
    while (defined(my $line = <$file>)) {
        last if $line =~ $separator_pattern;
        if ($line =~ $student_id_pattern) {
            $student_id = $line;
        }
        if ($line =~ $first_name_pattern) {
            $first_name = $line;
        }
        if ($line =~ $family_name_pattern) {
            $family_name = $line;
        }

    }
    return Student -> new (file_path => $path, first_name => $first_name, family_name => $family_name, student_id => $student_id);
}


sub create_master_file {
    my ($file_name) = @_;
    my $master_file = Master_File -> new(file_name => $file_name);
    open my $file ,'<', $file_name;
    my $rules = "";

    # append the ruleset for the master file
    while (defined(my $line = <$file>)) {
        last if $line =~ $separator_pattern;
        $rules .= $line;
    }

    while (defined(my $line = <$file>)) {
        next if $line =~ $empty_line_pattern;
        last if $line =~ $exam_end_pattern;
        my $item = create_item($line, $file);
        $master_file -> add_item($item);
    }

    $master_file -> set_rules($rules);
    return $master_file;
}

sub create_item {
    my ($line, $file) = @_;
    my $question = extract_question($line, $file);
    my $item = MCI -> new(question => $question);
    extract_answers($item, $line, $file);
    return $item;
}


sub extract_question {
    my ($line, $file) = @_;
    # Start capturing the question text
    my $question = '';
    do {
        chomp($line);
        $line =~ s/^\s*(\d+\.\s*)?|\s+$//g;
        $question .= " " if $question;
        $question .= $line;
    } while (defined($line = <$file>) && $line !~ $empty_line_pattern);

    return $question;
}


sub extract_answers {
    my ($item, $line, $file) = @_;
    my $current_answer = -1;
    my $chosen_answer = 0;

    while(defined($line = <$file>) && $line !~ $separator_pattern && $line !~ $exam_end_pattern) {
        next if $line =~ $empty_line_pattern;
        my $answer = $line;
        $answer =~ s/^\s+|\s+$//g; # remove leading whitespaces


        if($answer !~ $answer_pattern) {
            my $sub_answer = $item -> get_answers()->[$current_answer]. " ".$answer;
            $item -> replace_answer($current_answer, $sub_answer);
            if ($chosen_answer) {
                $item -> set_chosen_answer($sub_answer);
            }
            next;
        }

        if ($answer =~ s/$chosen_answer_pattern//g) {
            # Remove any extra whitespaces after removing [X]
            $answer =~ s/^\s+|\s+$//g;
            $item-> set_chosen_answer($answer);
            $chosen_answer = 1;
        } else {
            # Remove any [ ] and leading whitespaces from other answers 
            $answer =~ s/\[\s*\]\s*//;
            $item->add_answer($answer);
            $chosen_answer = 0;
        }

        $current_answer++;
    }
}
