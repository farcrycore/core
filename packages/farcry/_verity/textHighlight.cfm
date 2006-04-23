<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_verity/textHighlight.cfm,v 1.4 2005/08/09 03:54:39 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:39 $
$Name: milestone_3-0-0 $
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