package ImageExtractor::EmailParser;

use Email::MIME;

#param1 - email content
#returns from, message-id and parts of the email
our sub get_information {
    my ($email_content) = @_;
    my $parsed_content = Email::MIME->new($email_content);

    my @parts  = $parsed_content->parts;
    my $from   = $parsed_content->header('FROM');
    my $id     = $parsed_content->header('Message-ID');
    my %images;

    $from = $1 if($from =~ /\<(.+)\>/);
    $id   = $1 if($id =~ /\<(.+?)\>/);
    
    $parsed_content->walk_parts(sub {
            my ($part) = @_;
            if($part->content_type =~ /^image\//){
                $images{$part->filename} = $part->body;
            }
        });

    return $from, $id, %images;
}

1;
