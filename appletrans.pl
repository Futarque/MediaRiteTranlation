#!/usr/bin/perl 
# -*- mode: Perl; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*-

use strict;
use warnings; 
use Data::Dumper qw(Dumper);
use Time::HiRes qw( gettimeofday );
use Getopt::Long;
use File::Path qw(make_path);
use File::Copy;

my $verbose = 0;
my $errorcount=0;
my $help;
my $genDebug = 0;
my $src_dir = "Source/Android/Amoeba/app/src/main/res/";

my @LANGS=();
my %TRANS=();
my %KEYMAP=();
my %APPLE=();
my $parseIteration = 0;


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
    print "Usage: appletrans.pl [OPTIONS]  <rootOfMediaRite> <project>\n";
    print "\n";
    print "    Options:\n";
    print "        --debug=<0|1>\n";
    print "        --verbose=<0|1|..>\n";
    print "        --help\n";
    print "\n";    
    exit 1;
}


GetOptions("debug=i" => \$genDebug,
           "verbose=i" => \$verbose,
           "help" => \$help);

my $rootOfMediaRite = $ARGV[0];
if(!$rootOfMediaRite || $rootOfMediaRite eq ""){
    Usage();
}

my $project = $ARGV[1];
if(!$project || $project eq ""){
    Usage();
}


if ($help) {
    Usage();
}

my $dst_dir = "${rootOfMediaRite}/Source/Apple/${project}/";


# <string name="cancelled">"Afbrudt"</string>

sub ParseXmlTranslationDir {
    my ($some_dir) = @_;   
    pspam "  ParseXmlTranslationDir $some_dir\n";
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
    
    pspam "ParseXmlTranslationFile $isMainFile,$languageCode, $some_file\n";
    open(IFILE, $some_file) || die "Can't open $! $some_file";
    my @thefile = <IFILE>;
    close IFILE or die "Error '$some_file':$!";

    my $lineno = 0;
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
                $value =~ s/"/\\"/g;
                $TRANS{$languageCode}{data}{$key} = $value;
                if($languageCode eq "en"){
                    $KEYMAP{$value} = $key;
                }
            } else {
                $rest =~ s/(.*)$/$1\\n/;
                $valueContent = $rest;
            }		
        } elsif ($stringInProgress) {
            if ($line=~/(.*)\"<\/string>$/) {
                my ($moreContent) = ($1);
                $valueContent .= $moreContent;
                $stringInProgress = 0;
                $valueContent =~ s/"/\\"/g;
                $TRANS{$languageCode}{data}{$key} = $valueContent;
                if($languageCode eq "en"){
                    $KEYMAP{$valueContent} = $key;
                }
            } else {
                $line =~ s/(.*)$/$1\\n/;
                $valueContent .= $line;
            }	
        }
    }
}


sub ProcessAppleTranslationDir {
    my ($languageCode,$top_dir,$some_dir) = @_;   
    pspam "  ProcessAppleTranslationDir $languageCode $some_dir\n";
    opendir(my $dh, $some_dir) || die "$!\n";
    while(readdir $dh) {
        if( $_ eq "." || $_ eq ".."){
            # skip
        } elsif ($_ =~ /.strings$/) {
            if($parseIteration==0){
                ProcessAppleTranslationFileStage1($languageCode,$top_dir,$_,"$some_dir/$_");
            } elsif($parseIteration==1){
                ProcessAppleTranslationFileStage2($languageCode,$top_dir,$_,"$some_dir/$_");
            }    
        }
    }
    closedir $dh;
}

sub ProcessAppleProjectDir {
    my ($some_dir) = @_;   
    pspam "  ProcessAppleProjectDir $some_dir\n";
    opendir(my $dh, $some_dir) || die "$!\n";
    while(readdir $dh) {
        if( $_ eq "." || $_ eq ".."){
            # skip
        } elsif ( -d "$some_dir/$_" ) {
            if($_=~/^([a-z][a-z]).lproj$/){               
                ProcessAppleTranslationDir($1,$some_dir,"$some_dir/$_");
            } else {           
                ProcessAppleProjectDir("$some_dir/$_");
            }
        }
    }
    closedir $dh;
}


sub ProcessAppleTranslationFileStage1 {
    my ($languageCode, $top_dir, $file_name, $some_file) = @_;
    pdev "ProcessAppleTranslationFile $languageCode $top_dir $file_name $some_file\n";
    $APPLE{$top_dir}{files}{$file_name}{languages}{$languageCode}{file} = $some_file;
    if($languageCode eq "en"){

        open(IFILE, $some_file) || die "Can't open $! $some_file";
        my @thefile = <IFILE>;
        close IFILE or die "Error '$some_file':$!";
        
        my $lineno = 0;
        my $stringInProgress = 0;
        my $key = "";
        my $valueContent = "";
        foreach my $line(@thefile) {	
            $lineno++;
            
            if ($line=~/^\"([^\"]*)\" = \"(.*)/) {
                $stringInProgress = 1;
                my ($_key,$rest) = ($1,$2);
                $key = $_key;
                if ($rest=~/(.*)\";$/) {
                    my ($value) = ($1);
                    $stringInProgress = 0;
                    $APPLE{$top_dir}{files}{$file_name}{keymap}{$key} = $value;
                } else {
                    $rest =~ s/(.*)$/$1\\n/;
                    $valueContent = $rest;
                }		
            } elsif ($stringInProgress) {
                if ($line=~/(.*)\";$/) {
                    my ($moreContent) = ($1);
                    $valueContent .= $moreContent;
                    $stringInProgress = 0;
                    $APPLE{$top_dir}{files}{$file_name}{keymap}{$key} = $valueContent;
                } else {
                    $line =~ s/(.*)$/$1\\n/;
                    $valueContent .= $line;
                }	
            }
        }      
    }
    

    # my $fh;

    # make_path $dst_dir;
    # my $dst_file = $dst_dir."/master.strings";
    # if($isMainFile==0){
    #     $dst_file = $dst_dir."/${languageCode}.strings";
    # }
	
    # open($fh, '>', $dst_file) || die "Failed to open ".$dst_file;
    # print $fh $code;
    # close $fh;
}

sub ProcessAppleTranslationFileStage2 {
    my ($languageCode, $top_dir, $file_name, $some_file) = @_;    

    pdev "ProcessAppleTranslationFileStage2 $languageCode $top_dir $file_name $some_file\n";

    move($some_file,"$some_file.tmp");

    open(IFILE, "$some_file.tmp") || die "Can't open $! $some_file";
    my @thefile = <IFILE>;
    close IFILE or die "Error '$some_file':$!";
    unlink("$some_file.tmp");

    my $lineno = 0;
    my $stringInProgress = 0;
    my $key = "";
    my $valueContent = "";
    my $code = "";
    foreach my $line(@thefile) {	
        $lineno++;
        
        if ($line=~/^\"([^\"]*)\" = \"(.*)/) {
            $stringInProgress = 1;
            my ($_key,$rest) = ($1,$2);
            $key = $_key;
            if ($rest=~/(.*)\";$/) {
                my ($value) = ($1);
                $stringInProgress = 0;                
                my $mappedKey = $KEYMAP{$APPLE{$top_dir}{files}{$file_name}{keymap}{$key}};
                if($mappedKey) {
                    $code .= "\"${key}\" = \"$TRANS{$languageCode}{data}{$mappedKey}\";\n";
                } else {
                    $code .= "\"${key}\" = \"$value\";\n";
                }
            } else {
                $rest =~ s/(.*)$/$1\\n/;
                $valueContent = $rest;
                }		
        } elsif ($stringInProgress) {
            if ($line=~/(.*)\";$/) {
                my ($moreContent) = ($1);
                $valueContent .= $moreContent;
                $stringInProgress = 0;
                $APPLE{$top_dir}{files}{$file_name}{keymap}{$key} = $valueContent;
                my $mappedKey = $KEYMAP{$APPLE{$top_dir}{files}{$file_name}{keymap}{$key}};
                if($mappedKey) {
                    $code .= "\"${key}\" = \"$TRANS{$languageCode}{data}{$mappedKey}\";\n";
                } else {
                    $code .= "\"${key}\" = \"$valueContent\";\n";
                }
            } else {
                $line =~ s/(.*)$/$1\\n/;
                $valueContent .= $line;
            }	
        } else {
            $code .= $line;
        }
    }      

    my $fh;
    pdev $code;

    open($fh, '>', $some_file) || die "Failed to open ".$some_file;
    print $fh $code;
    close $fh;
}

ParseXmlTranslationDir($src_dir);

ProcessAppleProjectDir($dst_dir);

#pdev Dumper \%APPLE;
#pdev Dumper \%TRANS;

$parseIteration++;
ProcessAppleProjectDir($dst_dir);

