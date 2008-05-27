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
$Header: /cvs/farcry/core/packages/farcry/_verity/htmlStripper.cfm,v 1.3 2005/08/09 03:54:39 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:39 $
$Name: milestone_3-0-1 $
$Revision: 1.3 $

|| DESCRIPTION || 
$Description: HTML Stripper$


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