<cfsetting enablecfoutputonly="true" />
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2006, http://www.daemon.com.au $
$Community: FarCry CMS http://www.farcrycms.org $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: $
$Author: $
$Date: $
$Name: $
$Revision: $

|| DESCRIPTION || 
$Description: Verity Configurator Prototype; will have to tie us over till config engine is rebuilt. $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au)$
--->
<!--- import tag libraries --->
<cfimport prefix="admin" taglib="/farcry/core/tags/admin/" />

<!--- get current verity config --->
<cfset stconfig=application.config.verity />

<!--- type collection exclusion list --->
<cfset lexcludedTypes="dmCSS, dmCron, dmArchive, dmRedirect, dmEmail, dmXMLExport, dmNavigation, dmProfile, dmFacts" />
<cfset lexcludedPropTypes="UUID, array, boolean, numeric">
<cfset lexcludedProps="locked, lockedby, displayMethod, status, ownedby, createdby, lastupdatedby, commentlog">

<!-------------------------------------
ACTION:
 - Update Collection Settings
 - Passthrough to overview
-------------------------------------->
<cfif structkeyexists(form, "updateCollection")>

	<!--- wipe slate of current settings --->
	<cfset contenttype=structNew() />
	<cfset contenttype.aprops=arrayNew(1) />
	<!--- apply updated settings --->
	<cfloop collection="#form#" item="field">
		<cfif NOT listContainsNoCase("FIELDNAMES, builttodate, UPDATECOLLECTION, CUSTOM3, CUSTOM4, TYPENAME, FILECOLLECTIONPROPERTY",field)>
			<cfset arrayAppend(contenttype.aprops, field) />
		</cfif>
	</cfloop>
	<cfset contenttype.builttodate=form.builttodate />
	<cfset contenttype.custom3=form.custom3 />
	<cfset contenttype.custom4=form.custom4 />
	<cfset contenttype.FileCollectionProperty=form.FileCollectionProperty />
	<cfset contenttype.lcategories=false /> <!--- not yet implemented --->

	<!--- instantiate verity component --->
	<cfset oVerity=createObject("component", application.packagepath & ".farcry.verity") />
	
	<!--- if no properties to index then remove type from config --->
	<cfif NOT arraylen(stConfig.contenttype[form.typename].aprops)>
		<cfset oVerity.deleteContenttype(form.typename) />	
	</cfif>

	<!--- write the config back to the database --->
	<cfset stResult=oVerity.setContentType(form.typename, contenttype) />
	
	<cflocation URL="#cgi.SCRIPT_NAME#" addtoken="false"  />
</cfif>


<!----------------------------------------
VIEW:
 - Collection settings
----------------------------------------->
<cfif structKeyExists(url, "typename")>

	<cfif NOT structKeyExists(stconfig.contenttype, typename)>
		<!--- default settings for config --->
		<cfset stconfig.contenttype[typename]=structNew() />
		<cfset stConfig.contenttype[typename].custom3="" />
		<cfset stConfig.contenttype[typename].custom4="" />
		<cfset stConfig.contenttype[typename].aProps=arrayNew(1) />
	</cfif>
	
	<!--- generate property list for collection --->
	<cfset qProps=queryNew("property")>
	
	<cfloop collection="#application.types[typename].stprops#" item="property">
		<cfset queryAddRow(qProps, 1)>
		<cfset querySetCell(qProps,"property",property)>
	</cfloop>
	
	<admin:header />
		<cfoutput><h1>Collection Settings for #typename#</h1></cfoutput>
		
		<cfform action="verityConfig.cfm">
			<cfoutput>
			<input type="hidden" name="typename" value="#typename#" />
			
			<h3>Properties to Index</h3>
			
			<fieldset title="Properties to Index">
			</cfoutput>
			
			<cfloop collection="#application.types[typename].stprops#" item="key">
				<cfif NOT listContainsNoCase(lexcludedProps, key) AND NOT listContainsNoCase(lexcludedPropTypes, application.types[typename].stprops[key].metadata.type) >
					<!--- provide some additional info on property to assist user --->
					<cfif structKeyExists(application.types[typename].stprops[key].metadata, "hint")>
						<cfset hint=application.types[typename].stprops[key].metadata.hint />
					<cfelse>
						<cfset hint=application.types[typename].stprops[key].metadata.type />
					</cfif>
					
					<!--- check for property selection --->
					<cfif listcontainsnocase(arraytolist(stConfig.contenttype[typename].aProps),key)>
						<cfset checked="checked" />
					<cfelse>
						<cfset checked="" />
					</cfif>
					
					<!--- highlight longchar property types as these should generally be indexed --->
					<cfif application.types[typename].stprops[key].metadata.type eq "longchar">
						<cfoutput><input type="checkbox" name="#key#" id="#key#" #checked# /> <strong>#key#</strong> (#application.types[typename].stprops[key].metadata.hint#)<br></cfoutput>
					<cfelse>
						<cfoutput><input type="checkbox" name="#key#" id="#key#" #checked# /> #key# (#application.types[typename].stprops[key].metadata.hint#)<br></cfoutput>
					</cfif>
					
				</cfif>
				
			</cfloop>
			
			<cfoutput>
			</fieldset>
			
			<h3>Custom Fields</h3>
			
			<fieldset title="Custom Property Fields">
				
				<p>
				CUSTOM3: <cfselect name="custom3" query="qProps" value="property" display="property" selected="#stConfig.contenttype[typename].custom3#" queryposition="below"><option value="">-- not used --</option></cfselect>
				</p>
				
				<p>
				CUSTOM4: <cfselect name="custom4" query="qProps" value="property" display="property" selected="#stConfig.contenttype[typename].custom4#" queryposition="below"><option value="">-- not used --</option></cfselect>
				</p>
				
			</fieldset>
			
			
				
			<!--- todo: remove.. temp repair for incomplete config files --->
			<cfparam name="stconfig.contenttype[typename].FileCollectionProperty" default="" type="string" />
			
			<h3>Associated File Library</h3>
			
			<fieldset title="Associated File Library">
				<p>
				FileCollectionProperty: <cfselect name="FileCollectionProperty" query="qProps" value="property" display="property" selected="#stConfig.contenttype[typename].FileCollectionProperty#" queryposition="below"><option value="">-- not used --</option></cfselect>
				</p>
			</fieldset>
			
			
			
			
			<cfset Request.InHead.Calendar = 1>
			<cfset request.ftDateFormatMask = "dd mmm yyyy">
			<cfset request.ftTimeFormatMask = "hh:mm tt">
			<cfset request.ftCalendarFormatMask = "%d %b %Y %I:%M %p">
			<cfparam name="stConfig.contenttype.#typename#.builttodate" default="" />
			
			<h3>Last Built To Date</h3>			

					
		
			
			<fieldset title="Last Built To Date">
				<input type="Text" name="builttodate" id="builttodate" value="#DateFormat(stConfig.contenttype[typename].builttodate,request.ftDateFormatMask)# #TimeFormat(stConfig.contenttype[typename].builttodate,request.ftTimeFormatMask)#" />
				<a id="builttodateDatePicker"><img src="#application.url.farcry#/js/DateTimePicker/cal.gif" width="16" height="16" border="0" alt="Pick a date"></a>
				
				
				<script type="text/javascript">
				  Calendar.setup(
				    {
					  inputField	: "builttodate",         // ID of the input field
				      ifFormat		: "#request.ftCalendarFormatMask#",    // the date format
				      button		: "builttodateDatePicker",       // ID of the button
				      showsTime		: true
				    }
				  );
				</script>
			</fieldset>
						
			<br />	
			<br />
			<input type="submit" name="updateCollection" value="Commit Collection Settings" />
			</cfoutput>
			
		</cfform>
		
	<admin:footer />

<cfelse>

<!-------------------------------------
VIEW:
 - Overview
-------------------------------------->
<!--- build structure of server collection info keyed by typename --->
<cfcollection action="list" name="qServerCollections" />
<cfset stServerCollections=structNew()>
<cfloop query="qServerCollections">
<cfif qServerCollections.name contains "#application.applicationname#_">
	<cfset typename=replacenocase(qServerCollections.name,"#application.applicationname#_", "", "all")>
	<cfset sttmp=structnew()>
	<cfloop list="#qServerCollections.columnlist#" index="col">
		<cfset sttmp[col]=evaluate("qServerCollections.#col#")>
	</cfloop>
	<cfset stServerCollections[typename]=duplicate(sttmp) />
</cfif>
</cfloop>

<!--- build query for output --->
<cfset qCollections=queryNew("typename,lproperties,lcustomfields,bcategory,lastmodified,doccount,bactive,filecollectionproperty,builttodate")>

<cfloop collection="#application.types#" item="typename">
	<cfif NOT listContainsNoCase(lexcludedTypes, typename)>

		<cfset queryAddRow(qCollections, 1)>
		<cfset querysetcell(qCollections,"typename",typename) />
		<cfif structKeyExists(stconfig.contenttype, typename)>
			<!--- provide defaults for legacy config files --->
			<cfparam name="stconfig.contenttype[typename].custom3" default="" type="string" />
			<cfparam name="stconfig.contenttype[typename].custom4" default="" type="string" />
			<cfparam name="stconfig.contenttype[typename].FileCollectionProperty" default="" type="string" />
			<cfparam name="stconfig.contenttype[typename].builttodate" default="" type="Any" />

			<cfset querysetcell(qCollections,"lproperties",arrayToList(stconfig.contenttype[typename].aprops)) />
			<cfset querysetcell(qCollections,"lcustomfields", "#stconfig.contenttype[typename].custom3# #stconfig.contenttype[typename].custom4#") />
			<cfset querysetcell(qCollections,"FileCollectionProperty", stconfig.contenttype[typename].FileCollectionProperty) />
			<cfset querysetcell(qCollections,"builttodate", stconfig.contenttype[typename].builttodate) />
		<cfelse>
			<cfset querysetcell(qCollections,"lproperties","-") />
			<cfset querysetcell(qCollections,"lcustomfields","-") /> 
			<cfset querysetcell(qCollections,"FileCollectionProperty","-") />
			<cfset querysetcell(qCollections,"builttodate", "-") />
		</cfif>
		<cfset querysetcell(qCollections,"bcategory",false) /> <!--- not ready yet --->
		<cfif structKeyExists(stServerCollections, typename)>
			<cfset querysetcell(qCollections,"lastmodified",stServerCollections[typename].lastmodified) /> 
			<cfset querysetcell(qCollections,"doccount",stServerCollections[typename].doccount) /> 
			<cfset querysetcell(qCollections,"bactive", true) />
		<cfelse>
			<cfset querysetcell(qCollections,"lastmodified","-") /> 
			<cfset querysetcell(qCollections,"doccount","-") />
			<cfset querysetcell(qCollections,"bactive", false) />
		</cfif>
	</cfif>
</cfloop>

<cfquery dbtype="query" name="qCollections">
SELECT * FROM qCollections
ORDER BY typename
</cfquery>

<!----------------------------------------
OUTPUT:
 - Overview screen
----------------------------------------->
<admin:header title="Type Collection Management" />

<cfoutput>
<h1>Type Collection Management</h1>

<table class="table-2" cellspacing="0">
<tr>
	<!---<th scope="col">Select</th> --->
	<th scope="col">typename</th>
	<th scope="col">lproperties</th>
	<th scope="col">lcustomfields</th>
	<th scope="col">bcategory</th>
	<th scope="col">FileCollectionProperty</th>
	<th scope="col">lastmodified</th>
	<th scope="col">doccount</th>
	<th scope="col">builttodate</th>
</tr>
</cfoutput>
<cfoutput query="qCollections">
<tr class="#iif(currentrow MOD 2, de("alt"), de(""))# #iif(qCollections.bactive, de(""), de("disabled"))#">
	<!---<td style="text-align: center;"><input type="checkbox" class="f-checkbox" name="objectid" value="4FA8AEFC-C0A8-7E1F-160956AF789CC4E8" onclick="setRowBackground(this);" /></td> --->
	<td><a href="verityConfig.cfm?typename=#qcollections.typename#">#qcollections.typename#</a></td>
	<td>#qcollections.lproperties#</td>
	<td>#qcollections.lcustomfields#</td>
	<td>#yesnoformat(qcollections.bcategory)#</td>
	<td>#qcollections.filecollectionproperty#</td>
	<cfif isDate(qcollections.lastmodified)>
	<td>#dateformat(qcollections.lastmodified)# #timeformat(qcollections.lastmodified)#</td>
	<td>#numberformat(qcollections.doccount)#</td>
	<cfelse>
	<td>-</td>
	<td>-</td>
	</cfif>
	<td>#qcollections.builttodate#</td>
</tr>
</cfoutput>
<cfoutput>
</table>
</cfoutput>

<admin:footer />

</cfif>


<cfsetting enablecfoutputonly="true" />
