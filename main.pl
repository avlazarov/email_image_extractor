use ImageExtractor::Extractor;
use ImageExtractor::Config;

my $argc = @ARGV;

# check if there are file names passed as arguments
if($argc < 1){
    print "Need at least one email as argument. Use -h for help.";
    exit 1;
}

$\ = "\n";

if(@ARGV[0] eq "-h"){
    print "Usage:";
    print "\tmain.pl filename1 filename2 ...";
    print "\twhere fienameX is a file with the raw email content.";
    exit 0;
}

# load configuration through Config class
my $config = ImageExtractor::Config->load();

# file format when saving images
my $save_file_format = $config->get_save_file_format();

foreach (@ARGV){
    print "";
    print "Reading file $_...";

    $success = open(EMAIL, $_);

    if(!$success){
        print "File $_ does not exist or cannot be opened right now";
        next;
    }

    # get whole email content as a string
    my $message = '';
    while (<EMAIL>){
        $message .= $_;
    }

    close EMAIL;
    
    # and extract and convert via Extractor package
    ImageExtractor::Extractor::convert($message, $save_file_format);
}
