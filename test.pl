use ImageExtractor::EmailParser;
use ImageExtractor::Config;
use Image::Magick;

my $argc = @ARGV;

# check if there are file names passed as arguments
if($argc < 1){
    print "Need at least one email as argument...";
    exit 1;
}

$\ = "\n";

# load configuration through Config class
$config = ImageExtractor::Config->load();

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
    $message = '';
    while (<EMAIL>){
        $message .= $_;
    }

    close EMAIL;
    
    # get needed information
    my ($from, $id, %binary_images) = ImageExtractor::EmailParser::get_information($message);

    # prefix of the file names
    my $prefix = $from."_".$id."_";
    
    # iterate each image
    while (($filename, $image) = each(%binary_images)){
        print "Saving image ".$filename."...";

        $im = Image::Magick->new();
        $im->BlobToImage($image);#read image data and add it to $im object
        $im->Write(sprintf($save_file_format, $prefix.$filename));
    }
}
