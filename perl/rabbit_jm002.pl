#!/usr/bin/perl -w
use CGI qw(:standard escapeHTML);
use IO::String;
use JSON; # imports encode_json, decode_json, to_json and from_json.
#Last Modified: June 2, 2012

########use strict "vars";
use warnings;

print "Content-type: text/html\n\n";

my $query = new CGI;

my $debug = $query->param('debug') || "";

my $myOutpath= '.'; ##'/usr/home/pl1321/JSAdmin/log';
##my $mypath    ='perl .'; # 'perl /usr/www/users/pl1321/cgi-bin';
my $mypath    ='perl ./perl'; # 'perl /usr/www/users/pl1321/cgi-bin';

my $fn =  "$myOutpath/cloudmail.txt";
my $fnMsg = $ARGV[0] || "msg.txt";

#print $fnMsg;
#exit;


#my $fnMailGun =  "$myOutpath/mailgun.txt";
#my $fnMail="$mypath/mailgun.txt";

my $qs;
# FM 4/30/12 my $GUN = IO::String->new($qs);
#$qs = "FFFFFFFFFFFFFFFFFFFFFFFF";
our  $GUN = IO::String->new($qs);


$debug=102;
# FM 44/30/12 my $DBG;
our $DBG;
if ($debug)
{
     open($DBG, ">>$fn") || die print "can not open($fn)$!";
	 
	 print $DBG "\$fnMsg = $fnMsg";
	 
     print $DBG "\n***\nlocaltime: ". localtime() ."\n";
###	 exit;
}

#&reply($query);

if ($debug)
{

print $qs;
#print ("<br/>F(12)\n\$qs = $qs\n");
##if ($DBG){ close($DBG); }
#exit;
}

#$ENV{'WTF'} = $qs;

if ($DBG)
{
   close($DBG);
}
 
   #my $pipes = #"|$mypath/jm002a.pl".
   #"|echo '$qs'";
   
   print __FILE__."(". __LINE__ .  ")  ". localtime(). "\n";
#my $pipes = "|echo '$qs".
my $pipes;

#my $action = $query->param('subject') || "joeping";   
# check subject line for sw/
print $fnMsg; #exit;
my $action = "joemailweb" || "FUCK not there"; 

#=comment
$fnMsg = "$myOutpath/".$fnMsg;
open FILE, "$fnMsg" or die "Couldn't open file: $!"; 
$string = join("", <FILE>); 
close FILE;
$string =~ /(subject: .*)/i;
$action = $1 || "FUCK not there"; 
#=cut

#print $action; exit;

#my $action = "joemailweb";   

if ($action =~ m/joemailweb/i)
{
#$pipes = "$mypath/jm002a.pl".
#$pipes = "$mypath/rabbit_jm002a.pl".
$pipes = "$mypath/rabbit_jm002a.pl $fnMsg".
         "|$mypath/mgexp.pl".
         "|$mypath/mgexptags.pl".
         "|$mypath/mghtoe.pl".
         "|$mypath/mgsend.pl|";
#         "|";
}
#elsif ($action =~ m/joeping/i)
else
{
$pipes = "$mypath/rabbit_jm002a.pl $fnMsg".
         "|$mypath/mghtoe.pl".
         "|$mypath/mgsend.pl|";
#		 "";
}


=comment
else
{

   print "Content-type: text/html\n\n";
   print "no pipes to choose.";
   print "action=$action";
}
=cut
if($pipes)
{
   my $FMAIL;
#print "\n<br/>$pipes<br/>\n";
   open($FMAIL, $pipes);
#exit;
   while(<$FMAIL>){
      print $_; # Print output if you like
   }
   close($FMAIL);
   print "<hr>222<hr>";
}

print "\n***\n inside[$0] <br/>END localtime: ".  localtime() ." PHASE -1 \n";

# plack dont like this exit 1;
##exit;
#my $fnMail="$mypath/mailgun.txt";
#open(MSG, $fnMailGun) or die "Can't open $fnMailGun: $!\n";
#   my @lines = <MSG>;
#   close(MSG);
#my $buf = join "", @lines; print $buf; exit;



sub reply {
   my($query) = @_;
   my @values;

  my $subject = $query->param('Subject') || "";
#  my $Action = 'DECORATE'; #default Decorate or Joemailweb
#  if ($subject =~ m/joemailweb/i)
#  {
#     $Action = 'JOEMAILWEB';
#  }

   print "<H2>Wat you wrote(2):</H2>";

   my $mail="";
   my $bFirstRow=0;
   foreach my $key ($query->param) {
      print "<STRONG>$key</STRONG> -> ";
      @values = $query->param($key);
      print join(", ",@values),"<hr />\n";

      #my $fff=join(", ",@values);
      #$mail .= "$key ->" . join(", ",@values);
      if ($bFirstRow || $bFirstRow++)
      {
         $mail .="\n";
      }
      $mail .= "$key -> \n\t" . join(", ",@values);
  }
if ($DBG)
{
   if ($mail)
   {
      print $DBG "\n$mail\n"; 
      
      #$ENV{'WTF'} = 'what the _____? set from jm002'.$mail;
   }
}

  {

    # joemailweb call

  if (1==1)
  {
     my $buf;
     $buf = "";
     my $header = $query->param('message-headers');
     if ($header)
     {
        #open(GUN, ">$fnMailGun") || die print "can not open($fnMailGun)$!";
        #print $GUN $header;
        #print $GUN "\n***\nlocaltime: ". localtime() ."\n";

	    my @decoded_json = @{decode_json($header)};

       	#print "\n<MYMAIL>\n<HEADER>\n";
       	print $GUN "\n<MYMAIL>\n<HEADER>\n";

        my $mailheader;
	foreach my $item(@decoded_json ){
    	my @FFF = ($item);
		   
# Create the reply header. see testmymbox03.pl
# From: become To:
# Todo reomve whitelist from the Cc: field

if ($FFF[0][0] =~ /^Message-Id$/i)
{
   #print  "$FFF[0][0]: fm $FFF[0][1]\n";
   print  $GUN "$FFF[0][0]: fm $FFF[0][1]\n";
   next;
}

#Make the reply - To: is set to original sernder, From: is set to orignal joemail host.
if ($FFF[0][0] =~ m/^From$/i)
{
   my $recp = $query->param('recipient'); # "joemail\@joeschedule.com"; #$query->param('recipient');
   #print  "$FFF[0][0]:  $recp \n";
   print $ GUN "$FFF[0][0]:  $recp \n";
   next;
}

if ($FFF[0][0] =~ m/^To$/i)
{
   my $sender =  $query->param('sender');
   #print  "$FFF[0][0]:  $sender\n";
   print  $GUN "$FFF[0][0]:  $sender\n";
   next;
}
           #print "$FFF[0][0]: $FFF[0][1]\n";
           $mailheader .= "$FFF[0][0]: $FFF[0][1]\n";
        };

   #my $Reply
   # I don't know for some reason mailgun does not set this filed.
   $mailheader .= 'Content-Type: text/html; charset="UTF-8"';

   #print "$mailheader\n";
   print $GUN "$mailheader\n";

    #print "\n</HEADER>\n";
    print $GUN "\n</HEADER>\n";

        #print($header);
   #print "\n WTF Dude you piped it(94). :)\n";
   #print GUN $query->param('stripped-text');
   #print GUN $query->param('body-plain');
   my $body = $query->param('body-html');
   if (!$body){
      $body = $query->param('body-plain');
   }

   #print $body;
   print $GUN $body;

   #print "\n</MYMAIL>\n";
   print $GUN "\n</MYMAIL>\n";

#    close(GUN);
     }

  }

  }
print $GUN "\nFrom jm002.pl ************\n";
}
