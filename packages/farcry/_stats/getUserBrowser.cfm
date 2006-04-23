<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_stats/getUserBrowser.cfm,v 1.5 2003/12/31 00:14:23 paul Exp $
$Author: paul $
$Date: 2003/12/31 00:14:23 $
$Name: milestone_2-1-2 $
$Revision: 1.5 $

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
		{
			browsername = "Safari";
			browserVersion = "";// Not sure about how to disect the user_agent string for version just yet.
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
			if (Find("Mozilla",user_agent)) { 
				if (not Find("compatible",user_agent))
				{ 
					browserVersion=Val(RemoveChars(user_agent,1,Find("/",user_agent)));
					if (browserVersion lt 5) {
						//netscape browsers
						browserName="Netscape";	
					}
					else 
					{
						//mozilla browsers
						browserName="Mozilla";	
						browserVersion=Val(RemoveChars(user_agent,1,Find("rv:",user_agent)+2));
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