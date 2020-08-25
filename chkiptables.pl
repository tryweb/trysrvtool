#!/usr/bin/perl
# Check iptables rules change 
# 13:32 2016/4/8
# ver 1.04
# Jonathan Tsai <tryweb@ichiayi.com>
# 
use Mail::Sendmail;  # Ref - http://search.cpan.org/~mivkovic/Mail-Sendmail-0.79/Sendmail.pm

$g_prgname = substr($0, rindex($0,'/')+1);
$g_prgpath = substr($0, 0, rindex($0,'/'));
$g_ver = "1.04 (2016/4/8)";
$p_config = !defined($ARGV[0])?"/opt/trysrvtool/chkiptables.conf":$ARGV[0];

$conf_refFile = '/tmp/ipt.log';
$conf_toMail = 'tryweb@ichiayi.com';
$conf_fromMail = 'tryweb@ichiayi.com';
$conf_chkCmd = '/sbin/iptables --list -n';
if (-e $p_config) {
	require($p_config);
}

$g_hostname = `/bin/hostname`;
$g_hostname =~ s/\n|\r//g;

$v_nowdatetime = the_datetime(time);
`$conf_chkCmd > $conf_refFile.1`;
if (!-e $conf_refFile) {
	`/bin/cp $conf_refFile.1 $conf_refFile`;
	print $v_nowdatetime."	$g_prgname ($g_ver) Init. $conf_refFile\n";
	exit;
}

$v_chkResult = `/usr/bin/diff $conf_refFile.1 $conf_refFile`;
if ($v_chkResult ne '') {
	`/bin/cp $conf_refFile.1 $conf_refFile`;
	print $v_nowdatetime."	$g_prgname ($g_ver) Warning...\n-----\n	".$v_chkResult."\n-----\n";
	%mail = ( To      => $conf_toMail,
            From    => $conf_fromMail,
			Subject => $g_hostname.' iptables Changed!',
			'X-Mailer' => "Mail::Sendmail version $Mail::Sendmail::VERSION",
            Message => $v_nowdatetime."	$g_prgname ($g_ver) Warning...\n-----\n	".$v_chkResult."\n-----\n"
           );

  if (sendmail %mail) { print "Mail sent OK.\n" }
  else { print "Error sending mail: $Mail::Sendmail::error \n" }
  print "\n\$Mail::Sendmail::log says:\n", $Mail::Sendmail::log;
  print "\n";
}
exit;

sub the_datetime {
  local($p_sec_vaule) = @_;
  local(@t_datetime, $i);

  @t_datetime = localtime($p_sec_vaule);
  $t_datetime[4] ++;
  $t_datetime[5] += 1900;

  for($i=0; $i<6; $i++) {
    if (length($t_datetime[$i]) == 1) {
      $t_datetime[$i] = "0".$t_datetime[$i];
    }
  }
  return($t_datetime[5].$t_datetime[4].$t_datetime[3].$t_datetime[2].$t_datetime[1]);
}
