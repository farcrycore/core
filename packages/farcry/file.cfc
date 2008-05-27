<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/farcry/file.cfc,v 1.4 2005/08/09 03:54:39 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:39 $
$Name: milestone_3-0-1 $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: file handling cfc $


|| DEVELOPER ||
$Developer: Tom Cornilliac (tomc@co.deschutes.or.us) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfcomponent displayName="File" hint="Farcry File Operations">

	<cffunction name="getMimeTypes" access="private" returntype="struct" hint="Returns a structure of known Mime Types" output="No">
		<cfset var stMimes = structnew() />
		
		<cfset stMimes["a"] = "application/octet-stream" />
		<cfset stMimes["abc"] = "text/vnd.abc" />
		<cfset stMimes["acgi"] = "text/html" />
		<cfset stMimes["afl"] = "video/animaflex" />
		<cfset stMimes["ai"] = "application/postscript" />
		<cfset stMimes["aifc"] = "audio/aiff" />
		<cfset stMimes["aiff"] = "audio/aiff" />
		<cfset stMimes["aip"] = "text/x-audiosoft-intra" />
		<cfset stMimes["ani"] = "application/x-navi-animation" />
		<cfset stMimes["aps"] = "application/mime" />
		<cfset stMimes["arc"] = "application/octet-stream" />
		<cfset stMimes["arj"] = "application/octet-stream" />
		<cfset stMimes["art"] = "image/x-jg" />
		<cfset stMimes["asf"] = "video/x-ms-asf" />
		<cfset stMimes["asm"] = "text/x-asm" />
		<cfset stMimes["asp"] = "text/asp" />
		<cfset stMimes["asr"] = "video/x-ms-asf" />
		<cfset stMimes["asx"] = "video/x-ms-asf" />
		<cfset stMimes["atom"] = "application/xml+atom" />
		<cfset stMimes["au"] = "audio/basic" />
		<cfset stMimes["au"] = "audio/x-au" />
		<cfset stMimes["avi"] = "video/avi" />
		<cfset stMimes["avs"] = "video/avs-video" />
		<cfset stMimes["axs"] = "application/olescript" />
		<cfset stMimes["bas"] = "text/plain" />
		<cfset stMimes["bcpio"] = "application/x-bcpio" />
		<cfset stMimes["bin"] = "application/octet-stream" />
		<cfset stMimes["bm"] = "image/bmp" />
		<cfset stMimes["bmp"] = "image/bmp" />
		<cfset stMimes["boo"] = "application/book" />
		<cfset stMimes["book"] = "application/book" />
		<cfset stMimes["boz"] = "application/x-bzip2" />
		<cfset stMimes["bsh"] = "application/x-bsh" />
		<cfset stMimes["bz2"] = "application/x-bzip2" />
		<cfset stMimes["bz"] = "application/x-bzip" />
		<cfset stMimes["c"] = "text/plain" />
		<cfset stMimes["cat"] = "application/octet-stream" />
		<cfset stMimes["cc"] = "text/plain" />
		<cfset stMimes["ccad"] = "application/clariscad" />
		<cfset stMimes["cco"] = "application/x-cocoa" />
		<cfset stMimes["cdf"] = "application/cdf" />
		<cfset stMimes["cer"] = "application/x-x509-ca-cert" />
		<cfset stMimes["cha"] = "application/x-chat" />
		<cfset stMimes["chat"] = "application/x-chat" />
		<cfset stMimes["class"] = "application/java" />
		<cfset stMimes["class"] = "application/octet-stream" />
		<cfset stMimes["clp"] = "application/x-msclip" />
		<cfset stMimes["cmx"] = "image/x-cmx" />
		<cfset stMimes["cod"] = "image/cis-cod" />
		<cfset stMimes["com"] = "application/octet-stream" />
		<cfset stMimes["com"] = "text/plain" />
		<cfset stMimes["conf"] = "text/plain" />
		<cfset stMimes["cpio"] = "application/x-cpio" />
		<cfset stMimes["cpp"] = "text/x-c" />
		<cfset stMimes["cpt"] = "application/x-cpt" />
		<cfset stMimes["crd"] = "application/x-mscardfile" />
		<cfset stMimes["crl"] = "application/pkcs-crl" />
		<cfset stMimes["crl"] = "application/pkix-crl" />
		<cfset stMimes["crt"] = "application/x-x509-ca-cert" />
		<cfset stMimes["csh"] = "application/x-csh" />
		<cfset stMimes["csh"] = "text/x-script.csh" />
		<cfset stMimes["css"] = "text/css" />
		<cfset stMimes["cxx"] = "text/plain" />
		<cfset stMimes["dcr"] = "application/x-director" />
		<cfset stMimes["deb"] = "application/octet-stream" />
		<cfset stMimes["deepv"] = "application/x-deepv" />
		<cfset stMimes["def"] = "text/plain" />
		<cfset stMimes["der"] = "application/x-x509-ca-cert" />
		<cfset stMimes["dhh"] = "application/david-heinemeier-hansson" />
		<cfset stMimes["dif"] = "video/x-dv" />
		<cfset stMimes["dir"] = "application/x-director" />
		<cfset stMimes["dl"] = "video/dl" />
		<cfset stMimes["dll"] = "application/octet-stream" />
		<cfset stMimes["dmg"] = "application/octet-stream" />
		<cfset stMimes["dms"] = "application/octet-stream" />
		<cfset stMimes["doc"] = "application/msword" />
		<cfset stMimes["dp"] = "application/commonground" />
		<cfset stMimes["drw"] = "application/drafting" />
		<cfset stMimes["dump"] = "application/octet-stream" />
		<cfset stMimes["dv"] = "video/x-dv" />
		<cfset stMimes["dvi"] = "application/x-dvi" />
		<cfset stMimes["dwg"] = "application/acad" />
		<cfset stMimes["dwg"] = "image/x-dwg" />
		<cfset stMimes["dxf"] = "application/dxf" />
		<cfset stMimes["dxf"] = "image/x-dwg" />
		<cfset stMimes["dxr"] = "application/x-director" />
		<cfset stMimes["ear"] = "application/java-archive" />
		<cfset stMimes["el"] = "text/x-script.elisp" />
		<cfset stMimes["elc"] = "application/x-bytecode.elisp (compiled elisp)" />
		<cfset stMimes["elc"] = "application/x-elc" />
		<cfset stMimes["env"] = "application/x-envoy" />
		<cfset stMimes["eot"] = "application/octet-stream" />
		<cfset stMimes["eps"] = "application/postscript" />
		<cfset stMimes["es"] = "application/x-esrehber" />
		<cfset stMimes["etx"] = "text/x-setext" />
		<cfset stMimes["evy"] = "application/envoy" />
		<cfset stMimes["evy"] = "application/x-envoy" />
		<cfset stMimes["exe"] = "application/octet-stream" />
		<cfset stMimes["f77"] = "text/x-fortran" />
		<cfset stMimes["f90"] = "text/plain" />
		<cfset stMimes["f90"] = "text/x-fortran" />
		<cfset stMimes["f"] = "text/x-fortran" />
		<cfset stMimes["fdf"] = "application/vnd.fdf" />
		<cfset stMimes["fif"] = "application/fractals" />
		<cfset stMimes["fif"] = "image/fif" />
		<cfset stMimes["fli"] = "video/fli" />
		<cfset stMimes["fli"] = "video/x-fli" />
		<cfset stMimes["flo"] = "image/florian" />
		<cfset stMimes["flr"] = "x-world/x-vrml" />
		<cfset stMimes["flv"] = "video/x-flv" />
		<cfset stMimes["flx"] = "text/vnd.fmi.flexstor" />
		<cfset stMimes["fmf"] = "video/x-atomic3d-feature" />
		<cfset stMimes["for"] = "text/plain" />
		<cfset stMimes["for"] = "text/x-fortran" />
		<cfset stMimes["fpx"] = "image/vnd.fpx" />
		<cfset stMimes["fpx"] = "image/vnd.net-fpx" />
		<cfset stMimes["frl"] = "application/freeloader" />
		<cfset stMimes["funk"] = "audio/make" />
		<cfset stMimes["g3"] = "image/g3fax" />
		<cfset stMimes["g"] = "text/plain" />
		<cfset stMimes["gif"] = "image/gif" />
		<cfset stMimes["gl"] = "video/gl" />
		<cfset stMimes["gl"] = "video/x-gl" />
		<cfset stMimes["gsd"] = "audio/x-gsm" />
		<cfset stMimes["gsm"] = "audio/x-gsm" />
		<cfset stMimes["gsp"] = "application/x-gsp" />
		<cfset stMimes["gss"] = "application/x-gss" />
		<cfset stMimes["gtar"] = "application/x-gtar" />
		<cfset stMimes["gz"] = "application/x-compressed" />
		<cfset stMimes["gzip"] = "application/x-gzip" />
		<cfset stMimes["h"] = "text/plain" />
		<cfset stMimes["hdf"] = "application/x-hdf" />
		<cfset stMimes["help"] = "application/x-helpfile" />
		<cfset stMimes["hgl"] = "application/vnd.hp-hpgl" />
		<cfset stMimes["hh"] = "text/plain" />
		<cfset stMimes["hlb"] = "text/x-script" />
		<cfset stMimes["hlp"] = "application/hlp" />
		<cfset stMimes["hpg"] = "application/vnd.hp-hpgl" />
		<cfset stMimes["hpgl"] = "application/vnd.hp-hpgl" />
		<cfset stMimes["hqx"] = "application/binhex" />
		<cfset stMimes["hta"] = "application/hta" />
		<cfset stMimes["htc"] = "text/x-component" />
		<cfset stMimes["htm"] = "text/html" />
		<cfset stMimes["html"] = "text/html" />
		<cfset stMimes["htmls"] = "text/html" />
		<cfset stMimes["htt"] = "text/webviewhtml" />
		<cfset stMimes["htx"] = "text/html" />
		<cfset stMimes["ico"] = "image/x-icon" />
		<cfset stMimes["idc"] = "text/plain" />
		<cfset stMimes["ief"] = "image/ief" />
		<cfset stMimes["iefs"] = "image/ief" />
		<cfset stMimes["iges"] = "application/iges" />
		<cfset stMimes["igs"] = "application/iges" />
		<cfset stMimes["iii"] = "application/x-iphone" />
		<cfset stMimes["ima"] = "application/x-ima" />
		<cfset stMimes["imap"] = "application/x-httpd-imap" />
		<cfset stMimes["img"] = "application/octet-stream" />
		<cfset stMimes["inf"] = "application/inf" />
		<cfset stMimes["ins"] = "application/x-internet-signup" />
		<cfset stMimes["ins"] = "application/x-internett-signup" />
		<cfset stMimes["ip"] = "application/x-ip2" />
		<cfset stMimes["iso"] = "application/octet-stream" />
		<cfset stMimes["isp"] = "application/x-internet-signup" />
		<cfset stMimes["isu"] = "video/x-isvideo" />
		<cfset stMimes["it"] = "audio/it" />
		<cfset stMimes["iv"] = "application/x-inventor" />
		<cfset stMimes["ivr"] = "i-world/i-vrml" />
		<cfset stMimes["ivy"] = "application/x-livescreen" />
		<cfset stMimes["jam"] = "audio/x-jam" />
		<cfset stMimes["jar"] = "application/java-archive" />
		<cfset stMimes["jardiff"] = "application/x-java-archive-diff" />
		<cfset stMimes["jav"] = "text/plain" />
		<cfset stMimes["jav"] = "text/x-java-source" />
		<cfset stMimes["java"] = "text/plain" />
		<cfset stMimes["java"] = "text/x-java-source" />
		<cfset stMimes["jcm"] = "application/x-java-commerce" />
		<cfset stMimes["jfif-tbnl"] = "image/jpeg" />
		<cfset stMimes["jfif"] = "image/jpeg" />
		<cfset stMimes["jfif"] = "image/pipeg" />
		<cfset stMimes["jfif"] = "image/pjpeg" />
		<cfset stMimes["jng"] = "image/x-jng" />
		<cfset stMimes["jnlp"] = "application/x-java-jnlp-file" />
		<cfset stMimes["jpe"] = "image/jpeg" />
		<cfset stMimes["jpeg"] = "image/jpeg" />
		<cfset stMimes["jpg"] = "image/jpeg" />
		<cfset stMimes["jps"] = "image/x-jps" />
		<cfset stMimes["js"] = "application/x-javascript" />
		<cfset stMimes["js"] = "text/javascript" />
		<cfset stMimes["jut"] = "image/jutvision" />
		<cfset stMimes["kar"] = "audio/midi" />
		<cfset stMimes["kar"] = "music/x-karaoke" />
		<cfset stMimes["ksh"] = "application/x-ksh" />
		<cfset stMimes["ksh"] = "text/x-script.ksh" />
		<cfset stMimes["la"] = "audio/nspaudio" />
		<cfset stMimes["la"] = "audio/x-nspaudio" />
		<cfset stMimes["lam"] = "audio/x-liveaudio" />
		<cfset stMimes["latex"] = "application/x-latex" />
		<cfset stMimes["lha"] = "application/lha" />
		<cfset stMimes["lha"] = "application/octet-stream" />
		<cfset stMimes["lha"] = "application/x-lha" />
		<cfset stMimes["lhx"] = "application/octet-stream" />
		<cfset stMimes["list"] = "text/plain" />
		<cfset stMimes["lma"] = "audio/nspaudio" />
		<cfset stMimes["lma"] = "audio/x-nspaudio" />
		<cfset stMimes["log"] = "text/plain" />
		<cfset stMimes["lsf"] = "video/x-la-asf" />
		<cfset stMimes["lsp"] = "application/x-lisp" />
		<cfset stMimes["lsp"] = "text/x-script.lisp" />
		<cfset stMimes["lst"] = "text/plain" />
		<cfset stMimes["lsx"] = "text/x-la-asf" />
		<cfset stMimes["lsx"] = "video/x-la-asf" />
		<cfset stMimes["ltx"] = "application/x-latex" />
		<cfset stMimes["lzh"] = "application/octet-stream" />
		<cfset stMimes["lzh"] = "application/x-lzh" />
		<cfset stMimes["lzx"] = "application/lzx" />
		<cfset stMimes["lzx"] = "application/octet-stream" />
		<cfset stMimes["lzx"] = "application/x-lzx" />
		<cfset stMimes["m13"] = "application/x-msmediaview" />
		<cfset stMimes["m14"] = "application/x-msmediaview" />
		<cfset stMimes["m1v"] = "video/mpeg" />
		<cfset stMimes["m2a"] = "audio/mpeg" />
		<cfset stMimes["m2v"] = "video/mpeg" />
		<cfset stMimes["m3u"] = "audio/x-mpegurl" />
		<cfset stMimes["m"] = "text/x-m" />
		<cfset stMimes["man"] = "application/x-troff-man" />
		<cfset stMimes["map"] = "application/x-navimap" />
		<cfset stMimes["mar"] = "text/plain" />
		<cfset stMimes["mbd"] = "application/mbedlet" />
		<cfset stMimes["mc"] = "application/x-magic-cap-package-1.0" />
		<cfset stMimes["mcd"] = "application/mcad" />
		<cfset stMimes["mcd"] = "application/x-mathcad" />
		<cfset stMimes["mcf"] = "image/vasa" />
		<cfset stMimes["mcf"] = "text/mcf" />
		<cfset stMimes["mcp"] = "application/netmc" />
		<cfset stMimes["mdb"] = "application/x-msaccess" />
		<cfset stMimes["me"] = "application/x-troff-me" />
		<cfset stMimes["mht"] = "message/rfc822" />
		<cfset stMimes["mhtml"] = "message/rfc822" />
		<cfset stMimes["mid"] = "audio/mid" />
		<cfset stMimes["mid"] = "audio/midi" />
		<cfset stMimes["mid"] = "audio/x-mid" />
		<cfset stMimes["mid"] = "audio/x-midi" />
		<cfset stMimes["midi"] = "audio/midi" />
		<cfset stMimes["midi"] = "audio/x-mid" />
		<cfset stMimes["midi"] = "audio/x-midi" />
		<cfset stMimes["mif"] = "application/x-frame" />
		<cfset stMimes["mif"] = "application/x-mif" />
		<cfset stMimes["mime"] = "message/rfc822" />
		<cfset stMimes["mime"] = "www/mime" />
		<cfset stMimes["mjf"] = "audio/x-vnd.audioexplosion.mjuicemediafile" />
		<cfset stMimes["mjpg"] = "video/x-motion-jpeg" />
		<cfset stMimes["mm"] = "application/base64" />
		<cfset stMimes["mm"] = "application/x-meme" />
		<cfset stMimes["mme"] = "application/base64" />
		<cfset stMimes["mml"] = "text/mathml" />
		<cfset stMimes["mng"] = "video/x-mng" />
		<cfset stMimes["mod"] = "audio/mod" />
		<cfset stMimes["moov"] = "video/quicktime" />
		<cfset stMimes["mov"] = "video/quicktime" />
		<cfset stMimes["movie"] = "video/x-sgi-movie" />
		<cfset stMimes["mp2"] = "audio/mpeg" />
		<cfset stMimes["mp3"] = "audio/mpeg" />
		<cfset stMimes["mpa"] = "audio/mpeg" />
		<cfset stMimes["mpc"] = "application/x-project" />
		<cfset stMimes["mpe"] = "video/mpeg" />
		<cfset stMimes["mpeg"] = "video/mpeg" />
		<cfset stMimes["mpg"] = "video/mpeg" />
		<cfset stMimes["mpga"] = "audio/mpeg" />
		<cfset stMimes["mpp"] = "application/vnd.ms-project" />
		<cfset stMimes["mpt"] = "application/x-project" />
		<cfset stMimes["mpv2"] = "video/mpeg" />
		<cfset stMimes["mpv"] = "application/x-project" />
		<cfset stMimes["mpx"] = "application/x-project" />
		<cfset stMimes["mrc"] = "application/marc" />
		<cfset stMimes["ms"] = "application/x-troff-ms" />
		<cfset stMimes["msi"] = "application/octet-stream" />
		<cfset stMimes["msm"] = "application/octet-stream" />
		<cfset stMimes["msp"] = "application/octet-stream" />
		<cfset stMimes["mv"] = "video/x-sgi-movie" />
		<cfset stMimes["mvb"] = "application/x-msmediaview" />
		<cfset stMimes["my"] = "audio/make" />
		<cfset stMimes["mzz"] = "application/x-vnd.audioexplosion.mzz" />
		<cfset stMimes["nap"] = "image/naplps" />
		<cfset stMimes["naplps"] = "image/naplps" />
		<cfset stMimes["nc"] = "application/x-netcdf" />
		<cfset stMimes["ncm"] = "application/vnd.nokia.configuration-message" />
		<cfset stMimes["nif"] = "image/x-niff" />
		<cfset stMimes["niff"] = "image/x-niff" />
		<cfset stMimes["nix"] = "application/x-mix-transfer" />
		<cfset stMimes["nsc"] = "application/x-conference" />
		<cfset stMimes["nvd"] = "application/x-navidoc" />
		<cfset stMimes["nws"] = "message/rfc822" />
		<cfset stMimes["o"] = "application/octet-stream" />
		<cfset stMimes["oda"] = "application/oda" />
		<cfset stMimes["omc"] = "application/x-omc" />
		<cfset stMimes["omcd"] = "application/x-omcdatamaker" />
		<cfset stMimes["omcr"] = "application/x-omcregerator" />
		<cfset stMimes["p10"] = "application/pkcs10" />
		<cfset stMimes["p10"] = "application/x-pkcs10" />
		<cfset stMimes["p12"] = "application/pkcs-12" />
		<cfset stMimes["p12"] = "application/x-pkcs12" />
		<cfset stMimes["p7a"] = "application/x-pkcs7-signature" />
		<cfset stMimes["p7b"] = "application/x-pkcs7-certificates" />
		<cfset stMimes["p7c"] = "application/pkcs7-mime" />
		<cfset stMimes["p7c"] = "application/x-pkcs7-mime" />
		<cfset stMimes["p7m"] = "application/pkcs7-mime" />
		<cfset stMimes["p7m"] = "application/x-pkcs7-mime" />
		<cfset stMimes["p7r"] = "application/x-pkcs7-certreqresp" />
		<cfset stMimes["p7s"] = "application/pkcs7-signature" />
		<cfset stMimes["p7s"] = "application/x-pkcs7-signature" />
		<cfset stMimes["p"] = "text/x-pascal" />
		<cfset stMimes["part"] = "application/pro_eng" />
		<cfset stMimes["pas"] = "text/pascal" />
		<cfset stMimes["pbm"] = "image/x-portable-bitmap" />
		<cfset stMimes["pcl"] = "application/vnd.hp-pcl" />
		<cfset stMimes["pcl"] = "application/x-pcl" />
		<cfset stMimes["pct"] = "image/x-pict" />
		<cfset stMimes["pcx"] = "image/x-pcx" />
		<cfset stMimes["pdb"] = "application/x-pilot" />
		<cfset stMimes["pdf"] = "application/pdf" />
		<cfset stMimes["pem"] = "application/x-x509-ca-cert" />
		<cfset stMimes["pfunk"] = "audio/make" />
		<cfset stMimes["pfunk"] = "audio/make.my.funk" />
		<cfset stMimes["pfx"] = "application/x-pkcs12" />
		<cfset stMimes["pgm"] = "image/x-portable-graymap" />
		<cfset stMimes["pgm"] = "image/x-portable-greymap" />
		<cfset stMimes["pic"] = "image/pict" />
		<cfset stMimes["pict"] = "image/pict" />
		<cfset stMimes["pkg"] = "application/x-newton-compatible-pkg" />
		<cfset stMimes["pko"] = "application/vnd.ms-pki.pko" />
		<cfset stMimes["pko"] = "application/ynd.ms-pkipko" />
		<cfset stMimes["pl"] = "application/x-perl" />
		<cfset stMimes["pl"] = "text/plain" />
		<cfset stMimes["pl"] = "text/x-script.perl" />
		<cfset stMimes["plx"] = "application/x-pixclscript" />
		<cfset stMimes["pm4"] = "application/x-pagemaker" />
		<cfset stMimes["pm5"] = "application/x-pagemaker" />
		<cfset stMimes["pm"] = "application/x-perl" />
		<cfset stMimes["pm"] = "image/x-xpixmap" />
		<cfset stMimes["pm"] = "text/x-script.perl-module" />
		<cfset stMimes["pma"] = "application/x-perfmon" />
		<cfset stMimes["pmc"] = "application/x-perfmon" />
		<cfset stMimes["pml"] = "application/x-perfmon" />
		<cfset stMimes["pmr"] = "application/x-perfmon" />
		<cfset stMimes["pmw"] = "application/x-perfmon" />
		<cfset stMimes["png"] = "image/png" />
		<cfset stMimes["pnm"] = "application/x-portable-anymap" />
		<cfset stMimes["pnm"] = "image/x-portable-anymap" />
		<cfset stMimes["pot,"] = "application/vnd.ms-powerpoint" />
		<cfset stMimes["pot"] = "application/mspowerpoint" />
		<cfset stMimes["pot"] = "application/vnd.ms-powerpoint" />
		<cfset stMimes["pov"] = "model/x-pov" />
		<cfset stMimes["ppa"] = "application/vnd.ms-powerpoint" />
		<cfset stMimes["ppm"] = "image/x-portable-pixmap" />
		<cfset stMimes["pps"] = "application/mspowerpoint" />
		<cfset stMimes["ppt"] = "application/mspowerpoint" />
		<cfset stMimes["ppz"] = "application/mspowerpoint" />
		<cfset stMimes["prc"] = "application/x-pilot" />
		<cfset stMimes["pre"] = "application/x-freelance" />
		<cfset stMimes["prf"] = "application/pics-rules" />
		<cfset stMimes["prt"] = "application/pro_eng" />
		<cfset stMimes["ps"] = "application/postscript" />
		<cfset stMimes["psd"] = "application/octet-stream" />
		<cfset stMimes["pub"] = "application/x-mspublisher" />
		<cfset stMimes["pvu"] = "paleovu/x-pv" />
		<cfset stMimes["pwz"] = "application/vnd.ms-powerpoint" />
		<cfset stMimes["py"] = "text/x-script.phyton" />
		<cfset stMimes["pyc"] = "applicaiton/x-bytecode.python" />
		<cfset stMimes["qcp"] = "audio/vnd.qcelp" />
		<cfset stMimes["qd3"] = "x-world/x-3dmf" />
		<cfset stMimes["qd3d"] = "x-world/x-3dmf" />
		<cfset stMimes["qif"] = "image/x-quicktime" />
		<cfset stMimes["qt"] = "video/quicktime" />
		<cfset stMimes["qtc"] = "video/x-qtc" />
		<cfset stMimes["qti"] = "image/x-quicktime" />
		<cfset stMimes["qtif"] = "image/x-quicktime" />
		<cfset stMimes["ra"] = "audio/x-pn-realaudio" />
		<cfset stMimes["ra"] = "audio/x-pn-realaudio-plugin" />
		<cfset stMimes["ra"] = "audio/x-realaudio" />
		<cfset stMimes["ram"] = "audio/x-pn-realaudio" />
		<cfset stMimes["rar"] = "application/x-rar-compressed" />
		<cfset stMimes["ras"] = "application/x-cmu-raster" />
		<cfset stMimes["ras"] = "image/cmu-raster" />
		<cfset stMimes["ras"] = "image/x-cmu-raster" />
		<cfset stMimes["rast"] = "image/cmu-raster" />
		<cfset stMimes["rexx"] = "text/x-script.rexx" />
		<cfset stMimes["rf"] = "image/vnd.rn-realflash" />
		<cfset stMimes["rgb"] = "image/x-rgb" />
		<cfset stMimes["rm"] = "application/vnd.rn-realmedia" />
		<cfset stMimes["rm"] = "audio/x-pn-realaudio" />
		<cfset stMimes["rmi"] = "audio/mid" />
		<cfset stMimes["rmm"] = "audio/x-pn-realaudio" />
		<cfset stMimes["rmp"] = "audio/x-pn-realaudio" />
		<cfset stMimes["rmp"] = "audio/x-pn-realaudio-plugin" />
		<cfset stMimes["rng"] = "application/ringing-tones" />
		<cfset stMimes["rng"] = "application/vnd.nokia.ringing-tone" />
		<cfset stMimes["rnx"] = "application/vnd.rn-realplayer" />
		<cfset stMimes["roff"] = "application/x-troff" />
		<cfset stMimes["rp"] = "image/vnd.rn-realpix" />
		<cfset stMimes["rpm"] = "application/x-redhat-package-manager" />
		<cfset stMimes["rpm"] = "audio/x-pn-realaudio-plugin" />
		<cfset stMimes["rss"] = "text/xml" />
		<cfset stMimes["rt"] = "text/richtext" />
		<cfset stMimes["rt"] = "text/vnd.rn-realtext" />
		<cfset stMimes["rtf"] = "application/rtf" />
		<cfset stMimes["rtf"] = "application/x-rtf" />
		<cfset stMimes["rtf"] = "text/richtext" />
		<cfset stMimes["rtx"] = "application/rtf" />
		<cfset stMimes["rtx"] = "text/richtext" />
		<cfset stMimes["run"] = "application/x-makeself" />
		<cfset stMimes["rv"] = "video/vnd.rn-realvideo" />
		<cfset stMimes["s3m"] = "audio/s3m" />
		<cfset stMimes["s"] = "text/x-asm" />
		<cfset stMimes["saveme"] = "application/octet-stream" />
		<cfset stMimes["sbk"] = "application/x-tbook" />
		<cfset stMimes["scd"] = "application/x-msschedule" />
		<cfset stMimes["scm"] = "application/x-lotusscreencam" />
		<cfset stMimes["scm"] = "text/x-script.guile" />
		<cfset stMimes["scm"] = "text/x-script.scheme" />
		<cfset stMimes["scm"] = "video/x-scm" />
		<cfset stMimes["sct"] = "text/scriptlet" />
		<cfset stMimes["sdml"] = "text/plain" />
		<cfset stMimes["sdp"] = "application/sdp" />
		<cfset stMimes["sdp"] = "application/x-sdp" />
		<cfset stMimes["sdr"] = "application/sounder" />
		<cfset stMimes["sea"] = "application/sea" />
		<cfset stMimes["sea"] = "application/x-sea" />
		<cfset stMimes["set"] = "application/set" />
		<cfset stMimes["setpay"] = "application/set-payment-initiation" />
		<cfset stMimes["setreg"] = "application/set-registration-initiation" />
		<cfset stMimes["sgm"] = "text/sgml" />
		<cfset stMimes["sgm"] = "text/x-sgml" />
		<cfset stMimes["sgml"] = "text/sgml" />
		<cfset stMimes["sgml"] = "text/x-sgml" />
		<cfset stMimes["sh"] = "application/x-bsh" />
		<cfset stMimes["sh"] = "application/x-sh" />
		<cfset stMimes["sh"] = "application/x-shar" />
		<cfset stMimes["sh"] = "text/x-script.sh" />
		<cfset stMimes["shar"] = "application/x-bsh" />
		<cfset stMimes["shar"] = "application/x-shar" />
		<cfset stMimes["shtml"] = "text/html" />
		<cfset stMimes["shtml"] = "text/x-server-parsed-html" />
		<cfset stMimes["sid"] = "audio/x-psid" />
		<cfset stMimes["sit"] = "application/x-sit" />
		<cfset stMimes["sit"] = "application/x-stuffit" />
		<cfset stMimes["skd"] = "application/x-koan" />
		<cfset stMimes["skm"] = "application/x-koan" />
		<cfset stMimes["skp"] = "application/x-koan" />
		<cfset stMimes["skt"] = "application/x-koan" />
		<cfset stMimes["sl"] = "application/x-seelogo" />
		<cfset stMimes["smi"] = "application/smil" />
		<cfset stMimes["smil"] = "application/smil" />
		<cfset stMimes["snd"] = "audio/basic" />
		<cfset stMimes["snd"] = "audio/x-adpcm" />
		<cfset stMimes["sol"] = "application/solids" />
		<cfset stMimes["spc"] = "application/x-pkcs7-certificates" />
		<cfset stMimes["spc"] = "text/x-speech" />
		<cfset stMimes["spl"] = "application/futuresplash" />
		<cfset stMimes["spr"] = "application/x-sprite" />
		<cfset stMimes["sprite"] = "application/x-sprite" />
		<cfset stMimes["src"] = "application/x-wais-source" />
		<cfset stMimes["ssi"] = "text/x-server-parsed-html" />
		<cfset stMimes["ssm"] = "application/streamingmedia" />
		<cfset stMimes["sst"] = "application/vnd.ms-pki.certstore" />
		<cfset stMimes["sst"] = "application/vnd.ms-pkicertstore" />
		<cfset stMimes["step"] = "application/step" />
		<cfset stMimes["stl"] = "application/sla" />
		<cfset stMimes["stl"] = "application/vnd.ms-pki.stl" />
		<cfset stMimes["stl"] = "application/vnd.ms-pkistl" />
		<cfset stMimes["stl"] = "application/x-navistyle" />
		<cfset stMimes["stm"] = "text/html" />
		<cfset stMimes["stp"] = "application/step" />
		<cfset stMimes["sv4cpio"] = "application/x-sv4cpio" />
		<cfset stMimes["sv4crc"] = "application/x-sv4crc" />
		<cfset stMimes["svf"] = "image/vnd.dwg" />
		<cfset stMimes["svf"] = "image/x-dwg" />
		<cfset stMimes["svg"] = "image/svg+xml" />
		<cfset stMimes["svr"] = "application/x-world" />
		<cfset stMimes["svr"] = "x-world/x-svr" />
		<cfset stMimes["swf"] = "application/x-shockwave-flash" />
		<cfset stMimes["t"] = "application/x-troff" />
		<cfset stMimes["talk"] = "text/x-speech" />
		<cfset stMimes["tar"] = "application/x-tar" />
		<cfset stMimes["tbk"] = "application/toolbook" />
		<cfset stMimes["tbk"] = "application/x-tbook" />
		<cfset stMimes["tcl"] = "application/x-tcl" />
		<cfset stMimes["tcl"] = "text/x-script.tcl" />
		<cfset stMimes["tcsh"] = "text/x-script.tcsh" />
		<cfset stMimes["tex"] = "application/x-tex" />
		<cfset stMimes["texi"] = "application/x-texinfo" />
		<cfset stMimes["texinfo"] = "application/x-texinfo" />
		<cfset stMimes["text"] = "application/plain" />
		<cfset stMimes["text"] = "text/plain" />
		<cfset stMimes["tgz"] = "application/gnutar" />
		<cfset stMimes["tgz"] = "application/x-compressed" />
		<cfset stMimes["tif"] = "image/tiff" />
		<cfset stMimes["tiff"] = "image/tiff" />
		<cfset stMimes["tk"] = "application/x-tcl" />
		<cfset stMimes["tr"] = "application/x-troff" />
		<cfset stMimes["trm"] = "application/x-msterminal" />
		<cfset stMimes["tsi"] = "audio/tsp-audio" />
		<cfset stMimes["tsp"] = "application/dsptype" />
		<cfset stMimes["tsp"] = "audio/tsplayer" />
		<cfset stMimes["tsv"] = "text/tab-separated-values" />
		<cfset stMimes["turbot"] = "image/florian" />
		<cfset stMimes["txt"] = "text/plain" />
		<cfset stMimes["uil"] = "text/x-uil" />
		<cfset stMimes["uls"] = "text/iuls" />
		<cfset stMimes["uni"] = "text/uri-list" />
		<cfset stMimes["unis"] = "text/uri-list" />
		<cfset stMimes["unv"] = "application/i-deas" />
		<cfset stMimes["uri"] = "text/uri-list" />
		<cfset stMimes["uris"] = "text/uri-list" />
		<cfset stMimes["ustar"] = "application/x-ustar" />
		<cfset stMimes["ustar"] = "multipart/x-ustar" />
		<cfset stMimes["uu"] = "application/octet-stream" />
		<cfset stMimes["uu"] = "text/x-uuencode" />
		<cfset stMimes["uue"] = "text/x-uuencode" />
		<cfset stMimes["vcd"] = "application/x-cdlink" />
		<cfset stMimes["vcf"] = "text/x-vcard" />
		<cfset stMimes["vcs"] = "text/x-vcalendar" />
		<cfset stMimes["vda"] = "application/vda" />
		<cfset stMimes["vdo"] = "video/vdo" />
		<cfset stMimes["vew"] = "application/groupwise" />
		<cfset stMimes["viv"] = "video/vivo" />
		<cfset stMimes["viv"] = "video/vnd.vivo" />
		<cfset stMimes["vivo"] = "video/vivo" />
		<cfset stMimes["vivo"] = "video/vnd.vivo" />
		<cfset stMimes["vmd"] = "application/vocaltec-media-desc" />
		<cfset stMimes["vmf"] = "application/vocaltec-media-file" />
		<cfset stMimes["voc"] = "audio/voc" />
		<cfset stMimes["voc"] = "audio/x-voc" />
		<cfset stMimes["vos"] = "video/vosaic" />
		<cfset stMimes["vox"] = "audio/voxware" />
		<cfset stMimes["vqe"] = "audio/x-twinvq-plugin" />
		<cfset stMimes["vqf"] = "audio/x-twinvq" />
		<cfset stMimes["vql"] = "audio/x-twinvq-plugin" />
		<cfset stMimes["vrml"] = "application/x-vrml" />
		<cfset stMimes["vrml"] = "model/vrml" />
		<cfset stMimes["vrml"] = "x-world/x-vrml" />
		<cfset stMimes["vrt"] = "x-world/x-vrt" />
		<cfset stMimes["vsd"] = "application/x-visio" />
		<cfset stMimes["vst"] = "application/x-visio" />
		<cfset stMimes["vsw"] = "application/x-visio" />
		<cfset stMimes["w60"] = "application/wordperfect6.0" />
		<cfset stMimes["w61"] = "application/wordperfect6.1" />
		<cfset stMimes["w6w"] = "application/msword" />
		<cfset stMimes["war"] = "application/java-archive" />
		<cfset stMimes["wav"] = "audio/wav" />
		<cfset stMimes["wav"] = "audio/x-wav" />
		<cfset stMimes["wb1"] = "application/x-qpro" />
		<cfset stMimes["wbmp"] = "image/vnd.wap.wbmp" />
		<cfset stMimes["wbmp"] = "image/vnd.wap.wbmp" />
		<cfset stMimes["wcm"] = "application/vnd.ms-works" />
		<cfset stMimes["wdb"] = "application/vnd.ms-works" />
		<cfset stMimes["web"] = "application/vnd.xara" />
		<cfset stMimes["wiz"] = "application/msword" />
		<cfset stMimes["wk1"] = "application/x-123" />
		<cfset stMimes["wks"] = "application/vnd.ms-works" />
		<cfset stMimes["wmf"] = "application/x-msmetafile" />
		<cfset stMimes["wmf"] = "windows/metafile" />
		<cfset stMimes["wml"] = "text/vnd.wap.wml" />
		<cfset stMimes["wmlc"] = "application/vnd.wap.wmlc" />
		<cfset stMimes["wmls"] = "text/vnd.wap.wmlscript" />
		<cfset stMimes["wmlsc"] = "application/vnd.wap.wmlscriptc" />
		<cfset stMimes["wmv"] = "video/x-ms-wmv" />
		<cfset stMimes["word"] = "application/msword" />
		<cfset stMimes["wp5"] = "application/wordperfect" />
		<cfset stMimes["wp6"] = "application/wordperfect" />
		<cfset stMimes["wp"] = "application/wordperfect" />
		<cfset stMimes["wpd"] = "application/wordperfect" />
		<cfset stMimes["wps"] = "application/vnd.ms-works" />
		<cfset stMimes["wq1"] = "application/x-lotus" />
		<cfset stMimes["wri"] = "application/mswrite" />
		<cfset stMimes["wrl"] = "application/x-world" />
		<cfset stMimes["wsc"] = "text/scriplet" />
		<cfset stMimes["wsrc"] = "application/x-wais-source" />
		<cfset stMimes["wtk"] = "application/x-wintalk" />
		<cfset stMimes["x-png"] = "image/png" />
		<cfset stMimes["xaf"] = "x-world/x-vrml" />
		<cfset stMimes["xbm"] = "image/xbm" />
		<cfset stMimes["xdr"] = "video/x-amt-demorun" />
		<cfset stMimes["xgz"] = "xgl/drawing" />
		<cfset stMimes["xhtml"] = "application/xhtml+xml" />
		<cfset stMimes["xif"] = "image/vnd.xiff" />
		<cfset stMimes["xl"] = "application/excel" />
		<cfset stMimes["xla"] = "application/excel" />
		<cfset stMimes["xlb"] = "application/excel" />
		<cfset stMimes["xlc"] = "application/excel" />
		<cfset stMimes["xld"] = "application/excel" />
		<cfset stMimes["xlk"] = "application/excel" />
		<cfset stMimes["xll"] = "application/excel" />
		<cfset stMimes["xlm"] = "application/excel" />
		<cfset stMimes["xls"] = "application/excel" />
		<cfset stMimes["xlt"] = "application/excel" />
		<cfset stMimes["xlv"] = "application/excel" />
		<cfset stMimes["xlw"] = "application/excel" />
		<cfset stMimes["xm"] = "audio/xm" />
		<cfset stMimes["xml"] = "text/xml" />
		<cfset stMimes["xmz"] = "xgl/movie" />
		<cfset stMimes["xof"] = "x-world/x-vrml" />
		<cfset stMimes["xpi"] = "application/x-xpinstall" />
		<cfset stMimes["xpix"] = "application/x-vnd.ls-xpix" />
		<cfset stMimes["xpm"] = "image/x-xpixmap" />
		<cfset stMimes["xpm"] = "image/xpm" />
		<cfset stMimes["xsr"] = "video/x-amt-showrun" />
		<cfset stMimes["xwd"] = "image/x-xwd" />
		<cfset stMimes["xwd"] = "image/x-xwindowdump" />
		<cfset stMimes["xyz"] = "chemical/x-pdb" />
		<cfset stMimes["z"] = "application/x-compressed" />
		<cfset stMimes["zip"] = "application/zip" />
		<cfset stMimes["zoo"] = "application/octet-stream" />
		<cfset stMimes["zsh"] = "text/x-script.zsh" />
		
		<cfreturn stMimes />
	</cffunction>

	<cffunction name="getMimeType" returntype="string" hint="Return Mime Type based on lookup of file extension" output="No">
		<cfargument required="Yes" name="filename" type="string">

		<cfset var mimeStruct = getMimeTypes() />
		<cfset var ext = listLast(arguments.filename, ".") />
		
		<cfif structKeyExists(mimeStruct,ext)>
			<cfreturn mimeStruct[ext] />
		<cfelse>
			<cfreturn "text/plain" />
		</cfif>
	</cffunction>

	<cffunction name="getFileProperties" access="public" returntype="struct" description="Returns a struct of file information" output="false">
		<cfargument name="filename" type="string" required="true" hint="The file to query" />
		
		<cfset var stResult = structnew() />
		<cfset var qFile = querynew("empty") />
		
		<cfif not fileexists(arguments.filename)>
			<cfset arguments.filename = expandpath(arguments.filename) />
		</cfif>
		
		<cfdirectory action="list" name="qFile" directory="#getDirectoryFromPath(arguments.filename)#" filter="#getFileFromPath(arguments.fileName)#" />
		
		<cfif qFile.recordcount>
			<cfset stResult.ext = listlast(arguments.filename,".") />
			<cfset stResult.file = getFileFromPath(arguments.fileName) />
			<cfset stResult.directory = getDirectoryFromPath(arguments.filename) />
			<cfset stResult.mimetype = getMimeType(stResult.file) />
			<cfset stResult.size = qFile.size[1] />
			<cfset stResult.datelastmodified = qFile.datelastmodified[1] />
			<cfset stResult.attributes = qFile.attributes[1] />
		<cfelse>
			<cfthrow message="File doesn't exist: #arguments.filename#" />
		</cfif>
		
		<cfreturn stResult />
	</cffunction>

	<cffunction name="getFileSize" access="public" returntype="numeric" description="Returns the size of the specified file" output="false">
		<cfargument name="filename" type="string" required="true" hint="The file to query" />
		
		<cfset var fileinfo = getFileProperties(arguments.filename) />
		
		<cfreturn fileinfo.size />
	</cffunction>

</cfcomponent>