<cfsetting enablecfoutputonly="Yes">

<cfprocessingDirective pageencoding="utf-8">

<cfimport taglib="/farcry/core/tags/misc/" prefix="misc">

<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html dir="#session.writingDir#" lang="#session.userLanguage#">
<head>
	<title>adminMenuFrame</title>
	<misc:cacheControl>
	<LINK href="../css/overviewFrame.css" rel="stylesheet" type="text/css">
	<meta content="text/html; charset=UTF-8" http-equiv="content-type">
</head>

<body>
<cfparam name="url.parenttabindex" default="1">
<cfparam name="url.subtabindex" default="1">


<div id="frameMenu">
		<cfset menuElements = application.customAdminXML.customtabs.parenttab[URL.parenttabindex].subtabs[URL.subtabindex].xmlchildren>
		<cfloop from="1" to="#ArrayLen(menuElements)#" index="i">
			<cfswitch expression="#MenuElements[i].xmlname#">
				<cfcase value="menutitle">
					<cfscript>
						//if there is a permission, then check it exists
						if(structKeyExists(menuElements[i].xmlAttributes,"permission"))
						{
							//might want to add 'reference' to xml schema later as well
							bHasPerm = request.dmSec.oAuthorisation.checkPermission(permissionname=menuElements[i].xmlAttributes.permission,reference='policyGroup');
						}
						else
							bHasPerm = 1; //For the sake of backwards compatability, will assume that if no permission set - then everyone can see this menuitem
					</cfscript>
					<!--- If they have permission then render the menu title --->
					<cfif bHasPerm>
						<div class="frameMenuTitle">#MenuElements[i].xmltext#</div>
					</cfif>
				</cfcase>
				<cfcase value="menuitem">
					<cfset label = xmlSearch(MenuElements[i],"label")>
					<cfset link = xmlSearch(MenuElements[i],"link")>
					<cfparam name="link[1].xmlAttributes.bAppendApproval" default="1">
					<cfscript>
						//if there is a permission, then check it exists
						if(structKeyExists(menuElements[i].xmlAttributes,"permission"))
						{
							//might want to add 'reference' to xml schema later as well
							bHasPerm = request.dmSec.oAuthorisation.checkPermission(permissionname=menuElements[i].xmlAttributes.permission,reference='policyGroup');
						}
						else
							bHasPerm = 1; //For the sake of backwards compatability, will assume that if no permission set - then everyone can see this menuitem
						href = link[1].xmltext;
						bAppend = link[1].xmlAttributes.bAppendApproval;
						parentURL = application.config.general.adminServer;
						parentURL = parentURL & "#application.url.farcry#/index.cfm?section=customAdmin&parenttabindex=#url.parentTabIndex#&subtabindex=#url.subtabindex#&defaultPage=#link[1].xmltext#";
						append = '';
						//perhaps some users will want to overide this default behavior of appendin an approve URL - check for bAppendApproval
						if(bAppend)
						{
							if(findnocase(".cfm?",href))
								append = "&";
							else
								append = "?";
							href = href & append & "approveURL=#URLEncodedFormat(parentURL)#";
						}	
					</cfscript>
					<cfif bHasPerm GT 0>
					<div class="frameMenuItem">
					<span class="frameMenuBullet">&raquo;</span>
  						<a href="#href#" class="frameMenuItem" target="editFrame">#label[1].xmltext#</a>	
					</div>			
					</cfif>		 
				</cfcase>
			</cfswitch>
		</cfloop>
</div>

</body>
</html>
</cfoutput>
<cfsetting enablecfoutputonly="No">