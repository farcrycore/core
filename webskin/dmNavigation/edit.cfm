<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Edit --->
<!--- @@cacheStatus: -1 --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/navajo" prefix="nj" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/security" prefix="sec" />


<cfset setLock(stObj=stObj,locked=true) />


<ft:processForm action="Save,Manage">
	<cfset setLock(stObj=stObj,locked=false) />
	
	<!--- Initialise the new content ID --->
	<cfset newContentID = "" />
	
	<!--- If we already have children, then simply save. --->
	<cfif arraylen(stObj.aObjectIDs)>
		<ft:processFormObjects typename="#stobj.typename#" />
	<cfelse>
		<!--- Here we may have a new child. If we do then we want to redirect to the editing page of that child after saving. --->
		<ft:processFormObjects typename="#stobj.typename#">
			
			<cfif structkeyexists(stProperties,"aObjectIDs") and arraylen(stProperties.aObjectIDs)>
				<cfset newContentID = stProperties.aObjectIDs[1] />
			</cfif>
		</ft:processFormObjects>
	</cfif>
</ft:processForm>

<ft:processForm action="Save" bHideForms="true">
	<cfoutput>
		<script type="text/javascript">
			<cfif len(newContentID)>
				location.href = '#application.url.webtop#/edittabEdit.cfm?typename=#application.fapi.findType(newContentID)#&objectid=#newContentID#&ref=overview';
			<cfelse>
				location.href = '#application.url.webtop#/edittabOverview.cfm?typename=dmNavigation&objectid=#stObj.ObjectID#';
			</cfif>
		</script>
	</cfoutput>
</ft:processForm>

<ft:processForm action="Manage" bHideForms="true">
	<cfif structKeyExists(form, "selectedObjectID")>
		<cfoutput>
			<script type="text/javascript">
				location.href = '#application.url.webtop#/edittabOverview.cfm?typename=dmNavigation&objectid=#form.selectedObjectID#';
			</script>
		</cfoutput>		
	</cfif>
</ft:processForm>

<ft:processForm action="Cancel" bHideForms="true">
	<cfset setLock(stObj=stObj,locked=false) />
	<cfoutput>
		<script type="text/javascript">
			location.href = '#application.url.webtop#/edittabOverview.cfm?typename=dmNavigation&objectid=#stObj.ObjectID#';
		</script>
	</cfoutput>	
</ft:processForm>

<ft:form>

<skin:loadJS id="fc-jquery" />
<skin:loadCSS id="fc-fontawesome" />
<skin:onReady><script type="text/javascript"><cfoutput>
	$j("select[name$=navType]").bind("change",function(){
		var self = this;
		var cur = $j("div.navType:visible")[0].id.split("_")[1];
		if (cur !== self.value) {
			$j("div.navType_"+cur).fadeOut(function(){
				$j("div.navType_"+self.value).fadeIn();
			});
		}
	});
</cfoutput></script></skin:onReady>

<cfoutput>
	<h1>
		<cfif len(application.stCOAPI[stObj.typename].icon)>
			<i class="fa #application.stCOAPI[stObj.typename].icon#"></i>
		<cfelse>
			<i class="fa fa-file-o"></i>
		</cfif> 
		#stobj.label#
	</h1>
</cfoutput>

	
	<cfif stObj.navType eq "">
		<cfif len(stObj.externalLink)>
			<cfset stObj.navType = "externalLink" />
		<cfelse>
			<cfset stObj.navType = "aObjectIDs" />
		</cfif>
	</cfif>
	
	<ft:object stObject="#stObj#" lFields="title,navType" legend="General Details" />
	
	
	
	<cfoutput><div id="navType_aObjectIDs" class="navType navType_aObjectIDs"<cfif stObj.navType neq "aObjectIDs"> style="display:none;"</cfif>></cfoutput>
	<cfif not arrayLen(stobj.aObjectIds)>
		<ft:object stObject="#stObj#" lFields="aObjectIDs" bShowLibraryLink="false" />
	</cfif>
	<cfoutput></div></cfoutput>
	
	
	
	<cfoutput><div id="navType_internalRedirectID" class="navType navType_internalRedirectID"<cfif stObj.navType neq "internalRedirectID"> style="display:none;"</cfif>></cfoutput>
	<ft:object stObject="#stObj#" lFields="internalRedirectID" />
	<cfoutput></div></cfoutput>

	<cfoutput><div id="navType_externalRedirectURL" class="navType navType_externalRedirectURL"<cfif stObj.navType neq "externalRedirectURL"> style="display:none;"</cfif>></cfoutput>
	<ft:object stObject="#stObj#" lFields="externalRedirectURL" />
	<cfoutput></div></cfoutput>
	
	<cfoutput><div id="navType_ExternalLink" class="navType navType_ExternalLink"<cfif stObj.navType neq "ExternalLink"> style="display:none;"</cfif>></cfoutput>
	<ft:object stObject="#stObj#" lFields="ExternalLink" />
	<cfoutput></div></cfoutput>
	
	<sec:checkPermission permission="developer">
		<cfoutput><div class="navType navType_externalRedirectURL"<cfif not listcontainsnocase("externalRedirectURL",stObj.navType)> style="display:none;"</cfif>></cfoutput>
		<ft:object stObject="#stObj#" lFields="target" />
		<cfoutput></div></cfoutput>
	</sec:checkPermission>
	
	<!--- Now show any other fieldsets --->
	<cfset stLocal.qMetadata = application.types[stobj.typename].qMetadata />
	<cfquery dbtype="query" name="stLocal.qFieldSets">
		SELECT 		ftFieldset
		FROM 		stLocal.qMetadata
		WHERE 		lower(ftFieldset) not in ('','#stObj.typename#','general details','navigation behaviour')
		ORDER BY 	ftseq
	</cfquery>
	
	<cfoutput query="stLocal.qFieldSets" group="ftFieldset">
		<cfquery dbtype="query" name="stLocal.qFieldset">
			SELECT 		*
			FROM 		stLocal.qMetadata
			WHERE 		lower(ftFieldset) = '#lcase(stLocal.qFieldSets.ftFieldset)#'
			ORDER BY 	ftSeq
		</cfquery>
		
		<ft:object typename="#stobj.typename#" ObjectID="#stobj.objectID#" format="edit" lExcludeFields="label" lFields="#valuelist(stLocal.qFieldset.propertyname)#" inTable="false" IncludeFieldSet="true" Legend="#stLocal.qFieldSets.ftFieldset#" helptitle="#stLocal.qFieldSet.fthelptitle#" helpsection="#stLocal.qFieldSet.fthelpsection#" />
	</cfoutput>
	
	
	<ft:buttonPanel>
		<ft:button value="Save" color="orange" /> 
		<ft:button value="Cancel" validate="false" />
	</ft:buttonPanel>
</ft:form>

<cfsetting enablecfoutputonly="false" />