<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Edit Content View --->
<!--- @@timeout: 0 --->


<!--- IMPORT TAG LIBRARIES --->
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/navajo" prefix="nj" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />


<!--- LOCK THE OBJECT --->
<cfset setLock(stObj=stObj,locked=true) />


<!--- PROCESS FORM --->
<ft:processForm action="Save" Exit="true">
	<cfset setLock(stObj=stObj,locked=false) />
	<ft:processFormObjects typename="#stobj.typename#" />
</ft:processForm>

<ft:processForm action="Cancel" Exit="true">
	<cfset setLock(stObj=stObj,locked=false) />
</ft:processForm>


<!--- EDIT OBJECT --->
<ft:form>
	<cfoutput><h1>#stobj.label#</h1></cfoutput>
	
	<ft:object objectid="#stObj.objectid#" lFields="title,teaser,teaserImage" legend="General Details" />
	
	<ft:object objectid="#stObj.objectid#" lFields="displayMethod" legend="Layout" />


	<!--- OPTION 1: TYPE WEBSKIN --->
	
	<cfif structKeyExists(stobj, "webskinTypename") AND structKeyExists(stobj, "webskin")>	
		<ft:object objectid="#stObj.objectid#" lFields="webskinTypename,webskin" legend="Content View" r_stFields="stFields" />

		<!--- viewTypename metadata --->	
		<cfparam name="application.stCoapi['dmInclude'].stProps.webskinTypename.metadata.ftJoin" default="#structkeylist(application.stcoapi)#" /><!--- These types are allowed to be used for type webskins --->
		<cfparam name="application.stCoapi['dmInclude'].stProps.webskinTypename.metadata.ftExcludeTypes" default="farFU" /><!--- Remove this types --->

		<cfset qTypes = querynew("typename,description","varchar,varchar") />
		<cfset thistype = "" />
		
		<cfset lTypes = "" /><!--- Used to make sure we dont get duplicates for all the prefixes --->
		
		<cfloop list="#application.stCoapi['dmInclude'].stProps.webskinTypename.metadata.ftJoin#" index="thistype">
			<cfif not listcontains(application.stCoapi['dmInclude'].stProps.webskinTypename.metadata.ftExcludeTypes,thistype)>
				<cfset qTypeWebskins = application.coapi.coapiAdmin.getWebskins(typename=thistype, packagepath=application.stCOAPI[thistype].packagepath, viewBinding="type", viewStack="body") />

				<cfif qTypeWebskins.recordCount and not listFindNoCase(lTypes, thistype)>
					<cfset lTypes = listAppend(lTypes, thistype) />
					
					<cfset queryaddrow(qTypes) />
					<cfset querysetcell(qTypes,"typename",thistype) />
					<cfif structkeyexists(application.stCOAPI[thistype],"displayname") and len(application.stCOAPI[thistype].displayname)>
						<cfset querysetcell(qTypes,"description",application.stCOAPI[thistype].displayname) />
					<cfelse>
						<cfset querysetcell(qTypes,"description",thistype) />
					</cfif>
				</cfif>
			</cfif>
		</cfloop>
		<cfquery dbtype="query" name="qTypes">
			select		*
			from		qTypes
			order by	description
		</cfquery>
		
		
		<cfif qTypes.recordcount>
			<skin:loadJS id="fc-jquery" />
			<skin:htmlHead id="typewebskinformtool">
				<cfoutput>
				<script type="text/javascript">
					function getDisplayMethod(typename,fieldname,property) {
						var webskinTypename = $j('###stFields.webskinTypename.FORMFIELDNAME#').val();
						var webskin = $j('###stFields.webskin.FORMFIELDNAME#').attr('value');
					
						$j.ajax({
						   type: "POST",
						   url: '#application.url.farcry#/facade/ftajax.cfm?formtool=string&typename='+typename+'&fieldname='+fieldname+'&property='+property,
						   data: { 
								typename: webskinTypename,
								value: webskin
							},
						   cache: false,
						   success: function(msg){
								$j('###stFields.webskin.FORMFIELDNAME#-wrap').html(msg);			     	
						   }
						 });
					};
				</script>
				</cfoutput>
			</skin:htmlHead>
		
	
			<cfoutput>	
			<ft:fieldset legend="Content Type View">
				<ft:field label="#stFields.webskinTypename.label#">
					
					
					<select name="#stFields.webskinTypename.FORMFIELDNAME#" id="#stFields.webskinTypename.FORMFIELDNAME#" class="selectInput" onchange="getDisplayMethod('dmInclude','#stFields.webskin.FORMFIELDNAME#','webskin')">
						<option value="">None selected</option>
						<cfloop query="qTypes">
							<option value="#qTypes.typename#"<cfif qTypes.typename eq listfirst(#stFields.webskinTypename.value#,'.')> selected="selected"</cfif>>#qTypes.description#</option>
						</cfloop>	
					</select>
					
				</ft:field>
				
				
				<ft:field label="#stFields.webskin.label#">
					
					<div id="#stFields.webskin.FORMFIELDNAME#-wrap">
						<small>Select a content type above</small>
						<input type="hidden" name="#stFields.webskin.FORMFIELDNAME#" id="#stFields.webskin.FORMFIELDNAME#" value="#stFields.webskin.value#" />
					</div>
					
				</ft:field>
			
			</ft:fieldset>
			</cfoutput>
					
			<skin:onReady>
				<cfoutput>getDisplayMethod('dmInclude','#stFields.webskin.FORMFIELDNAME#','webskin');</cfoutput>
			</skin:onReady>
			
	
		<cfelse>
	
			<cfoutput>
			<fieldset class="formSection">
				<legend class="">Content Type View (Not Available)</legend>
				<input type="hidden" name="#stFields.webskin.FORMFIELDNAME#webskin" id="#stFields.webskin.FORMFIELDNAME#webskin" value="" />
				<label>No Type Webskins Available</label>
			</fieldset>
			</cfoutput>
	
		</cfif>
	<cfelse>
		<cfoutput>
			<fieldset class="formSection">
				<legend class="">Content Type View (Not Available)</legend>	
				<p>This is option has not been deployed. Please contact your administrator.</p>
			</fieldset>
		</cfoutput>
	</cfif>	
	

	<cfset stPropMetadata = structnew() />
	<cfset stPropMetadata.include.ftLabel = "Include File" />
	<cfset stPropMetadata.include.ftHint = "Select the include file to display" />

	<ft:object stObject="#stObj#" lFields="include" legend="(Deprecated Option: Include File)" stPropMetadata="#stPropMetadata#" bShowLibraryLink="false" />


	<ft:object objectid="#stObj.objectid#" lFields="catInclude" legend="Categorisation" />

	
	<ft:buttonPanel>
		<ft:button value="Save" color="orange" /> 
		<ft:button value="Cancel" validate="false" />
	</ft:buttonPanel>
</ft:form>




<cfsetting enablecfoutputonly="false" />