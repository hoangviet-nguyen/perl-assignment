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
use Exam_File;
use MCI;
