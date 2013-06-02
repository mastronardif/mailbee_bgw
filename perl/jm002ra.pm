package jm002ra;
use CGI qw(:standard escapeHTML);
use JSON; # imports encode_json, decode_json, to_json and from_json.
#use AnyEvent::RabbitMQ;
use Net::RabbitFoot;
use Test::More;
use Test::Exception;
use JSON::Parse 'json_to_perl';
use Data::Dumper::Perltidy;
use strict;

sub RabbitFootPublish
{
	my $msg = shift;
	my $retval = "wtf";
	
	my ($host, $port, $user, $pass, $vhost);
	
	if ($ENV{'VCAP_SERVICES'}) 
{
   # Extract and convert the JSON string in the VCAP_SERVICES environment var$
   my $vcap_services = json_to_perl ($ENV{'VCAP_SERVICES'});

   $host  = $vcap_services->{'rabbitmq'}[0]{'credentials'}{'host'};
   $port  = $vcap_services->{'rabbitmq'}[0]{'credentials'}{'port'};
   $user  = $vcap_services->{'rabbitmq'}[0]{'credentials'}{'user'};
   $pass  = $vcap_services->{'rabbitmq'}[0]{'credentials'}{'pass'};
   $vhost = $vcap_services->{'rabbitmq'}[0]{'credentials'}{'vhost'};

my $conn = Net::RabbitFoot->new()->load_xml_spec()->connect(
    host =>  $host,
    port =>  $port,
    user =>  $user,
    pass =>  $pass,
    vhost => $vhost,
);

my $chan = $conn->open_channel();

$chan->publish(
	queue       => 'test_q',
    exchange    => 'test_x',
    routing_key => 'test_r',
    body => $msg,
);

$retval = " [x] Sent 'Hello World!'\n";

$conn->close();


}	
return $retval;

}

sub makeReplyFromMailGun
{
	my($query) = @_;
	my $retval = "from Mailgun\n";
#	 print Dumper $query;

	my $subject = $query->param('Subject') || "";
  
#  my $Action = 'DECORATE'; #default Decorate or Joemailweb
#  if ($subject =~ m/joemailweb/i)
#  {
#     $Action = 'JOEMAILWEB';
#  }

     my $buf;
     $buf = "";
     #my $header = $query{'message-headers'};
	 my $header = $query->param('message-headers');

	 my @decoded_json = @{decode_json($header)};

	 $retval .= "\n<MYMAIL>\n<HEADER>\n";

	 my $mailheader;
	foreach my $item(@decoded_json )
	{
    	my @FFF = ($item);
		   
		# Create the reply header. see testmymbox03.pl
		# From: become To:
		# Todo reomve whitelist from the Cc: field

		if ($FFF[0][0] =~ /^Message-Id$/i)
		{
			$retval .=  "$FFF[0][0]: fm $FFF[0][1]\n";
			next;
		}

		#Make the reply - To: is set to original sernder, From: is set to orignal joemail host.
		if ($FFF[0][0] =~ m/^From$/i)
		{
			my $recp = $query->param('recipient'); # "joemail\@joeschedule.com"; #$query->param('recipient');
			$retval .=  "$FFF[0][0]:  $recp \n";
			next;
		}

		if ($FFF[0][0] =~ m/^To$/i)
		{
			my $sender =  $query->param('sender');
			$retval .=  "$FFF[0][0]:  $sender\n";
			next;
		}
           $mailheader .= "$FFF[0][0]: $FFF[0][1]\n";
    };

   #my $Reply
   # I don't know for some reason mailgun does not set this filed.
   $mailheader .= 'Content-Type: text/html; charset="UTF-8"';

   $retval .=  "$mailheader\n";
   $retval .=  "\n</HEADER>\n";

   my $body = $query->param('body-html');
   if (!$body){
      $body = $query->param('body-plain');
   }

   $retval .=  $body;

   $retval .=  "\n</MYMAIL>\n";
  
  return $retval;
}


sub reply {
   my($query) = @_;
   my(@values,$key);
   my $retval;

    my $header =  $query->param('message-headers');
	if ($header)
	{
		return makeReplyFromMailGun($query);
		#return makeReplyFromMailGun(CGI->new($query) );
		#$query = CGI->new(INPUTFILE);
	}
	
    my %flds;
	my $fldnms = "To From Subject body-plain";
	foreach (qw(To From Subject body-plain)) {
		$flds{$_} = 1;
	};
	my $iMailFlds = 0;
   
   foreach my $key ($query->param) {
	$retval .=  "<STRONG>$key</STRONG> -> ";
	
	my @list = $query->param($key);
	my $list = join(", ",@list);
	
	if ( UNIVERSAL::isa($list,'ARRAY') )
	{
		my @values = $query->param($key);
		$list = "";
		foreach (@values) {
			my $f =  $_;
			$list .= join ", ", @$f ;
		}
	}
	
	#if (m/To|From|Subject|Body/i)
	#if (exists $flds{$key})
	if (exists $flds{$key})
	{
		$iMailFlds++;
		$flds{$key} = $list;
		#$flds{$_} = $list;
	}
	
    $retval .= $list ."\n";
  }	

   if (keys( %flds ) == $iMailFlds)
   {
        #$retval = "";
        #foreach ( split(' ',$fldnms))
        #{
        #   $retval .= $_ . ": " . $flds{$_} . "\n";
        #}
my $ret = <<EOF;

<MYMAIL>
<HEADER>
From: $flds{'To'}
To: $flds{'From'}
Subject: $flds{'Subject'}

</HEADER>
$flds{'body-plain'}

</MYMAIL>
EOF
    return $ret;
   }
   	return $retval;
}

sub sendtogmail
{
	my $tagValue =  shift;
	

my $retval = <<EOF;	
<MYMAIL>
<HEADER>
From: jimmy\@joeschedule.mailgun.org
To: Frank Mastronardi <mastronardif\@gmail.com>
Subject: dancer bee joemailweb
In-Reply-To: <CAAAKxgKEqWkQ_v3kPRhY+3ATgM1ePYcCLtv+-1qtT3T=s=AYsAmail.gmail.com>
References: <CAAAKxgKEqWkQ_v3kPRhY+3ATgM1ePYcCLtv+-1qtT3T=s=AYsAmail.gmail.com>
Message-Id: <FU uddy mailbox-19950-1311902078-753076ww3.pairlite.com>
Date: Thu, 13 Oct 2011 21:14:38 -0400
MIME-Version: 1.0
Content-Type: text/html; charset="UTF-8"

</HEADER>

<tags>
'$tagValue'
</tags>

</MYMAIL>	
EOF

	return $retval;
}

1;
