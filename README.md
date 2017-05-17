
# htmlembed.pl

## Introduction

Sometimes it is necessary to create HTML files embedding all linked references like images, scripts, css files etc. This script converts HTML files and embeds linked resources or copies resources into the same folder as the HTML files and changes links accordingly. So the resulting HTML files can easily be distributed and run without dependencies.

## Why?

Using HTML5 and JavaScript presentation frameworks like reveal.js one can easily create interactive, synchronous and web-based presentations for conferences, workshops or e-learning. But the resulting HTML files hold certain dependencies e.g. to the reveal library, to customised CSS files, to image files etc. Accordingly it is difficult to distribute the HTML files and run them on an other system. This perl script is intended to convert HTML files in a way that all linked and referred resources are ether embedded into the file itself using base64 decoding methods of HTML5 or copied in the same folder as the HTML file itself so it can easily be compressed. The last case is interesting for uploading the HTML file in learning management systems like Moodle.

There are other ways to produce single file HTML reveal.js presentations with embedded resources, e.g. using the Org-mode reveal export extension or self written bash scripts for scanning HTML files. But those solutions turn out to be less flexible and inappropriate for certain use cases:

 * HTML files with audio resources are not embedded
 * It is not possible to ignore certain references while embedding others, e.g. exclude or drop audio files while embedding only images

## Usage

htmlembed.pl HTMLFILE [--audio|-a [embed|copy]] 
                      [--image|-i [embed|copy]] 
                      [--link|-l [embed|copy]]
                      [--script|-s [embed|copy]] 
                      [--all [embed|copy]] 
					  [--out|-o OUTFILE]
					  [--path|-p PATH]
					  
 --out|-o :: filename of output HTML file. Defaults to 'index.html'.
 --path|-p :: subfolder to output HTML file and to copy resources. Defaults to './htmlembed/'.
 --audio|-a, --image|-i, --link|-l, --script|-s, --all :: specify how to threat those tags: 'embed' embeds the linked resource using base64 within the HTML file, 'copy' copies the file in the specified subfolder an changes the reference accordingly..
 
## Installation

Please ensure the required libraries to be installed:

> sudo apt-get install libxml-libxml-perl libswitch-perl libmime-tools-perl perl-base

## Notes

This script is based on libxml and requires the HTML files to be XHTML. Due
