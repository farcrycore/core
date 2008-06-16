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
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/farcry/_verity/textHighlight.cfm,v 1.4 2005/08/09 03:54:39 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:39 $
$Name: milestone_3-0-1 $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: text highlighter$


|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfscript>
/**
 * Applies a simple highlight to a word in a string.
 * 
 * @param string 	 The string to format. 
 * @param word 	 The word to highlight. 
 * @param front 	 This is the HTML that will be placed in front of the highlighted match. It defaults to <span style= 
 * @param back 	 This is the HTML that will be placed at the end of the highlighted match. Defaults to </span> 
 * @param matchCase 	 If true, the highlight will only match when the case is the same. Defaults to false. 
 * @author Raymond Camden (ray@camdenfamily.com) 
 * @version 1, July 30, 2001 
 */
	front = "<span style=""background-color: ##ededed; font-weight: bold;"">";
	back = "</span>";
	matchCase = false;
	if(ArrayLen(arguments) GTE 3) front = arguments[3];
	if(ArrayLen(arguments) GTE 4) back = arguments[4];
	if(ArrayLen(arguments) GTE 5) matchCase = arguments[5];
	if(NOT matchCase) returnString= REReplaceNoCase(arguments.content,"(#word#)","#front#\1#back#","ALL");
	else returnString= REReplace(arguments.content,"(#word#)","#front#\1#back#","ALL");
</cfscript>