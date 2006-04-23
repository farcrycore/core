<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_file/getMimeTypes.cfm,v 1.1 2004/04/27 22:41:09 tom Exp $
$Author: tom $
$Date: 2004/04/27 22:41:09 $
$Name: milestone_2-2-1 $
$Revision: 1.1 $

|| DESCRIPTION || 
$Description: Builds a structure of Mime Types $
$TODO: $

|| DEVELOPER ||
$Developer: Tom Cornilliac (tomc@co.deschutes.or.us) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfscript>
	stMimeTypes = structNew();
	//build mime types structure
	stMimeTypes.ai="application/postscript";
	stMimeTypes.aif="audio/x-aiff";
	stMimeTypes.aifc="audio/x-aiff";
	stMimeTypes.aiff="audio/x-aiff";
	stMimeTypes.asc="text/plain";
	stMimeTypes.au="audio/basic";
	stMimeTypes.avi="video/x-msvideo";
	stMimeTypes.bcpio="application/x-bcpio";
	stMimeTypes.bin="application/octet-stream";
	stMimeTypes.c="text/plain";
	stMimeTypes.cc="text/plain";
	stMimeTypes.ccad="application/clariscad";
	stMimeTypes.cdf="application/x-netcdf";
	stMimeTypes.class="application/octet-stream";
	stMimeTypes.cpio="application/x-cpio";
	stMimeTypes.cpt="application/mac-compactpro";
	stMimeTypes.csh="application/x-csh";
	stMimeTypes.css="text/css";
	stMimeTypes.dcr="application/x-director";
	stMimeTypes.dir="application/x-director";
	stMimeTypes.dms="application/octet-stream";
	stMimeTypes.doc="application/msword";
	stMimeTypes.drw="application/drafting";
	stMimeTypes.dvi="application/x-dvi";
	stMimeTypes.dwg="application/acad";
	stMimeTypes.dxf="application/dxf";
	stMimeTypes.dxr="application/x-director";
	stMimeTypes.eps="application/postscript";
	stMimeTypes.etx="text/x-setext";
	stMimeTypes.exe="application/octet-stream";
	stMimeTypes.ez="application/andrew-inset";
	stMimeTypes.f="text/plain";
	stMimeTypes.f90="text/plain";
	stMimeTypes.fli="video/x-fli";
	stMimeTypes.gif="image/gif";
	stMimeTypes.gtar="application/x-gtar";
	stMimeTypes.gz="application/x-gzip";
	stMimeTypes.h="text/plain";
	stMimeTypes.hdf="application/x-hdf";
	stMimeTypes.hh="text/plain";
	stMimeTypes.hqx="application/mac-binhex40";
	stMimeTypes.htm="text/html";
	stMimeTypes.html="text/html";
	stMimeTypes.ice="x-conference/x-cooltalk";
	stMimeTypes.ief="image/ief";
	stMimeTypes.iges="model/iges";
	stMimeTypes.igs="model/iges";
	stMimeTypes.ips="application/x-ipscript";
	stMimeTypes.ipx="application/x-ipix";
	stMimeTypes.jpe="image/jpeg";
	stMimeTypes.jpeg="image/jpeg";
	stMimeTypes.jpg="image/jpeg";
	stMimeTypes.js="application/x-javascript";
	stMimeTypes.kar="audio/midi";
	stMimeTypes.latex="application/x-latex";
	stMimeTypes.lha="application/octet-stream";
	stMimeTypes.lsp="application/x-lisp";
	stMimeTypes.lzh="application/octet-stream";
	stMimeTypes.m="text/plain";
	stMimeTypes.man="application/x-troff-man";
	stMimeTypes.me="application/x-troff-me";
	stMimeTypes.mesh="model/mesh";
	stMimeTypes.mid="audio/midi";
	stMimeTypes.midi="audio/midi";
	stMimeTypes.mif="application/vnd.mif";
	stMimeTypes.mime="www/mime";
	stMimeTypes.mov="video/quicktime";
	stMimeTypes.movie="video/x-sgi-movie";
	stMimeTypes.mp2="audio/mpeg";
	stMimeTypes.mp3="audio/mpeg";
	stMimeTypes.mpe="video/mpeg";
	stMimeTypes.mpeg="video/mpeg";
	stMimeTypes.mpg="video/mpeg";
	stMimeTypes.mpga="audio/mpeg";
	stMimeTypes.ms="application/x-troff-ms";
	stMimeTypes.msh="model/mesh";
	stMimeTypes.nc="application/x-netcdf";
	stMimeTypes.oda="application/oda";
	stMimeTypes.pbm="image/x-portable-bitmap";
	stMimeTypes.pdb="chemical/x-pdb";
	stMimeTypes.pdf="application/pdf";
	stMimeTypes.pgm="image/x-portable-graymap";
	stMimeTypes.pgn="application/x-chess-pgn";
	stMimeTypes.png="image/png";
	stMimeTypes.pnm="image/x-portable-anymap";
	stMimeTypes.pot="application/mspowerpoint";
	stMimeTypes.ppm="image/x-portable-pixmap";
	stMimeTypes.pps="application/mspowerpoint";
	stMimeTypes.ppt="application/mspowerpoint";
	stMimeTypes.ppz="application/mspowerpoint";
	stMimeTypes.pre="application/x-freelance";
	stMimeTypes.prt="application/pro_eng";
	stMimeTypes.ps="application/postscript";
	stMimeTypes.qt="video/quicktime";
	stMimeTypes.ra="audio/x-realaudio";
	stMimeTypes.ram="audio/x-pn-realaudio";
	stMimeTypes.ras="image/cmu-raster";
	stMimeTypes.rgb="image/x-rgb";
	stMimeTypes.rm="audio/x-pn-realaudio";
	stMimeTypes.roff="application/x-troff";
	stMimeTypes.rpm="audio/x-pn-realaudio-plugin";
	stMimeTypes.rtf="text/rtf";
	stMimeTypes.rtx="text/richtext";
	stMimeTypes.scm="application/x-lotusscreencam";
	stMimeTypes.set="application/set";
	stMimeTypes.sgm="text/sgml";
	stMimeTypes.sgml="text/sgml";
	stMimeTypes.sh="application/x-sh";
	stMimeTypes.shar="application/x-shar";
	stMimeTypes.silo="model/mesh";
	stMimeTypes.sit="application/x-stuffit";
	stMimeTypes.skd="application/x-koan";
	stMimeTypes.skm="application/x-koan";
	stMimeTypes.skp="application/x-koan";
	stMimeTypes.skt="application/x-koan";
	stMimeTypes.smi="application/smil";
	stMimeTypes.smil="application/smil";
	stMimeTypes.snd="audio/basic";
	stMimeTypes.sol="application/solids";
	stMimeTypes.spl="application/x-futuresplash";
	stMimeTypes.src="application/x-wais-source";
	stMimeTypes.step="application/STEP";
	stMimeTypes.stl="application/SLA";
	stMimeTypes.stp="application/STEP";
	stMimeTypes.sv4cpio="application/x-sv4cpio";
	stMimeTypes.sv4crc="application/x-sv4crc";
	stMimeTypes.swf="application/x-shockwave-flash";
	stMimeTypes.t="application/x-troff";
	stMimeTypes.tar="application/x-tar";
	stMimeTypes.tcl="application/x-tcl";
	stMimeTypes.tex="application/x-tex";
	stMimeTypes.texi="application/x-texinfo";
	stMimeTypes.texinfo="application/x-texinfo";
	stMimeTypes.tif="image/tiff";
	stMimeTypes.tiff="image/tiff";
	stMimeTypes.tr="application/x-troff";
	stMimeTypes.tsi="audio/TSP-audio";
	stMimeTypes.tsp="application/dsptype";
	stMimeTypes.tsv="text/tab-separated-values";
	stMimeTypes.txt="text/plain";
	stMimeTypes.unv="application/i-deas";
	stMimeTypes.ustar="application/x-ustar";
	stMimeTypes.vcd="application/x-cdlink";
	stMimeTypes.vda="application/vda";
	stMimeTypes.viv="video/vnd.vivo";
	stMimeTypes.vivo="video/vnd.vivo";
	stMimeTypes.vrml="model/vrml";
	stMimeTypes.wav="audio/x-wav";
	stMimeTypes.wrl="model/vrml";
	stMimeTypes.xbm="image/x-xbitmap";
	stMimeTypes.xlc="application/vnd.ms-excel";
	stMimeTypes.xll="application/vnd.ms-excel";
	stMimeTypes.xlm="application/vnd.ms-excel";
	stMimeTypes.xls="application/vnd.ms-excel";
	stMimeTypes.xlw="application/vnd.ms-excel";
	stMimeTypes.xml="text/xml";
	stMimeTypes.xpm="image/x-xpixmap";
	stMimeTypes.xwd="image/x-xwindowdump";
	stMimeTypes.xyz="chemical/x-pdb";
	stMimeTypes.zip="application/zip";
</cfscript>

