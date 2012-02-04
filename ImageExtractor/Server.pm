package ImageExtractor::Server;

use ImageExtractor::Extractor;
use ImageExtractor::Config;
use HTTP::Server::Simple::CGI;

use base qw(HTTP::Server::Simple::CGI);

$CGI::POST_MAX = 5000000;
 
# specifies action handlers
my %dispatch = (
    '/home'   => \&resp_home,
    '/upload' => \&resp_upload,
    'default' => \&resp_home,
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
        $handler = $dispatch{'default'};
        print "HTTP/1.0 200 OK\r\n";
        $handler->($cgi);
    }
}
 
# handler called when uploading email content
sub resp_upload {
    my $cgi  = shift; # CGI object
    return if !ref $cgi;

    # uploaded email filename and file handler
    my $email_filename    = $cgi->param('email_file');
    my $upload_filehandle = $cgi->upload('email_file');

    # check if a file has been submitted
    if(!$email_filename){
        print $cgi->header,
              $cgi->start_html("File not found"),
              $cgi->h1("No file uploaded!"),
              $cgi->end_html;
        return;
    }

    # load config
    my $config = ImageExtractor::Config->load();
    my $save_file_format = $config->get_save_file_format();

    #get whole email content as a string
    my $message = '';
    while (<$upload_filehandle>){
        $message .= $_;
    }

    ImageExtractor::Extractor::convert($message, $save_file_format);

    print $cgi->header,
          $cgi->start_html("Upload"),
          $cgi->h1("File $email_filename successfully uploaded!"),
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
