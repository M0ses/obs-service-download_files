package MyHttpServer;
use strict;
use warnings;
use FindBin;
use IO::Socket;
use File::LibMagic;

sub new {
  my ($class, $port) = @_;
  my $self = bless {document_root=>$FindBin::Bin}, $class;
  $self->{sock} = new IO::Socket::INET (
				  LocalHost => 'localhost',
				  LocalPort => $port,
				  Proto => 'tcp',
				  Listen => 1,
				  Reuse => 1,
				  );
  die "Could not create socket: $!\n" unless $self->{sock};

  return $self;
}

sub background {
  my ($self) = @_;
  my $pid = $self->{pid} = fork;
  return $pid if $pid;
  while(1) {
    $self->read_sock();
    $self->{client}->shutdown(SHUT_WR);;
  }
}

sub read_sock {
  my ($self) = @_;
  my $cl = $self->{client} = $self->{sock}->accept();
  my $req;
  while(<$cl>) {
     $req .= $_;
     last if $_ eq "\r\n";
  }
  $self->handle_request($req);
}

sub send_sock {
  my ($self, $response) = @_;
  $self->{client}->send($response);
}

sub handle_request {
   my ($self, $req) = @_;

   my $path = $self->path_info($req);
   my $file = "$self->{document_root}/$path";

   if ( -f $file ) {
       $self->send_sock("HTTP/1.1 200 OK\r\n");
       $self->file_handler($file);
   } else {
       $self->print_404($file),
   }
}

sub path_info {
  my ($l, undef) = split("\n", $_[1]);
  $l =~ s#GET (.*) HTTP/.*#$1#;
  return $l;
}

sub header {
  my ($self, $code) = @_;
  my $ct = {
    200 => 'OK',
    404 => 'NOT FOUND'
  };
  $self->send_sock("HTTP/1.1 $code $ct->{$code}\r\n");
}

sub print_404 {
  my ($self, $file) = @_;
  $self->header(404);
  $self->send_sock("\n<html><body>Not found $file<body></html>");
}

sub file_handler {
  my ($self, $f) = @_;
  my $magic = File::LibMagic->new;
  if (open(my $fh, '<', $f)) {
    my $info = $magic->info_from_handle($fh);
    local $/; # enable localized slurp mode
    my $fc = <$fh>;
    close $fh;
    my $l   = length($fc);
    $self->send_sock("Content-Type: $info->{mime_type}\r\n");
    $self->send_sock("Content-Length: $l\r\n\r\n");
    $self->send_sock($fc);
  } else {
    $self->print_404();
  }
}

1;
