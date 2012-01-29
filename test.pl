use ImageExtractor::EmailParser;
use Image::Magick;
use List::MoreUtils qw{any};
use Config;
use File::Spec;

my $argc = @ARGV;
if($argc < 1){
    print "Need at least one email as argument...";
    exit 1;
}

$\ = "\n";

#default configuration values
my %conf = {'dest_dir'    => '',
            'dest_format' => 'jpeg'
           };

my @valid_conf_keys = qw{dest_dir dest_format};
my @valid_save_formats = qw{jpeg jpg tiff tif png bmp gif};

#set up configuration
if($Config{'osname'} =~ /^\s*mswin/i){
    $config_path = "config.ini";
} else {
    $config_path = "/usr/local/etc/imgstore.conf";
} 

open(CONFIG, $config_path) or die("Could not find configuration file $config_path");

$line_num = 1;
while(<CONFIG>){
    if($_ =~ /^\s*(.+?)\s*\=\s*(.+?)\s*$/){
        ($conf_key, $conf_value) = ($1, $2);

        if(any {$_ eq lc $conf_key} @valid_conf_keys) {
            $conf{$conf_key} = $conf_value;
        } else {
            print "Line $line_num: '$conf_key' is not a valid configuration value";
        }
    }
    ++$line_num;
}

close CONFIG;

if(not any {$_ eq lc $conf{'dest_format'}} @valid_save_formats) {
    printf "$conf{'dest_format'} is not a permitted image format";
    exit(1);
}

my $save_file_format = File::Spec->catpath("", $conf{'dest_dir'}, '%s.'.$conf{'dest_format'});

#create destination directory if it does not exist
unless(-d $conf{'dest_dir'}){
    print "Destination directory '$conf{'dest_dir'}' does not exists, crating it...";
    mkdir $conf{'dest_dir'} or die;
    chmod 777, $conf{'dest_dir'};
}

my $argc = @ARGV;

if($argc < 1){
    print "Need at least one email as argument...";
    exit 1;
}

foreach (@ARGV){
    print "";
    print "Reading file $_...";

    $success = open(EMAIL, $_);

    if(!$success){
        print "File $_ does not exist or cannot be opened right now";
        next;
    }

    #get whole email content as a string
    $message = '';$conf{'dest_format'};
    while (<EMAIL>){
        $message .= $_;
    }

    close EMAIL;
    
    #get needed information
    my ($from, $id, %binary_images) = ImageExtractor::EmailParser::get_information($message);

    #prefix of the file names
    my $prefix = $from."_".$id."_";
    
    #iterate each image
    while (($filename, $image) = each(%binary_images)){
        print "Saving image ".$filename."...";

        $im = Image::Magick->new();
        $im->BlobToImage($image);#read image data and add it to $im object
        $im->Write(sprintf($save_file_format, $prefix.$filename));
    }

    #EML + WEB INTERFACE
}
