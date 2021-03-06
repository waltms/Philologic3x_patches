#!/usr/bin/perl
# -*- perl -*-
# theme_rheme.pl.  Generated from theme_rheme.pl.plin by configure.
#
# $Id: theme_rheme.pl.plin,v 1.1 2004/11/16 00:47:38 o Exp $
#
# philologic 2.8 -- TEI XML/SGML Full-text database engine
# Copyright (C) 2004 University of Chicago
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the Affero General Public License as published by
# Affero, Inc.; either version 1 of the License, or (at your option)
# any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# Affero General Public License for more details.
# 
# You should have received a copy of the Affero General Public License
# along with this program; if not, write to Affero, Inc.,
# 510 Third Street, Suite 225, San Francisco, CA 94107 USA.

use Data::Dumper;

${prefix} = "" unless (defined ${prefix});

$PHILOSITECFG = "${prefix}/etc/philologic";
do "$PHILOSITECFG/dbnames";

$hitsize = $ARGV[0] * 2 + $ARGV[1] * 4;
$unpack = "s" . $ARGV[0] . "i" . $ARGV[1];
$hitlist = $ARGV[2];
$finish = 1000000;
$mvocounter = 0;
$theme = 0;
$dbname = $ARGV[3];
$themeprintlimit = $ARGV[4];

$SYSTEM_DIR=$dbnames{"$dbname"};
do "$PHILOSITECFG/philologic.cfg";
unshift (@INC, $SYSTEM_DIR . "/lib");
require "$SYSTEM_DIR/lib/philosubs.pl";

open (P, $SYSTEM_DIR . "pagemarks");
@p = <P>;

$|=1;

$BLOCKSIZE = 2048;

$cntxt = 300; #250;
$permcntxt = $cntxt;

$lastdoc = -1;

$CONTEXTUALIZER = "$PHILOCGI/contextualize.pl";
$GETOBJECT = "$PHILOCGI/getobject.pl";

&SetThemeColors;
 
$citefile="$SYSTEM_DIR/docinfo";

open (TFILE, $citefile);
while (<TFILE>) {
      chop;
      ($filename, $dl, $cite, $rest) = split (" ", $_, 4);
      push (@filenames, $filename); 
      push (@citebuffer, $cite);
      push (@doclengths, $dl);
  } 
close TFILE;

# the SetThemeLimit() function no longer makes use of values you
# # pass to it, unless you want to retain old logic. See my notes
# question 24 for further comments.
($FRONTLIMIT, $LASTLIMIT) = &SetThemeLimit(1);
print "<p>" . sprintf ($philomessage[267], $FRONTLIMIT, 100 - $LASTLIMIT, $LASTLIMIT - $FRONTLIMIT);

print "<p><a href=\"#summary\">" . $philomessage[268] . "</a>";
   if ($themeprintlimit == 1) {
	print "<p>Go to <a href=\"#theme\">" . $philomessage[269] . "</a>";
	print " (" . $themehitcoloron . $philomessage[270] . $themehitcoloroff . ")";
	}
   if ($themeprintlimit == 2) {
        print " || <a href=\"#last\">" . $philomessage[271] . "</a>";
        print " (" . $lasthitcoloron. $philomessage[270] . $lasthitcoloroff . ")";
        }
   if ($themeprintlimit > 2) {
	print "<p>Go to <a href=\"#theme\">" . $philomessage[269] . "</a>";
	print " (" . $themehitcoloron . $philomessage[270] . $themehitcoloroff . ")";
        print " || <a href=\"#last\">" . $philomessage[271] . "</a>";
        print " (" . $lasthitcoloron. $philomessage[270] . $lasthitcoloroff . ")";
        }
   if ($themeprintlimit > 3) {
        print " || <a href=\"#rheme\">" . $philomessage[272] . "</a>";
        print " (" . $rhemehitcoloron. $philomessage[270] . $rhemehitcoloroff . ")";
	}
   if ($themeprintlimit > 4) {
        print " || <a href=\"#short\">" . $philomessage[273] . "</a>";
        print " (" . $shorthitcoloron. $philomessage[270] . $shorthitcoloroff . ")";
	}
   print "<p>";

open (TFILE, "$hitlist");

while ( ($hit = &GetHit) && ($mvocounter < $finish + 1) ) {
    @o = unpack ($unpack, $hit); 
    @index = (); 
    for ( $i = 0; $i < $ARGV[0]; $i++ ) {
          push (@index, shift (@o)); 
       }

   $doc = shift @index; 
   $pc = pop @index;
 
   if ( $#docs < 0 || $docs[$#docs] != $doc ) {
       push ( @docs, $doc ); 
   }


    @o = sort numerically @o;

# page number:

    $pagenum = $pc <= $p[0] ? $pc : $p[$pc - $p[0]]; 


    ###################
    #
    # Context:
    #
    ###################

    #
    # $lo and $ro -- left and right offsets;
    # $ll and $rl -- left and right lengths;
    # $dl -- total document length
    #

	$dl = $doclengths [$doc];
# Sometimes for really short files we find a context * 2 longer than
# the file length.  This corrects by shortening the context.  MVO 28-01-2001

        $cntxt = $permcntxt;
        $cntxt2x = $cntxt * 2;

        if ($dl < $cntxt2x) {
                $cntxt = int $dl / 2 - 20;
        }

# End Addition....


	$lo = $o[0] - $cntxt;
	$ro = $o[0]; # + $l;
        $rl = ($o[$#o] + $cntxt > $dl) ? $dl - $ro : $o[$#o] + $cntxt - $ro;


    # Some necessary corrections just in case we don't have enough context,
    # for ex., if the word is at the very beginning of the document:
  
        $lo = $lo < 0 ? 0 : $rl < $cntxt ? ($lo - ($cntxt - $rl)) : $lo;

	open (TEXT, $SYSTEM_DIR . "TEXTS/" . $filenames [$doc]); 

	seek (TEXT, $lo, 0);
	read (TEXT, $textbuffer, $ro + $rl - $lo);

        undef (@spans);

        $left = substr ($textbuffer, 0, $o[0] - $lo);

        for ( $i = 0; $i < $#o; $i++ ) {
	   $span = substr ($textbuffer, $o[$i] - $lo, $o[$i+1] - $o[$i]);
           $span = &ConcSpan($span);
	   push (@spans, $span);
	}

        $span = substr ($textbuffer, $o[$#o] - $lo, $ro + $rl - $o[$i]);
        $span = &ConcSpan($span);
	push (@spans, $span);

        unshift (@spans, $left);

    for ($spn = 0; $spn <= $#spans; $spn++) {
	$spans[$spn] =~ s/<[bB]>//g; 
        }

    $text = join ($hithighon_conc, @spans);
    $text = &ConcFormat($text);

    $tagtail = &TagTail ($dbname);
    $hitlist =~ s:^.*/hitlist.::g;


# HREF tag for page object:

    if ( !$ChainLinksRestricted ) {
	$href = "<A HREF=\"" . $CONTEXTUALIZER . "?p." . $doc . "." . 
	      $tagtail . "\">";
        }
    else {
	$href = "<A HREF=\"" . $CONTEXTUALIZER . "?p." . $hitlist . "." . 
	      $dbname . "." . $mvocounter . "." . $ARGV[0] . "." . 
	      $ARGV[1] . ".0\">";
    }

# for now, we are going to give them links to h1, h2 and paragraph


    $hier = "";

    for ( $i = 0; $i < $ARGV[0] - 2; $i++ ) {
	$hier .= ":$index[$i]";
	if ( $index[$i] == -1 ) {
	    $ohref[$i] = "";
	    }	
	else {
	    unless ( $ChainLinksRestricted ) {
		$ohref[$i] = "<A HREF=\"" . $GETOBJECT . "?c." . $doc . 
		$hier . "." . $tagtail . "\">";
	    }
	    else {
	       $ohref[$i] = "<A HREF=\"" . $GETOBJECT . "?c" . ($i + 1) . "." . 
	       $hitlist . "." . $dbname . "." . $mvocounter . "." . $ARGV[0] . 
	       "." . $ARGV[1] . ".0\">";
	    }
	}
    }

    $HITBUFFER = "";
    $mvocounter++;
    $pagenum =~ s/\n//;
    $HITBUFFER .= &concheadline ( $citebuffer[$doc], $pagenum, $href, @ohref ); 
    $text =~ s/\'  */\'/g;
    $text =~ s/<br>/ /gi;
    $HITBUFFER .= "\n<p>" . $text . "</i>";
    $MYHITLINE = &ThemeHitLine($text);
    @clausewords = split(/ /, $MYHITLINE);
    $numofdwords = @clausewords;
    $hitwordinclause = "";
    for $i (0..$numofdwords) {
	if ($clausewords[$i] =~ /<hitword>/) {
		$hitwordinclause = $i + 1;
		$i = $numofdwords + 2;
		}
	}
    $doctotalhit{$doc}++;

    $alongclause = 0;
    if ($numofdwords > 3) {
        $alongclause = 1;
	}
    else {
        $shorties++;
	$clauselenshort += $numofdwords;
	$SHORTIES .= "<hr>Too Short: $shorties\. " . $HITBUFFER;
	push (@shortdocstoprint, $doc);
    }

    if ($alongclause) {
	$whereinclause = ($hitwordinclause / $numofdwords) * 100;
	$headinfo = " [" . $hitwordinclause . "/" . $numofdwords;
	$tempwhere = $whereinclause;
	$tempwhere =~ s/\.(..).*/\.$1/;
	$headinfo .= " = " . $tempwhere . "%] ";

        $HITBUFFER .= "<p>\n";
#	$THEMELIMIT = &SetThemeLimit($numofdwords);
	($FRONTLIMIT, $LASTLIMIT) = &SetThemeLimit($numofdwords);

	if ($whereinclause < $FRONTLIMIT) {
	   $clauselentheme += $numofdwords;
	   $theme++;
	   $docthemehit{$doc}++;
	   $THEMEBUF .= "<hr>" . $philomessage[274] . ": $theme\. " . $headinfo . $HITBUFFER;
	   push (@themedocstoprint, $doc);
	   }
	elsif ($whereinclause < $LASTLIMIT) {
	   $clauselenrheme += $numofdwords;
	   $rheme++;
	   $RHEMEBUF .= "<hr>" . $philomessage[276] . ": $rheme\. " . $headinfo . $HITBUFFER;
	   push (@rhemedocstoprint, $doc);
	   }
        else {
	   $rightatend++;
	   $clauselenend += $numofdwords;
	   $ENDBUFFER .= "<hr>" . $philomessage[277] . ": $rightatend\. " . $headinfo . $HITBUFFER;
	   push (@lastdocstoprint, $doc);
	   }
	}
        
}
# Print the rest of the hits if set by user.
if ($themeprintlimit == 1) {
   print "<hr>";
   print "<a name=\"theme\">";
   print "<p><b>" . $philomessage[275] . "</b><p>\n";
   $THEMEBUF =~ s/< hitword>/$themehitcoloron/g;
   $THEMEBUF =~ s/< \/hitword>/$themehitcoloroff/g;
   print $THEMEBUF;
}
if ($themeprintlimit == 2) {
   print "<hr>\n";
   print "<a name=\"last\">";
   print "<p><b>" . sprintf($philomessage[278], $rightatend, $mvocounter) . "</b><p>\n";
   $ENDBUFFER =~ s/< hitword>/$lasthitcoloron/g;
   $ENDBUFFER =~ s/< \/hitword>/$lasthitcoloroff/g;
   print $ENDBUFFER;
}
if ($themeprintlimit > 2) {
    # Theme
   print "<hr>";
   print "<a name=\"theme\">";
   print "<p><b>" . $philomessage[275] . "</b><p>\n";
   $THEMEBUF =~ s/< hitword>/$themehitcoloron/g;
   $THEMEBUF =~ s/< \/hitword>/$themehitcoloroff/g;
   print $THEMEBUF;

   # End
   print "<hr>\n";
   print "<a name=\"last\">";
   print "<p><b>" . sprintf($philomessage[278], $rightatend, $mvocounter) . "</b><p>\n";
   $ENDBUFFER =~ s/< hitword>/$lasthitcoloron/g;
   $ENDBUFFER =~ s/< \/hitword>/$lasthitcoloroff/g;
   print $ENDBUFFER;
}
if ($themeprintlimit > 3) {
   print "<hr>\n";
   print "<a name=\"rheme\">";
   print "<p><b>" . sprintf($philomessage[279], $rheme, $mvocounter) . "</b><p>\n";
   $RHEMEBUF =~ s/< hitword>/$rhemehitcoloron/g;
   $RHEMEBUF =~ s/< \/hitword>/$rhemehitcoloroff/g;
   print  $RHEMEBUF;
   print "<hr>\n";

}
if ($themeprintlimit > 4) {
   print "<hr>\n";
   print "<a name=\"short\">";
   print "<p><b>" . sprintf($philomessage[280], $shorties, $mvocounter) . "</b><p>\n";
   $SHORTIES =~ s/< hitword>/$shorthitcoloron/g;
   $SHORTIES =~ s/< \/hitword>/$shorthitcoloroff/g;
   print $SHORTIES;
   print "<hr>\n";
}

# Print the summaries......
print "<a name=\"summary\">\n";
print "<p><center><b>". $philomessage[281] . "</b></center><p>\n";
print "</a>";

if ($theme) {
    $thepercent = ($theme/$mvocounter) * 100;
    $themepercent = $thepercent;
    $thepercent =~ s/\.(..).*/\.$1/;
    print sprintf($philomessage[282], $theme, $mvocounter, $thepercent);

    $avgclauselen = ($clauselentheme/$theme);
    $avgclauselen =~ s/\.(..).*/\.$1/;
    print " " . sprintf($philomessage[283], $avgclauselen) . " ";
   if ($themeprintlimit == 1 || $themeprintlimit > 2) {
    print "(" . $themehitcoloron . $philomessage[284] . $themehitcoloroff . ")";
    print " <a href=\"#theme\">" . $philomessage[285] . "</a>";
    } else {
        print " " . $philomessage[286];
    }
    print "<br>";
}

if ($rightatend) {
   $thepercent = ($rightatend/$mvocounter) * 100;
   $thepercent =~ s/\.(..).*/\.$1/;
   print sprintf($philomessage[288], $rightatend, $mvocounter, $thepercent) . " ";
   $avgclauselen = ($clauselenend/$rightatend);
   $avgclauselen =~ s/\.(..).*/\.$1/;
   print " " . sprintf($philomessage[283], $avgclauselen) . " ";
   if ($themeprintlimit == 2 || $themeprintlimit > 2) {
        print "(" . $lasthitcoloron . $philomessage[284] . $lasthitcoloroff . ")";
        print " <a href=\"#last\">" . $philomessage[285]. "</a>";
        }
   else {
        print " " . $philomessage[286];
        }
   print "<br>";
}

if ($rheme) {
   $thepercent = ($rheme/$mvocounter) * 100;
   $thepercent =~ s/\.(..).*/\.$1/;
   print sprintf($philomessage[287], $rheme, $mvocounter, $thepercent) . " ";

   $avgclauselen = ($clauselenrheme/$rheme);
   $avgclauselen =~ s/\.(..).*/\.$1/;
   print " " . sprintf($philomessage[283], $avgclauselen) . " ";
   if ($themeprintlimit > 3) {
        print "(" . $rhemehitcoloron . $philomessage[284] . $rhemehitcoloroff . ")";
   	print " <a href=\"#rheme\">" . $philomessage[285]. "</a>";
	}
   else { 
   	print " " . $philomessage[286];
	}
   print "<br>";
}

if ($shorties) {
$thepercent = ($shorties/$mvocounter) * 100;
$thepercent =~ s/\.(..).*/\.$1/;
print sprintf($philomessage[289], $shorties, $mvocounter, $thepercent) . " ";

$avgclauselen = ($clauselenshort/$shorties);
$avgclauselen =~ s/\.(..).*/\.$1/;
   print " " . sprintf($philomessage[283], $avgclauselen) . " ";
   if ($themeprintlimit > 4) {
        print "(" . $shorthitcoloron . $philomessage[284] . $shorthitcoloroff . ")";
        print " <a href=\"#short\">" . $philomessage[285]. "</a>";
        }
   else {
     	print " " . $philomessage[286];
        }
   print "<br>";

}


$filterpercent = $themepercent * 1.5;
$displaypercent = $filterpercent;
$displaypercent =~ s/([0-9]*\.[0-9][0-9]).*/$1/;
$HIRATEBUFF = "";

foreach $thisdocid (sort numerically keys(%docthemehit)) {
	$docrate = ($docthemehit{$thisdocid} / $doctotalhit{$thisdocid}) * 100;
	$docrate =~ s/\.(..).*/\.$1/;
	if ($docrate > $filterpercent && $doctotalhit{$thisdocid} > 10) {
		$HIRATEBUFF .= "<b>" . $docrate . "% </b> (";
		$HIRATEBUFF .= $docthemehit{$thisdocid} . "/";
	        $HIRATEBUFF .= $doctotalhit{$thisdocid}. "): ";
		if ($biblioLinesProcessed > $thisdocid) {
		        close (BIB);
			$biblioLinesProcessed = 0;
			}
		$HIRATEBUFF .= &getbiblioLine($thisdocid);
		$HIRATEBUFF .= "<p>";
		}
	}

if ($HIRATEBUFF) {
       print "<hr>" . sprintf($philomessage[290], $displaypercent) . "<p>";
       print $HIRATEBUFF;
       }

print "<hr><center><b>" . $philomessage[291] . "</b></center><p>\n";
if ($biblioLinesProcessed) {
	close (BIB);
	$biblioLinesProcessed = 0;
	}
#@tempdoc = @themedocstoprint;
@tempdoc = ();
if ($themeprintlimit == 1) {
	for $tdoc(@themedocstoprint) {
		push (@tempdoc, $tdoc);
	}
}
if ($themeprintlimit == 2) {
	for $tdoc(@lastdocstoprint) {
		push (@tempdoc, $tdoc);
	}
}
if ($themeprintlimit > 2) {
	for $tdoc(@themedocstoprint) {
		push (@tempdoc, $tdoc);
	}
	for $tdoc(@lastdocstoprint) {
		push (@tempdoc, $tdoc);
	}
}
if ($themeprintlimit > 3) {
	for $tdoc(@rhemedocstoprint) {
		push (@tempdoc, $tdoc);
	}
}

if ($themeprintlimit > 4) {
	for $tdoc(@shortdocstoprint) {
		push (@tempdoc, $tdoc);
	}
}

@tempdoc = sort numerically @tempdoc;


$lastdoc = -1;
for $doc(@tempdoc) {
	if ($lastdoc != $doc) {
		push (@alldocstoprint, $doc);
		$lastdoc = $doc;
		}
	}

for $doc (@alldocstoprint) {
    print &getbiblioLine ( $doc, "link" ) . "<p>\n";
}

# Subroutines....
sub GetHit {
    local($str);
    read (TFILE, $bufstr, 1024 * $hitsize) unless $readinit % 1024;
    $str = substr ($bufstr, $readinit++ % 1024 * $hitsize, $hitsize);
    return $str;
}


sub TagTail {
local ($database) = $_[0];

    return $database . "." . join (".", @o);
}

sub numerically { $a <=> $b }





