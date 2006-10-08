<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2006, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: $
$Author: $
$Date: $
$Name: $
$Revision: $

|| DESCRIPTION || 
$Description: Webtop component. $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au)$
--->
<cfcomponent>
<!--- TODO: remove REQUEST scope security reference --->

<cffunction name="init" access="public" output="false" returntype="any" hint="Initialise component with XML configs from core and custom admin.">
	<cfargument type="string" required="false" name="xWebtop" default="" hint="Webtop XML config file as a string.">
	<cfargument type="string" required="false" name="xCustomAdmin" default="" hint="Custom Admin XML config file as a string.">
	<cfset var xmlWebtop="">
	<cfset var xmlCustomAdmin="">
	<cfset var aXMLCustomAdmin= arrayNew(1) />
	<cfset var xmlpathfull="" />
	
	<cfif NOT len(arguments.xWebtop)>
		<cffile action="read" file="#application.path.core#/config/webtop.xml" variable="arguments.xWebtop">
	</cfif>
<!---	<cfif NOT len(arguments.xCustomAdmin) AND fileexists("#application.path.project#/customadmin/customadmin.xml")>
		<cffile action="read" file="#application.path.project#/customadmin/customadmin.xml" variable="arguments.xCustomAdmin">
	</cfif> --->

	<!--- parse XML and validate config files --->
	<cfset xmlWebTop=xmlParse(arguments.xWebtop)>


	<!--- If we have passed a custom admin in through arguments, add it as the first item in the custom admin XML array --->
	<cfif len(arguments.xCustomAdmin)>
		<cfset bResult = arrayAppend(aXMLCustomAdmin, xmlParse(arguments.xCustomAdmin)) />
	</cfif>
	
	<!--- If any custom admin xml files exist, we need to add them to our custom admin XML array --->
	<cfdirectory action="list" directory="#application.path.project#/customadmin" filter="*.xml" name="qCustomAdmin" />
	

	<cfif qCustomAdmin.RecordCount>
		
		<cfloop query="qCustomAdmin">
			<cffile action="read" file="#application.path.project#/customadmin/#qCustomAdmin.Name#" variable="arguments.xCustomAdmin">
			
			<cftry>
				<!--- validate custom admin xml --->
				<cfset xmlCustomAdmin=xmlParse(arguments.xCustomAdmin)>
				<cfif arraylen(xmlsearch(xmlCustomAdmin, "/customtabs"))>
					<!--- process old-style custom admin --->
					<cffile action="read" file="#application.path.core#/config/transform.xsl" variable="xslt">
					<!--- XSLT transform customadmin --->
					<cfset xmlCustomAdmin=xmlTransform(xmlCustomAdmin,xslt)>
					<cfset xmlCustomAdmin=xmlParse(xmlCustomAdmin)>
					<!--- log deprecated approach --->
					<cftrace type="warning" category="farcry.webtop" text="../customadmin/customadmin.xml is using an old format.  This was updated to a more modern format with the release of FarCry 2.4." />
					<cflog application="true" file="deprecated" type="warning" text="../customadmin/customadmin.xml initialised using an old xml format.  This was updated to a more modern format with the release of FarCry 2.4." />
				</cfif>
				
				<!--- add the xml to our array --->
				<cfset bResult = arrayAppend(aXMLCustomAdmin, xmlCustomAdmin) />
				
				<cfcatch>
					<cftrace type="warning" category="farcry.webtop" text="../customadmin/customadmin.xml was not parsed successfully." var="cfcatch.Detail" />
				</cfcatch>
			</cftry>
			
		</cfloop>
	</cfif>
		
		
	<cfif structKeyExists(application, "lFarcryLib") and listLen(application.lFarcryLib)>

		<cfloop list="#application.lFarcryLib#" index="library">
			
			<cfif directoryExists("#application.path.library#/#library#/customadmin")>
				<cfdirectory action="list" directory="#application.path.library#/#library#/customadmin" filter="*.xml" name="qCustomAdmin" />
	

				<cfif qCustomAdmin.RecordCount>
					
					<cfloop query="qCustomAdmin">
						<cfset xmlpathfull="#application.path.library#/#library#/customadmin/#qCustomAdmin.Name#" />
						<cffile action="read" file="#application.path.library#/#library#/customadmin/#qCustomAdmin.Name#" variable="arguments.xCustomAdmin">
						
						<cftry>
							<!--- validate custom admin xml --->
							<cfset xmlCustomAdmin=xmlParse(arguments.xCustomAdmin)>
							<cfif arraylen(xmlsearch(xmlCustomAdmin, "/customtabs"))>
								<!--- process old-style custom admin --->
								<cffile action="read" file="#application.path.core#/config/transform.xsl" variable="xslt">
								<!--- XSLT transform customadmin --->
								<cfset xmlCustomAdmin=xmlTransform(xmlCustomAdmin,xslt)>
								<cfset xmlCustomAdmin=xmlParse(xmlCustomAdmin)>
								<!--- log deprecated approach --->
								<cftrace type="warning" category="farcry.webtop" text="#xmlpathfull# is using an old format.  This was updated to a more modern format with the release of FarCry 2.4." />
								<cflog application="true" file="deprecated" type="warning" text="#xmlpathfull# initialised using an old xml format.  This was updated to a more modern format with the release of FarCry 2.4." />
							</cfif>
							
							<!--- add the xml to our array --->
							<cfset bResult = arrayAppend(aXMLCustomAdmin, xmlCustomAdmin) />
							
							<cfcatch>
								<cftrace type="warning" category="farcry.webtop" text="#xmlpathfull# was not parsed successfully." var="cfcatch.Detail" />
							</cfcatch>
						</cftry>
						
					</cfloop>
				</cfif>
			</cfif>
		</cfloop>
		
	</cfif>
			
	<cfif arrayLen(aXMLCustomAdmin)>
		
			
		<cfinvoke component="WebtopRoot" method="init" returnVariable="webtopRoot"> 
  			<cfinvokeargument name="WebtopXmlDoc" value="#xmlWebtop#"> 
		</cfinvoke> 
		
		
		<cfloop from="1" to="#arrayLen(aXMLCustomAdmin)#" index="i">

						
			<cfinvoke component="WebtopRoot" method="init" returnVariable="webtopCustom"> 
				<cfinvokeargument name="WebtopXmlDoc" value="#aXMLCustomAdmin[i]#"> 
			</cfinvoke> 
			
			
			
			<cfset webtopRoot.mergeRoot(webtopCustom)>  	
			
		</cfloop>
		
		
		<cfset xmlWebtop = webtopRoot.getXmlDoc()>
		
			
	</cfif>
	<cfset this.xmlwebtop=xmlWebtop>


<!---
	<!--- parse XML and validate config files --->
	<cfset xmlWebTop=xmlParse(arguments.xWebtop)>
	<cfif len(arguments.xcustomadmin)>
		
		<!--- validate custom admin xml --->
			<cfset xmlCustomAdmin=xmlParse(arguments.xCustomAdmin)>
			<cfif arraylen(xmlsearch(xmlCustomAdmin, "/customtabs"))>
				<!--- process old-style custom admin --->
				<cffile action="read" file="#application.path.core#/config/transform.xsl" variable="xslt">
				<!--- XSLT transform customadmin --->
				<cfset xmlCustomAdmin=xmlTransform(xmlCustomAdmin,xslt)>
				<cfset xmlCustomAdmin=xmlParse(xmlCustomAdmin)>
				<!--- log deprecated approach --->
				<cftrace type="warning" category="farcry.webtop" text="../customadmin/customadmin.xml is using an old format.  This was updated to a more modern format with the release of FarCry 2.4." />
				<cflog application="true" file="deprecated" type="warning" text="../customadmin/customadmin.xml initialised using an old xml format.  This was updated to a more modern format with the release of FarCry 2.4." />
			</cfif>

	</cfif>
	
	<!--- merge xml documents--->
	<cfif len(xmlCustomAdmin)>
		<cfinvoke component="WebtopRoot" method="init" returnVariable="webtopRoot1"> 
  			<cfinvokeargument name="WebtopXmlDoc" value="#xmlWebtop#"> 
		</cfinvoke> 

		<cfinvoke component="WebtopRoot" method="init" returnVariable="webtopRoot2"> 
			<cfinvokeargument name="WebtopXmlDoc" value="#xmlCustomAdmin#"> 
		</cfinvoke> 

		<cfset webtopRoot1.mergeRoot(webtopRoot2)> 
		<cfset xmlWebtop = webtopRoot1.getXmlDoc()> 		
	</cfif> 
	
	<cfset this.xmlwebtop=xmlWebtop>
	 --->
	
	<cfreturn this>
</cffunction>

<cffunction name="getsubsectionasarray" access="public" output="false" returntype="array" hint="Return a single index array of the subsection detail.">
	<cfargument name="section" required="false" default="">
	<cfargument name="subsection" required="false" default="">
	<cfset var aSubectionToDisplay=arraynew(1)>
	
	<!--- get subsection directly, if no section (might get multiples if subsection ids not unique) --->
	<cfif NOT len(arguments.section) AND len(arguments.subsection)>
		<cfset aSubectionToDisplay=xmlSearch(this.xmlWebTop,"//subsection[@id='#arguments.subsection#']")>
		<cfdump var="#aSubectionToDisplay#">
		<cfabort>
	</cfif>
	
	<!--- get subsection by exact match --->
	<cfif len(arguments.section) AND len(arguments.subsection)>
		<cfset aSubectionToDisplay=xmlSearch(this.xmlWebTop,"//section[@id='#arguments.section#']/subsection[@id='#arguments.subsection#']")>
	</cfif>
	
	<!--- if subsection can't be determined default to first subsection --->
	<cfif arrayisempty(aSubectionToDisplay) AND len(arguments.section)>
		<cfset aSubectionToDisplay=xmlSearch(this.xmlWebTop,"//section[@id='#arguments.section#']/subsection[1]")>
	</cfif>

	<!--- if all else fails try first section & subsection --->
	<cfif arrayisempty(aSubectionToDisplay)>
		<cfset aSubectionToDisplay=xmlSearch(this.xmlWebTop,"//section[1]/subsection[1]")>
	</cfif>
	
	<cfreturn aSubectionToDisplay>
</cffunction>

<cffunction name="getSectionsAsArray" access="public" output="false" returntype="array" hint="Return an array of webtop sections, filtered by user permission set.">
	<!--- determine available section tabs --->
	<cfset var aSections=this.xmlWebtop.webtop.XMLChildren>
	<cfset var lsections="">
	<cfset var i=0>
	
	<cfloop from="1" to="#arraylen(aSections)#" index="i">
	<cfscript>
		//if there is a permission, then check it exists
		if(structKeyExists(aSections[i].xmlAttributes,"permission")) {
			if (NOT request.dmSec.oAuthorisation.checkPermission(permissionname=aSections[i].xmlAttributes.permission,reference='policyGroup'))
				// remove section if permission not available
				lSections="#i#,#lsections#";
		} 
	</cfscript>
	</cfloop>
	<!--- reverse loop to make sure we can delete relevant array position --->
	<cfloop list="#lSections#" index="i">
		<cfset arrayDeleteAt(aSections,i)>
	</cfloop>
	<cfreturn aSections>
</cffunction>

<cffunction name="getSubSectionsAsArray" access="public" output="true" returntype="array" hint="Return an array of webtop sub-sections, filtered by user permission set.">
	<cfargument name="section" required="false" type="string" default="">
	<cfargument name="subsection" required="false" type="string" default="">
	<!--- determine available section tabs --->
	<cfset var aSubSections=arraynew(1)>
	<cfset var lsubsections="">
	<cfset var i=0>
	
	<cfif len(arguments.section)>
		<!--- determine by section --->
		<cfset aSubSections=xmlSearch(this.xmlWebTop,"//section[@id='#arguments.section#']/subsection")>
	<cfelse>
		<!--- determine by subsection, getting preceding siblings, self and following siblings --->
		<cfset aSubSections=xmlSearch(this.xmlWebTop,"//subsection[@id='#arguments.subsection#']/preceding-sibling::*|//subsection[@id='#arguments.subsection#']|//subsection[@id='#arguments.subsection#']/following-sibling::*")>
	</cfif>
	
	<cfloop from="1" to="#arraylen(aSubSections)#" index="i">
	<cfscript>
		//if there is a permission, then check it exists
		if(structKeyExists(aSubSections[i].xmlAttributes,"permission")) {
			if (NOT request.dmSec.oAuthorisation.checkPermission(permissionname=aSubSections[i].xmlAttributes.permission,reference='policyGroup'))
				// remove section if permission not available
				lSubSections="#i#,#lSubsections#";
		} 
	</cfscript>
	</cfloop>
	<!--- reverse loop to make sure we can delete relevant array position --->
	<cfloop list="#lSubSections#" index="i">
		<cfset arrayDeleteAt(aSubSections,i)>
	</cfloop>
	<cfreturn aSubSections>
</cffunction>
<cffunction name="fTranslateXMLElement" hint="Translate the XmlText based on whether the to evaluate XmlAttributes.label (XmlAttributes.labelEvaluate = True)">
	<cfargument name="xmlElement" required="true" type="any">

	<!--- local variables --->
	<cfset var xElement = arguments.xmlElement>
	<cfset var stLocal = StructNew()>
	<!--- translate the xmlattributes --->

	<cfif StructKeyExists(xElement.xmlAttributes,"labelType")>
		<cftry>						
			<cfswitch expression="#xElement.xmlAttributes.labelType#">
				<cfcase value="evaluate">
					<!--- evaluate --->
					<cfset xElement.xmlAttributes.label = Evaluate(xElement.xmlAttributes.label)>
				</cfcase>
	
				<cfcase value="expression">
					<!--- expressions --->			
					<cfset xElement.xmlAttributes.label = Evaluate(xElement.xmlAttributes.label)>
				</cfcase>

				<cfcase value="text">
					<!--- text --->			
					<cfset xElement.xmlAttributes.label = xElement.xmlAttributes.label>
				</cfcase>
								
				<cfdefaultcase>

				</cfdefaultcase>
			</cfswitch>
			
			<cfcatch type="any">
				<cfset xElement.xmlAttributes.label = "<font color='red'>#xElement.xmlAttributes.label#</font>">
			</cfcatch>
		</cftry>
	<cfelse>
		<cfif NOT StructKeyExists(xElement.xmlAttributes,"label")>
			<cfif StructKeyExists(xElement,"xmlText")>
				<cfset xElement.xmlAttributes.label = xElement.xmlText>
			<cfelse>
				<cfset xElement.xmlAttributes.label = "[Add Label]">
			</cfif>
		</cfif>
	</cfif>

	<cfloop index="stLocal.i" from="1" to="#ArrayLen(xElement.xmlChildren)#">
		<cfset fTranslateXMLElement(xElement.xmlChildren[stLocal.i])>
	</cfloop>
</cffunction>

<!--- this function is specifically written for /farcry_core/admin/index.cfm
      ~line 56.
      Call like: sidebar=oWebTop.getSidebarUrl(aSubsectionToDisplay[1].xmlattributes) 
      author: Tyler Ham (tylerh@austin.utexas.edu) 
      date: 2005-10-05 --->
<cffunction name="getSidebarUrl" access="public" output="false" returntype="string" hint="takes a struct of the xmlattributes of a subsection, returns the string of a url to use for the sidebar.">
	<cfargument name="stXmlAttributes" type="Struct" required="true">
	<cfset var sReturn = "custom/sidebar.cfm">  <!--- this seems like a good default url --->
	<cfset var urlUtil = "">
	<cfset var stParams = StructNew()>

	<cfobject component="UrlUtility" name="urlUtil">
	
	<!--- if the 'sidebar' attribute exists, make it the base url --->
	<cfif StructKeyExists(arguments.stXmlAttributes, "sidebar")>
		<cfset sReturn = arguments.stXmlAttributes.sidebar>
	</cfif>
	
	<!--- add anything in our query_string to the url params --->
	<!--- getUrlParamStruct looks for the '?' --->
	<cfset stParams = urlUtil.getURLParamStruct("?" & CGI.QUERY_STRING)>
	
	<!--- if 'id' attribute exists, REPLACE any 'sub' url param with this value --->
	<cfif StructKeyExists(arguments.stXmlAttributes, "id")>
		<cfset stParams.sub = arguments.stXmlAttributes.id>
	</cfif>
	
	<!--- generate the sidebar url by appending the params we've accumulated --->
	<cfset sReturn = urlUtil.appendURLParams(address=sReturn, paramStruct=stParams, replaceExisting=false)>
	
	<cfreturn sReturn>
</cffunction>

<!--- this function is specifically written for /farcry_core/admin/index.cfm
      ~line 57
      Call like: content=oWebTop.getContentUrl(aSubsectionToDisplay[1].xmlattributes)
      author: Tyler Ham (tylerh@austin.utexas.edu)
      date: 2005-10-05 --->
<cffunction name="getContentUrl" access="public" output="false" returntype="string" hint="takes a struct of the xmlattributes of a subsection, returns the string of a url to use for the content pane.">
	<cfargument name="stXmlAttributes" type="Struct" required="true">
	
	<cfset var sReturn = "inc/content.html"> <!--- this seems like a good default url --->
	<cfset var urlUtil = "">
	<cfset var stParams = StructNew()>
	
	<cfobject component="UrlUtility" name="urlUtil">
	
	<!--- if the 'content' attribute exists, make it the base url --->
	<cfif StructKeyExists(arguments.stXmlAttributes, "content")>
		<cfset sReturn = arguments.stXmlAttributes.content>
	</cfif>
	
	<!--- add anything in our query_string to the url params --->
	<!--- getUrlParamStruct looks for the '?' --->
	<cfset stParams = urlUtil.getUrlParamStruct("?" & CGI.QUERY_STRING)>
	
	<!--- generate the sidebar url by appending the params we've accumulated --->
	<cfset sReturn = urlUtil.appendURLParams(address=sReturn, paramStruct=stParams, replaceExisting=false)>
	
	<cfreturn sReturn>
</cffunction>

<cfscript>
/**
 * Merges one xml document into another
 * 
 * @param xml1 	 The XML object into which you want to merge (Required)
 * @param xml2 	 The XML object from which you want to merge (Required)
 * @param overwriteNodes 	 Boolean value for whether you want to overwrite (default is true) (Optional)
 * @return void (changes the first XML object) 
 * @author Nathan Dintenfass (nathan@changemedia.com) 
 * @version 1, November 2, 2003 
 */
function xmlMerge(xml1,xml2){
	var readNodeParent = arguments.xml2;
	var writeNodeList = arguments.xml1;
	var writeNodeDoc = arguments.xml1;
	var readNodeList = "";
	var writeNode = "";
	var readNode = "";
	var nodeName = "";
	var ii = 0;
	var writeNodeOffset = 0;
	var toAppend = 0;
	var nodesDone = structNew();
	//by default, overwrite nodes
	var overwriteNodes = true;
	//if there's a 3rd arguments, that's the overWriteNodes flag
	if(structCount(arguments) GT 2)
		overwriteNodes = arguments[3];
	//if there's a 4th argument, it's the DOC of the writeNode -- not a user provided argument -- just used when doing recursion, so we know the original XMLDoc object
	if(structCount(arguments) GT 3)
		writeNodeDoc = arguments[4];
	//if we are looking at the whole document, get the root element
	if(isXMLDoc(arguments.xml2))
		readNodeParent = arguments.xml2.xmlRoot;
	//if we are looking at the whole Doc for the first element, get the root element
	if(isXMLDoc(arguments.xml1))
		writeNodeList = arguments.xml1.xmlRoot;	
	//loop through the readNodeParent (recursively) and override all xmlAttributes/xmlText in the first document with those of elements that match in the second document
	for(nodeName in readNodeParent){
		writeNodeOffset = 0;
		//if we haven't yet dealt with nodes of this name, do it
		if(NOT structKeyExists(nodesDone,nodeName)){
			readNodeList = readNodeParent[nodeName];
			//if there aren't any of this node, we need to append however many there are
			if(NOT structKeyExists(writeNodeList,nodeName)){
				toAppend = arrayLen(readNodeList);
			}
			//if there are already at least one node of this name
			else{
				//if we are overwriting nodes, we need to append however many there are minus however many there were (if there none new, it will be 0)
				if(overWriteNodes){
					toAppend = arrayLen(readNodeList) - arrayLen(writeNodeList[nodeName]);
				}
				//if we are not overwriting, we need to add however many there are
				else{
					toAppend = arrayLen(readNodeList);
					//if we are not overwriting, we need to make the offset of the writeNode equal to however many there already are
					writeNodeOffset = arrayLen(writeNodeList[nodeName]);
				}
			}
			//append however many nodes necessary of the name
			for(ii = 1;  ii LTE toAppend; ii = ii + 1){
				arrayAppend(writeNodeList.xmlChildren,xmlElemNew(writeNodeDoc,nodeName));
			}
			//loop through however many of this nodeName there are, writing them to the writeNodes
			for(ii = 1; ii LTE arrayLen(readNodeList); ii = ii + 1){
				writeNode = writeNodeList[nodeName][ii + writeNodeOffset];
				readNode = readNodeList[ii];
				//set the xmlAttributes and xmlText to this child's values
				writeNode.xmlAttributes = readNode.xmlAttributes;
				writeNode.xmlText = readNode.xmlText;
				//if this element has any children, recurse
				if(arrayLen(readNode.xmlChildren)){
					xmlMerge(writeNode,readNode,overwriteNodes,writeNodeDoc);
				}
			}
			//add this node name to those nodes we have done -- we need to do this because an XMLDoc object can have duplicate keys
			nodesDone[nodeName] = true;
		}
	}
}
</cfscript>

</cfcomponent>

