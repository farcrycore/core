<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/rss.cfc,v 1.1 2003/07/24 06:04:37 geoff Exp $
$Author: geoff $
$Date: 2003/07/24 06:04:37 $
$Name: b201 $
$Revision: 1.1 $

|| DESCRIPTION || 
$Description: RSS Utilities based on work done in the infamous Fullasagoog.com $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->
<cfcomponent displayname="RSS" hint="Provides utilities for working with RSS XML feeds.">

	<cffunction name="getVersion" access="public" returntype="struct" hint="Return the RSS version for the XML feed.  Results can be either 0.91, 0.92, 1.0, 2.0 or unknown." output="false">
		<cfargument name="xml" type="string" required="true">
		<cfset var stResult=structNew()>
		<cfset var myXML="">
		
		<cfscript>
		// check to see if the feed is valid XML
		// TODO: add namespace URL to version result structure
		// TODO: work out the standard for RSS version labels
		try {
			myXML = xmlParse(arguments.xml);
			// test for Rss2.0
			if (isDefined("myXml.rss.xmlattributes.version")) {
				stResult.Version = myXml.rss.xmlattributes.version;
			// test for RSS1.0 ie. RDF
			} else if (isDefined("myXML.xmlroot.xmlname") AND myXML.xmlroot.xmlname CONTAINS "rdf:RDF") {
				stResult.Version = "1.0";
			} else {
				stResult.Version = "unknown";
			}
			stResult.bSuccess = true;
		}
		catch(Any error) {
			stResult.bSuccess = false;
			stResult.status = error;
		}
		</cfscript>
		<cfreturn stResult>
	</cffunction>

	<cffunction name="getChannelAttribs" access="public" returntype="struct" output="false">
		<cfargument name="xml" type="string" required="true">
		
		<cfset var stResult=structNew()>
		<cfset var myXML="">
		<cfset var channel = structNew()>
		<cfset var aAttributes = arrayNew(1)>
		
		<!--- // TODO: map all versions to a common set of keys, perhaps RSS20 keys?? --->
		<cfset myXML=xmlParse(arguments.xml)>
		<cfset aAttributes = myxml.xmlroot.xmlchildren[1].xmlchildren> <!--- //channel node --->
		
		
		<cfloop from="1" to="#arrayLen(aAttributes)#" index="i">
			<cfif len(aAttributes[i].xmlText)>
				<cfset setVariable("channel['#aAttributes[i].xmlName#']", aAttributes[i].xmlText)>
			</cfif>
		</cfloop>
		<cfset stResult.bSuccess="true">
		<cfset stResult.channel=channel>
		<cfreturn stResult>
	</cffunction>

	<cffunction name="getItemsAsArray" access="public" returntype="array" output="false">
		<cfargument name="xml" type="string" required="true">
		<cfargument name="version" type="string" required="false">
		<cfargument name="stripHTML" type="boolean" required="false" default="true">
		<cfargument name="truncate" type="boolean" required="false" default="true">
		
		<cfset var aResults = arrayNew(1)>
		<cfset var aItems = arrayNew(1)>
		<cfset var stItem = structNew()>
		<cfset var myXML = "">
		<cfset var i = "">
		
		<!--- parse unwanted doctypes from raw feed --->
		<cfset arguments.xml = replaceNoCase(arguments.xml, '<!DOCTYPE rss .*>', "")>
		<cfset myXML = xmlParse(arguments.xml)>
		
		<!--- if version not defined -> getVersion() --->
		<cfif NOT isDefined("arguments.version")>
			<cfset arguments.version = this.getVersion(arguments.xml)>
			<cfset arguments.version = arguments.version.version>
		</cfif>
		
		<!--- extract items from feed --->
		<cfscript>
		if (arguments.version neq "1.0") {
			// use XPATH search for RSS0.91/0.92/2.0
			aResults = XMLSearch(myxml, "//item");
		} else {
			// RSS1.0 (RDF)
			// XPATH //item search doesn't work on RDF, use XMLDOM instead 
			aResults = myXML['rdf:RDF'].XMLChildren;
		}
	    for (i=1; i LTE ArrayLen(aResults); i=i+1) {
			// only process ITEM nodes
    		if (aResults[i].XmlName eq "item") {
				stItem = structNew();
				// loop over child nodes of ITEM and build a struct
			    for (j=1; j LTE ArrayLen(aResults[i].XMLChildren); j=j+1) {
					if (arguments.stripHTML) {
						setVariable("stItem['#aResults[i].xmlChildren[j].xmlname#']", REReplaceNoCase(aResults[i].xmlChildren[j].xmltext, "<[^>]*>", "", "all"));
					} else {
						setVariable("stItem['#aResults[i].xmlChildren[j].xmlname#']", aResults[i].xmlChildren[j].xmltext);
					}
				}
				// parse date to something intelligible
				if (structkeyExists(stItem, "dc:date")) {
					stItem['dc:date'] = this.parseRSSDate(stItem['dc:date']);
				} else {
					// if no date exists add an empty key, using RSS2.0 standard
					stItem['dc:date']="";
				}
				// make sure the description field has been populated
				if (structkeyExists(stItem, "description")) {
					// truncate very long descriptions/excerpts to 500char
					if (structkeyExists(stItem, "description") AND arguments.truncate)
						stItem['description'] = left(stItem['description'], 500);
				} else {
					// if no description exists add an empty key, using RSS2.0 standard
					stItem['description']="";
				}

				arrayAppend(aItems, stItem);
			}
		}
		</cfscript>

		<cfreturn aItems>
	</cffunction>

	<cffunction name="parseRSSDate" access="public" returntype="string" output="false" hint="Syndicated feeds use a variety of date formats.  This function helps to decipher the date from the most common formats. Unknown dates are returned as empty strings.  Parsed date times are returned in ODBC format.">
		<cfargument name="dts" type="string" required="true" hint="Date time stamp.">
		
		<cfset var itemdts="">
		<cfset var itemdate="">
		<cfset var itemtime="">
		
		<cfscript>
		if (isDate(arguments.dts)) {
			itemdts = parseDateTime(dts);
			itemdts = createODBCDateTime(itemdts);
		} else if (len(dts) eq 25) {
		// typical MoveableType dateformat eg. "2003-02-03T00:39:59+10:00"
			itemdate = left(dts, 10);
			itemtime = left(listlast(dts, "T"), 8);
			itemdts = CreateDateTime(year(itemdate), month(itemdate), day(itemdate), hour(itemtime), minute(itemtime), second(itemtime));
      /*
       * BEGIN: Added by Spike 6pm Thursday 22 May 2003.
       * Turn localized timestamps into international timestamps
       */
      if (reFind('[+-][0-9]{2}:[0-9]{2}$',dts)) {
        offset = reReplaceNoCase(dts,'(.*)([+-][0-9]{2})(:[0-9]{2})$','\2','all');
        itemdts = dateAdd('h',offset*-1,itemdts);
      }
      /*
       * END: Added by Spike 6pm Thursday 22 May 2003.
       */
			itemdts = createODBCDateTime(itemdts);
		} else {
			// unknown date format
			itemdts="";
		}
		</cfscript>

		<cfreturn itemdts>
	</cffunction>

	<cffunction name="HTMLStripper" hint="Strips HTML from a string">
	<cfargument name="string" type="string" hint="The String to be stripped" required="true">
	<cfscript>
		modsummary = REReplaceNoCase(string, "<[^>]*>", "", "all");
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
	</cfscript>
	<cfreturn modSummary>
	</cffunction>
</cfcomponent>