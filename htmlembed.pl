#!/usr/bin/perl

use File::Basename;
use File::Path qw(remove_tree);
use File::Copy;
use Getopt::Long;
use XML::LibXML;
use Switch;
use MIME::Base64 qw(encode_base64);

my $infile= @ARGV[0];
die "File $infile not readable" unless -r $infile;

my ($file, $path, $suffix)= fileparse($infile, (".html", ".htm"));
my $outfile= "index.html";
my $outpath= './htmlembed/';
my $audio= 'embed';
my $img= 'embed';
my $script= 'embed';
my $link= 'embed';
my $alltags= '';

GetOptions('audio|a=s' => \$audio,
	   'img|i=s' => \$img,
	   'script|s=s' => \$script,
	   'link|l=s' => \$link,
	   'all=s' => \$alltags,
	   'out|o=s' => \$outfile,
	   'path|p=s' => \$outpath,
    );

# append ./ and / to $outpath if necessary
$outpath = './'.$outpath unless $outpath =~ /^\.\//;
$outpath = $outpath.'/' unless $outpath =~ /\/$/;

if ($alltags) {
    $audio= $alltags;
    $img= $alltags;
    $script= $alltags;
    $link= $alltags;
}

my ($file, $path, $suffix)= fileparse($infile, (".html", ".htm"));

my %mimetypes= (
    "png" => "image/png",
    "jpeg" => "image/jpeg",
    "jpg" => "image/jpeg",
    "html" => "text/html",
    "htm" => "text/html",
    "css" => "text/css",
    "js" => "text/javascript",
    "svg" => "image/svg+xml",
    "mp3" => "audio/mpeg",
    "ogg" => "audio/ogg",
    ); 
my %copied= ();

chdir($path);
remove_tree($outpath);
mkdir $outpath;

my $dom = XML::LibXML->load_html(
    location  => $file.$suffix,
    recover   => 2,
    );

# audio-tag
foreach my $tag ($dom->findnodes('//audio')) 
{
    foreach my $source ($tag->findnodes('./source'))
    {
	my $uri= $source->getAttribute('src');
	if ($audio eq 'embed') {	
	    print "audio: embed src $uri\n";
	    $source->setAttribute('src' => datauri($uri));
	};
	if ($audio eq 'copy') {	
	    print "audio: copy src $uri\n";
	    $source->setAttribute('src' => copyuri($uri));
	};	      
    }
}

# img-tag
foreach my $tag ($dom->findnodes('//img')) 
{
    my $uri= $tag->getAttribute('src');
    if ($img eq 'embed') {	
	print "img: embed src $uri\n";
	$tag->setAttribute('src' => datauri($uri));
    }
    elsif ($img eq 'copy') {
	print "img: copy src $uri\n";
	$tag->setAttribute('src' => copyuri($uri));
    }
}

# script-tag
foreach my $tag ($dom->findnodes('//script')) 
{
    # obviously libxml has some problems with the script tag. This is
    # why we append an empty text later and why we remove CDATASection.
    my $uri= $tag->getAttribute('src');
    if ($uri) {		
	if ($script eq 'embed') {	
	    print "script: embed src $uri\n";
	    $tag->setAttribute('src' => datauri($uri));
	    $tag->appendText(' ');
	};
	if ($script eq 'copy') {	
	    print "script: copy src $uri\n";
	    $tag->setAttribute('src' => copyuri($uri));
	    $tag->appendText(' ');
	};
    } else {
	if (ref($tag->firstChild) eq "XML::LibXML::CDATASection")
	{	    
	    my $code= $tag->firstChild->data();
	    $tag->removeChildNodes();
	    $tag->appendText($code);
	}
    }
}

# link-tag
foreach my $tag ($dom->findnodes('//link')) 
{
    my $uri= $tag->getAttribute('href');
    if ($link eq 'embed') {	
	print "link: embed href $uri\n";
	$tag->setAttribute('href' => datauri($uri));
    };
    if ($link eq 'copy') {	
	print "link: copy href $uri\n";
	$tag->setAttribute('href' => copyuri($uri));
    };
}

# write output
open (OUT, ">$outpath/$outfile");
print OUT $dom->toString();
close (OUT);

sub datauri
{
    my $href= shift;
    my $content= undef;
    my $type= "";

    my ($file, $path, $suffix)= fileparse($href, keys(%mimetypes));
    $type= $mimetypes{$suffix} if $mimetypes{$suffix};
    
    open (my $fh, '<', $href) or die "Can't open file $href: $!\n";
    $content.= $line while ($line= <$fh>);
    close (REF);
    $content= encode_base64($content, "");
    return "data:$type;base64,$content";
}

sub copyuri
{
    my $that= shift;
    my ($file, $path)= fileparse($that);
    my $newfile= $file;
    if ($copied{$that}) {
	$newfile= $copied{$that};
    } else {
	if (-e $outpath.$newfile) {
	    my $i= 0;
	    $i++ while -e $outpath.$i.$file;
	    $newfile= $i.$file;
	}
    }
    copy($path.$file, $outpath.$newfile);
    $copied{$that} = $newfile;
    return $newfile;
}
