#!/usr/bin/perl 
# -*- mode: Perl; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*-

use strict;
use warnings; 
use Data::Dumper qw(Dumper);
use Time::HiRes qw( gettimeofday );
use Getopt::Long;
use File::Path qw(make_path);


my $verbose = 0;
my $errorcount=0;
my $help;
my $genDebug = 0;
my $src_dir = "Source/Android/Amoeba/app/src/main/res/";

my @LANGS=();

sub pdev {
    my ($msg) = @_;   
    print $msg;
}

sub perror {
    my ($msg) = @_;   
    $errorcount++;
    print "#ERROR# $msg";
}

sub pwarn {
    my ($msg) = @_;   
    print $msg;
}

sub pinfo {
    my ($msg) = @_;   
    if($verbose>=1){
        print $msg;
    }
}

sub pdebug {
    my ($msg) = @_;   
    if($verbose>=2){
        print $msg;
    }
}

sub pspam {
    my ($msg) = @_;   
    if($verbose>=3){
        print $msg;
    }
}

sub ltrim { my $s = shift; $s =~ s/^\s+//;       return $s };
sub rtrim { my $s = shift; $s =~ s/\s+$//;       return $s };
sub  trim { my $s = shift; $s =~ s/^\s+|\s+$//g; return $s };

sub pultraspam {
    my ($msg) = @_;   
    if($verbose>=4){
        print $msg;
    }
}

sub toUpperAndUnder {
    my ($str) = @_;   
    $str =~ s/([a-z])([A-Z])/$1_$2/g;
    return uc($str);
}

sub Usage {
    print "\n";
    print "Usage: webtrans.pl [OPTIONS]  <targetNr>\n";
    print "\n";
    print "    Options:\n";
    print "        --mediariterootdir=<thedir>\n";
    print "        --debug=<0|1>\n";
    print "        --verbose=<0|1|..>\n";
    print "        --help\n";
    print "\n";    
    exit 1;
}


GetOptions("debug=i" => \$genDebug,
           "verbose=i" => \$verbose,
           "help" => \$help);

my $prodNr = $ARGV[0];

if(!$prodNr || $prodNr eq ""){
    Usage();
}

if ($help) {
    Usage();
}


# <string name="cancelled">"Afbrudt"</string>

sub ParseXmlTranslationDir {
    my ($some_dir) = @_;   
    pspam "  ParseCmlTranslationDir $some_dir\n";
    opendir(my $dh, $some_dir) || die "$!\n";
    while(readdir $dh) {
        if( $_ eq "." || $_ eq ".."){
            # skip
        } elsif ( -d "$some_dir/$_" ) {
            ParseXmlTranslationDir("$some_dir/$_");
        } elsif ($_ =~ /^strings.xml$/) {
	    my $languageCode = "";
	    my $isMaster = 1;
	    if($some_dir=~/values-([a-z][a-z])$/){
		my ($_lang) = ($1);
		$languageCode = $_lang;
		$isMaster = 0;
	    }	    
            ParseXmlTranslationFile($isMaster,$languageCode,"$some_dir/$_");
        }
    }
    closedir $dh;
}



sub ParseXmlTranslationFile {
    my ($isMainFile,$languageCode, $some_file) = @_;

    if($isMainFile){       
	# We use en for now
	return;
    }

    push(@LANGS,$languageCode);
    
    pdev "ParseXmlTranslationFile $isMainFile,$languageCode, $some_file\n";
    open(IFILE, $some_file) || die "Can't open $! $some_file";
    my @thefile = <IFILE>;
    close IFILE or die "Error '$some_file':$!";

    my $lineno = 0;
    my $code = "";
    my $stringInProgress = 0;
    my $key = "";
    my $valueContent = "";
    foreach my $line(@thefile) {	
        $lineno++;
	
	if ($line=~/^<string\s*name=\"([^\"]*)\">\"(.*)/) {
	    $stringInProgress = 1;
	    my ($_key,$rest) = ($1,$2);
	    $key = $_key;
	    if ($rest=~/(.*)\"<\/string>$/) {
		my ($value) = ($1);
		$stringInProgress = 0;
		$code .= "$key = $value\n";
	    } else {
		$rest =~ s/(.*)$/$1\\n/;
		$valueContent = $rest;
	    }		
	} elsif ($stringInProgress) {
	    if ($line=~/(.*)\"<\/string>$/) {
		my ($moreContent) = ($1);
		$valueContent .= $moreContent;
		$stringInProgress = 0;
		$code .= "$key = $valueContent\n";
	    } else {
		$line =~ s/(.*)$/$1\\n/;
		$valueContent .= $line;
	    }	
	}
    }

    my $fh;
    my $dst_dir = "Resource/Gui/${prodNr}/tv-gateway-web/bundle/";

    make_path $dst_dir;
    my $dst_file = $dst_dir."/Messages.properties";
    if($isMainFile==0){
	$dst_file = $dst_dir."/Messages_${languageCode}.properties";
    }
	
    open($fh, '>', $dst_file) || die "Failed to open ".$dst_file;
    print $fh $code;
    close $fh;

    # Make main from en
    if($languageCode eq "en"){
	$dst_file = $dst_dir."/Messages.properties";
	open($fh, '>', $dst_file) || die "Failed to open ".$dst_file;
	print $fh $code;
	close $fh;
    }
}


sub writeJson(){
    my $code = "";
    $code .= "{\n";
    $code .= "        \"languages\": [\n";
    my $doSep = 0;
    foreach my $lang (sort @LANGS) {       
	if($doSep){
	    $code .= ",\n";
	}
	$code .= "                \"$lang\"";
	$doSep = 1;
	
    }
    $code .= "\n";
    $code .= "        ]\n";
    $code .= "}\n";

    my $fh;
    my $dst_dir = "Resource/Gui/${prodNr}/tv-gateway-web/bundle/";
    my $dst_file = $dst_dir."/languages.json";

    open($fh, '>', $dst_file) || die "Failed to open ".$dst_file;
    print $fh $code;
    close $fh;

}


ParseXmlTranslationDir($src_dir);
writeJson();
