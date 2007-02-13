<cfparam name="action" default="">
<cfparam name="primaryObjectID" default="">
<cfparam name="lObjectID" default="">
<cfparam name="libraryType" default="">
<cfparam name="plpArrayPropertieName" default="aobjectids">
<cfparam name="bPLPStorage" default="yes">
<cfsetting showdebugoutput="false">
<cfif action NEQ "" AND lObjectID NEQ "" AND libraryType NEQ "">
	<!--- JSON encode and decode functions [jsonencode(str), jsondecode(str)]--->
	<cfinclude template="/farcry/core/admin/includes/json.cfm">
	<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
	<cfset objImage = CreateObject("component","#application.types.dmImage.typepath#")>
	<cfswitch expression="#action#">
		<cfcase value="delete,reposition"> <!--- manipulation of related item --->
			<cfif primaryObjectID NEQ "" AND libraryType NEQ "">

				<cfset objplp = CreateObject("component","#application.packagepath#.farcry.plpUtilities")>
			
				<cfswitch expression="#action#">
					<cfcase value="delete">
						<cfset objplp.fDeleteArrayObjects(primaryObjectID,lObjectID,plpArrayPropertieName,bPLPStorage)>
					</cfcase>
			
					<cfcase value="reposition">
						<cfset objplp.fRepositionArrayObjects(primaryObjectID,lObjectID,plpArrayPropertieName,bPLPStorage)>
					</cfcase>
					
					<cfdefaultcase>
					<!--- do nothing --->
					</cfdefaultcase>
				</cfswitch>

				<cfset returnstruct = objplp.fGetArrayObjects(primaryObjectID,plpArrayPropertieName,bPLPStorage)>
				<cfset arOptions = ArrayNew(1)>
				<cfset iCounter = 1>

				<cfif IsArray(returnstruct.output)>
					<cfset aObjects = returnstruct.output>
				<cfelse>
				<cfset aObjects = ListToArray(returnstruct.output)>
				</cfif>
				<cfloop index="i" from="1" to="#ArrayLen(aObjects)#">
					<q4:contentobjectget objectid="#aObjects[i]#" r_stobject="stItem">
					<cfif ListFindNoCase(libraryType,stItem.typename)>
						<cfset arOptions[iCounter] = StructNew()>
						<!--- replace potentially unsafe chars --->
						<cfset stItem.label = objplp.fReplaceBadCharacters(stItem.label)>
						<cfset arOptions[iCounter].text = stItem.label>
						<cfset arOptions[iCounter].objectID = stItem.objectID>
						<cfif libraryType EQ "dmImage">

							<cfset imageurl_default = objImage.getURLImagePath(stItem.objectID,"original")>
							<cfset imageurl_thumbnail = objImage.getURLImagePath(stItem.objectID,"thumb")>
							<cfset imageurl_highres = objImage.getURLImagePath(stItem.objectID,"optimised")>
	
							<!--- default thumbnail to original if it doesnt exist --->
							<cfif trim(imageurl_thumbnail) EQ "">
								<cfset imageurl_thumbnail = imageurl_default>
							</cfif>
							<!--- default highres to original if it doesnt exist --->						
							<cfif trim(imageurl_highres) EQ "">
								<cfset imageurl_highres = imageurl_default>
							</cfif>
							<!--- get the image insert html config item (returns to insertHTML javascript funvction) --->
							<cfset arOptions[iCounter].value = Application.config.image.insertHTML>
	
							<!--- replace thumbnail with thumbnail image url --->
							<cfset arOptions[iCounter].value = replaceNoCase(arOptions[iCounter].value,"*thumbnail*",imageurl_thumbnail,"all")>
	
							<!--- replace original with original image url --->
							<cfset arOptions[iCounter].value = replaceNoCase(arOptions[iCounter].value,"*imagefile*",imageurl_default,"all")>
																			
							<!--- replace high resolution with high resolution image url --->
							<cfset arOptions[iCounter].value = replaceNoCase(arOptions[iCounter].value,"*optimisedImage*",imageurl_highres,"all")>
	
							<!--- replace high resolution with high resolution image url --->
							<cfset arOptions[iCounter].value = replaceNoCase(arOptions[iCounter].value,"*alt*",stItem.alt,"all")>
							
							<!--- this is returned to the generateLibraryXML file and sent to a javasecript function .: have to escape javascript --->
							<cfset arOptions[iCounter].value = JSStringFormat("#stItem.objectID#|#arOptions[iCounter].value#")>

						<cfelseif libraryType EQ "dmFile">
							<cfset stItem.title = objplp.fReplaceBadCharacters(stItem.title)>
							<cfif application.config.general.fileDownloadDirectLink eq "false">
								<cfset arOptions[iCounter].value = JSStringFormat("#stItem.objectID#|<a href='#application.url.webroot#/download.cfm?DownloadFile=#stItem.objectid#' target='_blank'>#stItem.title#</a>")>
							<cfelse>
								<cfset arOptions[iCounter].value = JSStringFormat("#stItem.objectID#|<a href='#application.url.webroot#/files/#stItem.filename#' target='_blank'>#stItem.title#</a>")>
							</cfif>
						<cfelse>
							<cfset arOptions[iCounter].value = JSStringFormat("#stItem.objectID#")>
						</cfif>
						<cfset iCounter = iCounter + 1>
					</cfif>
				</cfloop>
			</cfif>
		</cfcase>

		<cfcase value="getItemByObjectID">
			<cfset arOptions = ArrayNew(1)>
			<cfset iCounter = 1>
			<cfloop index="currentObjectID" list="#lObjectID#">
				<q4:contentobjectget objectid="#currentObjectID#" r_stobject="stItem">
				<cfset arOptions[iCounter] = StructNew()>
				<cfset arOptions[iCounter].text = stItem.title>
				<cfif libraryType EQ "dmImage">
					<cfset imageurl_thumb = objImage.getURLImagePath(stItem.objectID,"thumb")>
					<cfset arOptions[iCounter].value = JSStringFormat("#imageurl_thumb#")>
				<cfelse>
<!--- diffrent types may want different values assigned --->
					<cfset arOptions[iCounter].value = stItem.title>
				</cfif>
				<cfset iCounter = iCounter + 1>
			</cfloop>
		</cfcase>
		
		<cfdefaultcase>
			<!--- do noting --->
		</cfdefaultcase>
	</cfswitch>

	<cfcontent type="text/plain"><cfoutput>
#jsonencode(arOptions)#</cfoutput>
</cfif>