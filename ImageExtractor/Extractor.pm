package ImageExtractor::Extractor;

use ImageExtractor::EmailParser;
use Image::Magick;

# param1 - email content as a string
# param2 - the file format for the image files
our sub convert {
    my $message          = shift;
    my $save_file_format = shift;

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

1;
