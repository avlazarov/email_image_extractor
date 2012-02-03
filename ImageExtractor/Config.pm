package ImageExtractor::Config;

use List::MoreUtils qw{any};
use Config;
use File::Spec;

# default configuration values
my %conf = {'dest_dir'    => '',
            'dest_format' => 'jpeg'
           };

# permitted params
my @valid_conf_keys = qw{dest_dir dest_format};
my @valid_save_formats = qw{jpeg jpg tiff tif png bmp gif};


# filename format when saving images
my $save_file_format;


# "constructor", loads configuration from file
sub load {
    my $class = shift;
    
    #set up configuration
    if($Config{'osname'} =~ /^\s*mswin/i){
        $config_path = "config.ini";
    } else {
        $config_path = "/usr/local/etc/imgstore.conf";
    }

    #open config file or bye bye!
    open(CONFIG, $config_path) or die("Could not find configuration file $config_path");

    #count lines for more specific error reporting
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

    #create destination directory if it does not exist
    unless(-d $conf{'dest_dir'}){
        print "Destination directory '$conf{'dest_dir'}' does not exists, creating it...";
        mkdir $conf{'dest_dir'} or die;
        chmod 777, $conf{'dest_dir'};
    }


    # check if configuration has invalid values
    if(not any {$_ eq lc $conf{'dest_format'}} @valid_save_formats) {
        printf "$conf{'dest_format'} is not a permitted image format";
        exit 1;
    }

    $save_file_format = File::Spec->catpath("", $conf{'dest_dir'}, '%s.'.$conf{'dest_format'});

    my $self = {};
    bless $self, $class;

    return $self;
}

# getter for filenames format
sub get_save_file_format {
    return $save_file_format;
}

1;
