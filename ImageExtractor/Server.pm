package ImageExtractor::Server;

use ImageExtractor::EmailParser;
use ImageExtractor::Config;
use Image::Magick;
use HTTP::Server::Simple::CGI;

use base qw(HTTP::Server::Simple::CGI);

$CGI::POST_MAX = 5000000;
 
# specifies action handlers
my %dispatch = (
    '/home'   => \&resp_home,
    '/upload' => \&resp_upload,
);

# handles each request
sub handle_request {
    my $self = shift;
    my $cgi  = shift;
   
    my $path = $cgi->path_info();
    my $handler = $dispatch{$path};
 
    if (ref($handler) eq "CODE") {
        print "HTTP/1.0 200 OK\r\n";
        $handler->($cgi);
         
    } else {
        print "HTTP/1.0 404 Not found\r\n";
        print $cgi->header,
              $cgi->start_html('Not found'),
              $cgi->h1('Not found'),
              $cgi->end_html;
    }
}
 
# handler called when uploading email content
sub resp_upload {
    my $cgi  = shift; # CGI object
    return if !ref $cgi;

    # uploaded email filename and file handler
    my $filename_          = $cgi->param('email_file');
    my $upload_filehandle  = $cgi->upload('email_file');

    # load config
    my $config = ImageExtractor::Config->load();
    my $save_file_format = $config->get_save_file_format();

    #get whole email content as a string
    $message = '';
    while (<$upload_filehandle>){
        $message .= $_;
    }

    #get needed information
    my ($from, $id, %binary_images) = ImageExtractor::EmailParser::get_information($message);

    #prefix of the file names
    my $prefix = $from."_".$id."_";
    
    #iterate each image
    while (($filename, $image) = each(%binary_images)){ 
        $im = Image::Magick->new();
        $im->BlobToImage($image);#read image data and add it to $im object
        $im->Write(sprintf($save_file_format, $prefix.$filename));
    }

    print $cgi->header,
          $cgi->start_html("Upload"),
          $cgi->h1("File $filename_ successfully uploaded!"),
          $cgi->end_html;

}

# handles upload form, simple
sub resp_home {
    my $cgi  = shift; # CGI object
    return if !ref $cgi;
     
    print $cgi->header,
          $cgi->start_html("Home"), # title of page
          $cgi->start_form( # main form
            -name    => 'main_form',
            -method  => 'POST',
            -enctype => 'multipart/form-data',
            -action => '/upload',
          ),
          $cgi->filefield( # file choosing field
            -name      => 'email_file',
          ),
          '<br/>',
          $cgi->submit( # submit button
            -name     => 'submit_form',
            -value    => 'Upload',
          ),
          $cgi->endform(), # end file submition form
          $cgi->end_html;
}

1;
