#!PERLPATH
#
#	skkconv - $B%3%^%s%I%i%$%s$G$N%m!<%^;z4A;zJQ49(B
#
#		1990	5/20	$BA}0f=SG7(B
#		1990	12/17	$BA}0f=SG7(B
#				$B%3!<%IJQ49%i%$%V%i%j$r;H$&$h$&JQ99(B
#
eval "exec PERLPATH -S $0 $*"
	if $Shell_cannot_understand;
($program) = ($0 =~ m#([^/]+)$#);

if($#ARGV < 0){
	print stderr "$program -- Convert Romaji string to Kanji\n";
	print stderr "  usage: $program romajistring\n";
	exit 0;
}

#
#	Loading code-conversion libraries
#

require "codeconv.pl";
require "roma2kana.pl";

#
#	Communication between SKK server
#

$skkserver = $ENV{'SKKSERVER'};
if($skkserver eq ''){
	print stderr "Environ variable SKKSERVER not set\n";
	exit 0;
}
chop($hostname = `hostname`);
$SIG{'INT'} = 'dokill';

($name, $aliases, $type, $len, $thisaddr) = gethostbyname($hostname);
($name, $aliases, $type, $len, $thataddr) = gethostbyname($skkserver);

$port = 1178; # SKK port#

$sockaddr = 'S n a4 x8';
$this = pack($sockaddr, 2, 0, $thisaddr);
$that = pack($sockaddr, 2, $port, $thataddr);

socket(S, 2, 1, 0) || die "socket: $!";
bind(S, $this) || die "bind: $!";
connect(S, $that) || die "connect: $!";

select(S); $| = 1; select(stdout);

sub dokill {
	kill 9, $child if $child;
}

if($child = fork){
	while(<S>){
		chop;
		if(s/^1\///){
			s/\//\n/g;
			print &ujis2jis($_);
		}
	}
}
else {
	print S "1", &roma2kana($ARGV[0]), " ";
	print S "0";
}

