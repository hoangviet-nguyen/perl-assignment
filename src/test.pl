my $master_file_path =  shift @ARGV;
print "The master file is : ", $master_file_path, "\n";
my $total_width = 100; 
my @files;

for (my $i = 0; $i < 10; $i++) {
    push @files, $i;
}

foreach my $s (@files) {
    print $s, "\n";
}