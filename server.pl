use ImageExtractor::Server;

my $pid = ImageExtractor::Server->new(8080)->background();
print "'kill $pid' to stop server.\n";
