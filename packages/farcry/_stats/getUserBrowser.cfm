<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_stats/getUserBrowser.cfm,v 1.7 2004/06/02 00:48:37 brendan Exp $
$Author: brendan $
$Date: 2004/06/02 00:48:37 $
$Name: milestone_2-2-1 $
$Revision: 1.7 $

|| DESCRIPTION || 
$Description: get users browser $
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfscript>
	browserName="Unknown: ";
	if (Len(user_agent))
	{
		browserVersion=user_agent;
		if (FindNoCase("MSIE",user_agent) AND NOT findNoCase("opera",user_agent) )
		{ 
			browserName="MSIE";
			browserVersion=Val(RemoveChars(user_agent,1,FindNoCase("MSIE",user_agent)+4));
		}
		else if (findNoCase("opera",user_agent))
		{
			browserName = "Opera";
			browserVersion = Val(RemoveChars(user_agent,1,FindNoCase("Opera",user_agent)+5));
		}	
		else if (findNoCase("safari",user_agent))
		// Safari (Macintosh)
		{
			browsername = "Safari";
			browserVersion = DecimalFormat(Int(Val(RemoveChars(user_agent,1,FindNoCase("Safari/",user_agent)+6)))/100);
			// browserVersion = Left(DecimalFormat(browserVersion), Evaluate(Len(DecimalFormat(browserVersion))-1));
			// If you'd prefer browser version to be displayed as 1.2 instead of 1.25 (since Apple releases new builds often) Then use BOTH lines (don't remark the first one).
		}	
		else if (findNoCase("Camino/",user_agent))
		// Camino (Macintosh)
		{
			browsername = "Camino";
			browserVersion = Val(RemoveChars(user_agent,1,FindNoCase("Camino/",user_agent)+6));
		}
		else if (findNoCase("Galeon/",user_agent))
		// Galeon (Gnome browser)
		{
			browsername = "Galeon";
			browserVersion = Val(RemoveChars(user_agent,1,FindNoCase("Galeon/",user_agent)+6));
			//browserVersion = ListGetAt(RemoveChars(user_agent,1,FindNoCase("Galeon/",user_agent)+6),1," ");
			// If you'd prefer browser version to be displayed as 1.3.11a instead of 1.3, then use the above line instead.
		}
		else if (findNoCase("Googlebot",user_agent))
		{
			browsername = "Googlebot";
			browserVersion = Val(RemoveChars(user_agent,1,FindNoCase("Googlebot",user_agent)+9));
		}	
		else if (findNoCase("ia_archiver",user_agent))
		{
			browsername = "ia archiver";
			browserVersion = "";// Not sure about how to disect the user_agent string for version just yet.
		}
		else	
		{
			if (FindNoCase("Mozilla/",user_agent)) { 
				if (Int(Val(RemoveChars(user_agent,1,FindNoCase("Mozilla/",user_agent)+7))) LTE 4) {
					// Netscape Navigator Browsers (v1.x - 4.x)
					browserName = "Netscape";
					browserVersion = DecimalFormat(Val(RemoveChars(user_agent,1,FindNoCase("Mozilla/",user_agent)+7)));
				}
				else if (FindNoCase("Netscape6/",user_agent)) {
					// Netscape 6 browsers
					browserName = "Netscape";
					browserVersion = DecimalFormat(Val(RemoveChars(user_agent,1,FindNoCase("Netscape6/",user_agent)+9)));
				}
				else if (FindNoCase("Netscape/",user_agent)) {
					// All other (newer) Netscape Browsers
					browserName = "Netscape";
					browserVersion = DecimalFormat(Val(RemoveChars(user_agent,1,FindNoCase("Netscape/",user_agent)+8)));
				}
				else if (not FindNoCase("compatible",user_agent)) { 
					browserVersion=Val(RemoveChars(user_agent,1,Find("/",user_agent)));
					if (browserVersion lt 5) {
						//netscape browsers
						browserName="Netscape";	
					}
					else 
					{
						if (FindNoCase("Firefox/",user_agent)) {
							// Firefox Browsers (by Mozilla)
							browserName = "Firefox";
							browserVersion = Val(RemoveChars(user_agent,1,FindNoCase("Firefox/",user_agent)+7));
						} else if (FindNoCase("Firebird/",user_agent)) {
							// Firebird Browsers (now replaced by FireFox)
							browserName = "Firebird";
							browserVersion = Val(RemoveChars(user_agent,1,FindNoCase("Firebird/",user_agent)+8));
						} else {
							//mozilla browsers
							browserName = "Mozilla";
							browserVersion = Val(RemoveChars(user_agent,1,FindNoCase("rv:",user_agent)+2));
						}
					}
				}
				else
				{
					browserName="compatible"; 
				}
			}
			if (Find("ColdFusion",user_agent)) 
			{ 
				browserName="ColdFusion";
			}
		}
	} else {
		browserVersion = "unknown";
	}	
	stBroswer = structNew();
	stBrowser.name = trim(browsername);
	stBrowser.version = trim(browserversion);
</cfscript>

