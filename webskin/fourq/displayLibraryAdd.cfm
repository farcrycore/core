<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
<!--- @@displayname: library summary --->
<!--- @@description:   --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY IMPORT FILES
 ------------------>
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />


<skin:htmlHead id="jqueryJS">
	<cfoutput>
		<script src="#application.url.webtop#/thirdparty/jquery/js/jquery-1.3.2.min.js" type="text/javascript"></script>
		<script type="text/javascript">
		     var $j = jQuery.noConflict();
		</script></cfoutput>
</skin:htmlHead>


<!------------------ 
START WEBSKIN
 ------------------>
<cfif application.fapi.isLoggedIn()>
	
	<cfparam name="url.property" type="string" />
	<cfparam name="url.filterTypename" type="string" default="" />
	
	<cfset stMetadata = application.fapi.getPropertyMetadata(typename="#stobj.typename#", property="#url.property#") />
	
	<cfif not len(url.filterTypename)>		
		<cfset url.filterTypename = listFirst(stMetadata.ftJoin) />
	</cfif>
	
	<cfif structKeyExists(form, "filterTypename")>
		<cfset url.filterTypename = form.filterTypename />
	</cfif>
	
			
	<ft:form name="#stobj.typename#_#url.property#">
		
		
		<cfset stNewObject = application.fapi.getNewContentObject(typename="#url.filterTypename#", key="newLibraryObject") />

		
		<cfset stOnExit = structNew() />
		<cfset stOnExit.type = "HTML" />
		<cfsavecontent variable="stOnExit.content">
		<cfoutput>
		<script type="text/javascript">
		$j(function() {
			$j.ajax({
				cache: false,
				type: "POST",
	 			url: '/index.cfm?ajaxmode=1&type=#stobj.typename#&objectid=#stobj.objectid#&view=displayAjaxUpdateJoin&property=#url.property#',
				data: {addID: '#stNewObject.objectid#'},
				dataType: "html",
				complete: function(data){
					parent.$j('###stobj.typename##stobj.objectid##url.property#').dialog('close');
				}
			});		
		});
		</script>
		</cfoutput>
		</cfsavecontent>
				
		<cfset oType = application.fapi.getContentType("#url.filterTypename#") />		
  		<cfset html = oType.getView(objectID="#stNewObject.objectid#", webskin="libraryAdd", OnExit="#stOnExit#", alternateHTML="", bIgnoreSecurity="true") />
		
		<cfif len(html)>
		    <cfoutput>#html#</cfoutput>
		<cfelse>
			<!--- THIS IS THE LEGACY WAY OF DOING THINGS AND STAYS FOR BACKWARDS COMPATIBILITY --->
		    <cfinvoke component="#oType#" method="edit">
		        <cfinvokeargument name="objectId" value="#stNewObject.objectID#" />
		        <cfinvokeargument name="onExit" value="#stOnExit#" />
		    </cfinvoke>
		</cfif>
		
	</ft:form>

</cfif>

<cfsetting enablecfoutputonly="false">