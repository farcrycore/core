<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<cfset session.fc.trayWebskin = "displayAdminBarSummary" />


<skin:onReady>
<cfoutput>

$j('##hide-tray').click(function(){
	$fc.traySwitch('displayAdminBarHidden');
});
$j('##show-detail').click(function(){
	$fc.traySwitch('displayAdminBarDetail');
});



</cfoutput>
</skin:onReady>


<cfoutput>
<div style="display:block;margin-left:15px;margin-right:15px;overflow:visible !important;position:relative;border:1px solid ##B5B5B5;border-width:1px 1px 0px 1px;background-color:##E5E5E5;">
	<div style="display:block;padding:0;border-top:1px solid ##FFFFFF;">
		<div style="float:left;">
</cfoutput>


<cfdump var="#form#" expand="false" label="form">
<cfoutput>#application.fapi.getContentTypeMetadata(typename="#stobj.typename#", md="displayName", default="#stobj.typename#")#</cfoutput>

<ft:form validation="false">
<cfoutput>
<a id="hide-tray" class="ui-icon toggletray_icon"></a>
<a id="show-detail" class="ui-icon moredetail_icon"></a>
</cfoutput>

<cfif request.mode.flushcache>
	<ft:button value="Cache Off" type="button" class="ui-state-default ui-corner-all" url="#application.fapi.fixURL(url='#cgi.HTTP_REFERER#', addvalues='flushcache=0')#" />
<cfelse>
	<ft:button value="Cache On" text="Cache On" type="button" class="ui-state-active ui-corner-all" url="#application.fapi.fixURL(url='#cgi.HTTP_REFERER#', addvalues='flushcache=1')#" />
	<!--- <span class='ui-icon ui-icon-triangle-1-e' style='margin-top:-8px;position:absolute;top:50%;'/><span style='padding:0.5em 0.5em 0.5em 2.2em;'>Cache On</span> --->
</cfif>


<cfif request.mode.showdraft>		
	<ft:button value="Showing Drafts" type="button" class="ui-state-active ui-corner-all" url="#application.fapi.fixURL(url='#cgi.HTTP_REFERER#', addvalues='flushcache=1&showdraft=0')#" />
<cfelse>
	<ft:button value="Hiding Drafts" type="button" class="ui-state-default ui-corner-all" url="#application.fapi.fixURL(url='#cgi.HTTP_REFERER#', addvalues='flushcache=0&showdraft=1')#" />
</cfif>


<cfif request.mode.design and request.mode.showcontainers gt 0>
	<ft:button value="Showing Rules" type="button" class="ui-state-active ui-corner-all" url="#application.fapi.fixURL(url='#cgi.HTTP_REFERER#', addvalues='designmode=0')#" />
<cfelse>
	<ft:button value="Hiding Rules" type="button" class="ui-state-default ui-corner-all" url="#application.fapi.fixURL(url='#cgi.HTTP_REFERER#', addvalues='designmode=1')#" />
</cfif>

</ft:form>

<cfoutput>
	
		</div>
		<br style="clear:both;" />
	</div>
</div>
</cfoutput>