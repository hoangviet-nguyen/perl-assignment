=pod

=head1 NAME
Exam_Manager.pl - Script for Managing and Scoring Multiple Choice Exams

=head1 SYNOPSIS
This script provides a command-line interface for generating randomized multiple choice exam files from a master file 
and scoring student submissions. It uses the Exam_File and MCI classes to manage questions, randomize them, and produce new exam versions. 
Options for scoring and identifying potential academic misconduct are included in extensions.

=head1 DESCRIPTION
The Exam_Manager.pl script is designed to streamline the creation and assessment of multiple choice exams. 
It offers the following functionalities:

=over 4

=item * Generation of randomized exam files from a specified master file.

=item * Utilization of the Exam_File and MCI classes to handle exam questions and their answers

=item * Capability to score student submissions against the master file with extensions for detailed analysis including detecting potential misconduct.

=back

The script can be executed directly from the command line and is part of a broader suite of tools developed for the 
Introduction to Perl for Programmers course.

=head1 USAGE
1. **Initialization**:

    Start by loading a master exam file. This file contains the base questions and answers which 
    will be used to generate randomized versions or to score against student submissions.

    Usage:
    ```
    perl Exam_Manager.pl master_exam_file.txt
    ```

2. **Operation Options**: 

    After loading the master file, the script provides a command-line interface (CLI) with options 
    to either generate a new randomized exam file or score student responses. Follow the prompts on the CLI 
    to select the desired operation:

=head1 EXTENSIONS

Additional functionality for scoring includes:

=over 4

=item * Inexact matching of answers to allow for minor transcription errors.

=item * Detailed reporting of scores with the option to flag suspicious patterns indicative of academic misconduct.

=back

=head1 AUTHOR

Hoang Viet Nguyen - Developed as part of the Introduction to Perl for Programmers course final project.

=cut

use strict;
use warnings;
use lib './src/task_1a';
use Master_File;
use MCI;
use autodie qw( open close );

# regex matching pattern
my $separator_pattern = qr/^[_]+$/;
my $exam_end_pattern = qr/^(=+|.*\bEND OF EXAM\b.*)$/;
my $answer_pattern = qr/^\s*\[\s*[Xx]?\s*\]/;
my $empty_line_pattern = qr/^\s*$/;
my $chosen_answer = qr/\[\s*[a-zA-Z]\s*\]/;

my $master_file = create_master_file($ARGV[0]); 
$master_file -> create_exam_file();

sub create_master_file {
    my $file_path = shift;
    my $right_answer = 0;
    my $master_file = Master_File -> new(master_file => $file_path);
    open my $file ,'<', $file_path;
    my $rules = "";

    # append the ruleset for the master file
    while (my $line = <$file>) {
        last if $line =~ $separator_pattern;
        $rules .= $line;
    }

    while (defined(my $line = <$file>)) {
        next if $line =~ $empty_line_pattern;
        last if $line =~ $exam_end_pattern;

        # Start capturing the question text
        my $question = '';
        do {
            chomp($line);
            $line =~ s/^\s*(\d+\.\s*)?|\s+$//g;
            $question .= " " if $question;
            $question .= $line;

        } while (defined($line = <$file>) && $line !~ $empty_line_pattern);

        my $item = MCI -> new(question => $question);
        my $current_answer = -1;


        # loop until seperator
        while(defined($line = <$file>) && $line !~ $separator_pattern && $line !~ $exam_end_pattern) {
            next if $line =~ $empty_line_pattern;
            my $answer = $line;
            $answer =~ s/^\s+|\s+$//g;


            if($answer =~ $answer_pattern) {
                if ($answer =~ s/$chosen_answer//g) {
                    # Remove any extra whitespaces after removing [X]
                    $answer =~ s/^\s+|\s+$//g;
                    $item->set_right_answer($answer);
                    $right_answer = 1;
                } else {
                    # Remove any [ ] and leading whitespaces from other answers 
                    $answer =~ s/\[\s*\]\s*//;
                    $item->add_answer($answer);
                    $right_answer = 0;
                }

            } else {
                my $sub_answer = $item -> get_answers()->[$current_answer]. " ".$answer;
                $item -> replace_answer($current_answer, $sub_answer);

                if ($right_answer) {
                    $item -> set_right_answer($sub_answer);
                }

                next;
            }

            $current_answer++;
        }

        $master_file -> add_item($item);
    }

    $master_file -> set_rules($rules);
    return $master_file;
}

