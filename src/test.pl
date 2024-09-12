# Loop through each command line argument provided
foreach my $filename (@ARGV) {
    my $file = $filename =~ /\/([^\/]+)\.txt$/;
    printf "%s/%s.%s%d/%d\n", "exam1", $filename, "." x 10, 10, 30;
}