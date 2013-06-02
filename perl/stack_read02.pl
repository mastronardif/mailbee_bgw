use AnyEvent::RabbitMQ;
use Test::More;
use Test::Exception;
use Data::Dump ();
use Data::Dumper;
use JSON::Parse 'json_to_perl';
use strict;

my %rabbit = do 'myrabbitconfig.pl';

print $rabbit{'rabbit_host'};
print "\n";
print $rabbit{'rabbit_port'};
print "\n";
print $rabbit{'rabbit_port'};
print "\n";
print $rabbit{'rabbit_vhost'};

my $fnMylog = "mylog.txt";
my $FILE;	

my $fn = "read.txt"; #default
my $MYFILE;	
if ($#ARGV+1 > 0 ) {
	$fn = $ARGV[0];
}

my $cv = AnyEvent->condvar;
my $ar = AnyEvent::RabbitMQ->new();

my %server = (
    product => undef,
    version => undef,
);

##my $mypath    ='perl .';
my $mypath    ='perl ./perl';

my ($host, $port, $user, $pass, $vhost);


 $host  = $rabbit{'rabbit_host'};
 $port  = $rabbit{'rabbit_port'};
 $user  = $rabbit{'rabbit_user'};
 $pass  = $rabbit{'rabbit_pass'};
 $vhost = $rabbit{'rabbit_vhost'};

 
print "\n--------------\n";
print $user;
print "\n";
print $vhost;


if ($ENV{'VCAP_SERVICES'})
{
   # Extract and convert the JSON string in the VCAP_SERVICES environment var$
   my $vcap_services = json_to_perl ($ENV{'VCAP_SERVICES'});
print "\nasdfasfasdfasdf\nasdfasfasdfasf\n";
   $host  = $vcap_services->{'rabbitmq'}[0]{'credentials'}{'host'};
   $port  = $vcap_services->{'rabbitmq'}[0]{'credentials'}{'port'};
   $user  = $vcap_services->{'rabbitmq'}[0]{'credentials'}{'user'};
   $pass  = $vcap_services->{'rabbitmq'}[0]{'credentials'}{'pass'};
   $vhost = $vcap_services->{'rabbitmq'}[0]{'credentials'}{'vhost'};
}

my %conf = (
    host  => $host,  #$rabbit{'rabbit_host'},
    port  => $port,  #$rabbit{'rabbit_port'},
    user  => $user,  #$rabbit{'rabbit_user'},
    pass  => $pass,  #$rabbit{'rabbit_pass'},
    vhost => $vhost, #$rabbit{'rabbit_vhost'},
);


lives_ok sub {
    $ar->load_xml_spec()
}, 'load xml spec';

#1
my $done = AnyEvent->condvar;
$ar->connect(
    (map {$_ => $conf{$_}} qw(host port user pass vhost)),
    timeout    => 1,
    on_success => sub {
        my $ar = shift;
        #isa_ok($ar, 'AnyEvent::RabbitMQ');
        $server{product} = $ar->server_properties->{product};
        $server{version} = version->parse($ar->server_properties->{version});
        $done->send;
    },
    on_failure => \&failure_cb($done),
    on_close   => sub {
        my $method_frame = shift->method_frame;
        die $method_frame->reply_code, $method_frame->reply_text;
    },
);

$done->recv;
#2
$done = AnyEvent->condvar;
my $ch;
$ar->open_channel(
    on_success => sub {
        $ch = shift;
        isa_ok($ch, 'AnyEvent::RabbitMQ::Channel');
        $done->send;
    },
    on_failure => \&failure_cb($done),
    on_close   => sub {
        my $method_frame = shift->method_frame;
        die $method_frame->reply_code, $method_frame->reply_text;
    },
);
$done->recv;

$done = AnyEvent->condvar;
$ch->declare_exchange(
    exchange   => 'test_x',
    on_success => sub {
        #pass('declare exchange');
        $done->send;
    },
    on_failure => \&failure_cb($done),
);
$done->recv;

$done = AnyEvent->condvar;
$ch->declare_queue(
    queue      => 'test_q',
    on_success => sub {
        #pass('declare queue');
        $done->send;
    },
    on_failure => \&failure_cb($done),
);
$done->recv;

$done = AnyEvent->condvar;
$ch->bind_queue(
    queue       => 'test_q',
    exchange    => 'test_x',
    routing_key => 'test_r',
    on_success  => sub {
        #pass('bound queue');
        $done->send;
    },
    on_failure => \&failure_cb($done),
);
$done->recv;

####################################
####################################
my $msg;

#for (my $ii=0; $ii<5; $ii++)

#while(1)
{
$done = AnyEvent->condvar;

my $consumer_tag;

#=comment

$ch->consume(
	queue      => 'test_q',
	no_ack     => 1,
#	no_ack     => 0,

	on_consume => \&work_cb,
    on_failure => failure_cb($done),
);

#print __FILE__."(". __LINE__ .  ")  ". localtime(). "\n";
$done->recv;
#$done->send;
} #end for


# Wait forever
#print __FILE__."(". __LINE__ .  ")  ". localtime(). "\n";
AnyEvent->condvar->recv;
#print __FILE__."(". __LINE__ .  ")  ". localtime(). "\n";

exit(0);

sub failure_cb {
    my ($cv,) = @_;
    return sub {
        fail(join(' ', 'on_failure:', @_));
		print __FILE__."(". __LINE__ .  ")  ". localtime(). "\n";
        $cv->send;
		exit;
    };
}

sub qos_cb
{
	my $response = shift;
	print Data::Dump::dump($response), "\n";
}

sub qos_fail
{
	my $response = shift;
	print Data::Dump::dump($response), "\n";
	print __FILE__."(". __LINE__ .  ")  ". localtime(). "\n";
	exit;
}


sub work_cb {
	my $response = shift;
	$msg = $response->{body}->payload;
	
	my $delivery_tag = "fuck ";#$response->{deliver}->{method_frame}->delivery_tag;

=comment	
	print ("\t delivery_tag = ", $delivery_tag, "\n");
	print ("\t", $response->{header}->timestamp, "\n");
	print ("\n______________________\n");

	print Data::Dump::dump($response), "\n";
=cut
#    my @c = $msg =~ /\./g;
#	printf("\ncnt = %d\n",  scalar(@c));
#    sleep(scalar(@c));
	#sleep(scalar(2));

	# FM 11/8/12
	open ($FILE, "+>>", $fnMylog) or die "can not open($fnMylog)$!";
  #print FILE "rightnow YIKES ... \n";
  
	#

	#open (MYFILE, '>>$fn');
	open($MYFILE, q{>}, "$fn") || die print "can not open($fn)$!";
	print $MYFILE $msg .  "\n";
	
    print $FILE Data::Dump::dump($response). "\n<END/>\n";
    close ($FILE);

	close ($MYFILE);
#	print __FILE__."(". __LINE__ .  ")  ". localtime(). "\n";

	# mailbee
	# perl rabbit_jm002.pl msg22.txt
print "does this tell you the cwd? $0\n";
	my $pipes;
	$pipes = "$mypath/rabbit_jm002.pl $fn|".
        "";
print "$pipes\n";

        if($pipes)
	{
		my $FMAIL;
		#print "\n<br/>$pipes<br/>\n";
		open($FMAIL, $pipes);
   		while(<$FMAIL>){
      			print $_; # Print output if you like
	   	}
   		close($FMAIL);
	}

#	$ch->ack(delivery_tag => $response->{deliver}->method_frame->delivery_tag);
	#$done->send;
}
