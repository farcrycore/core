<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_verity/htmlStripper.cfm,v 1.2 2003/09/24 02:26:55 brendan Exp $
$Author: brendan $
$Date: 2003/09/24 02:26:55 $
$Name: b201 $
$Revision: 1.2 $

|| DESCRIPTION || 
$Description: HTML Stripper$
$TODO: $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<CFSCRIPT>
	modsummary = REReplaceNoCase(arguments.content, "<[^>]*>", "", "all");
	// need a regex to strip incomplete HTML from end of summary.  this will do for now GB
	modsummary = REreplacenocase(modsummary, "<table .*$", "", "all");
	modsummary = REreplacenocase(modsummary, "<a .*$", "", "all");
	modsummary = REreplacenocase(modsummary, "<td .*$", "", "all");
	modsummary = REreplacenocase(modsummary, "<tr .*$", "", "all");
	modsummary = REreplacenocase(modsummary, "<img .*$", "", "all");
	modsummary = REreplacenocase(modsummary, "<font .*$", "", "all");
	modsummary = REreplacenocase(modsummary, "<p .*$", "", "all");
	modsummary = REreplacenocase(modsummary, "/images.*>", "", "all");
	modsummary = REreplacenocase(modsummary, "<$", "", "all");
	modsummary = replacenocase(modsummary, "&nbsp;", " ", "all");
	modsummary = replacenocase(modsummary, "&##160;", " ", "all"); //nbsp
	modsummary = replacenocase(modsummary, "&amp;", "&", "all");
	modsummary = replacenocase(modsummary, "&##8217;", "'", "all"); // smart apost
	modsummary = replacenocase(modsummary, "&##174;", "(R)", "all"); // rego
	modsummary = replacenocase(modsummary, "&##8482;", "(tm)", "all"); // tm
</CFSCRIPT>