<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/grid" prefix="grid" />

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
<div class="tray-summary" style="display:block;margin-left:15px;margin-right:15px;overflow:visible !important;position:relative;border:1px solid ##B5B5B5;border-width:1px 1px 0px 1px;background-color:##E5E5E5;">
	<div style="display:block;padding:0;border-top:1px solid ##FFFFFF;">
		<div style="">
</cfoutput>

<!--- If the url points to a type webskin, we need to determine the content type. --->
<cfif stObj.typename eq "farCOAPI">
	<cfset contentTypename = stobj.name />
<cfelse>
	<cfset contentTypename = stobj.typename />
</cfif>


	<grid:div style="float:left;">
		<cfoutput>
		<a id="hide-tray" class="ui-icon toggletray_icon" style="float:left;"></a>
		<a id="show-detail" class="ui-icon moredetail_icon" style="float:left;"></a>
		</cfoutput>
	</grid:div>
	<grid:div style="float:left;">
		<cfoutput><img class='traytypeicon' src='#application.url.webtop#/facade/icon.cfm?icon=#contentTypename#&size=16' alt='#stObj.typename#' /></cfoutput>
	</grid:div>
	
	<grid:div style="float:left;width:50%;">
		<cfoutput>#application.fapi.getContentTypeMetadata(typename="#contentTypename#", md="displayName", default="#contentTypename#")#</cfoutput>
	</grid:div>

	<grid:div style="float:right;">
		
		<cfoutput>
		<ul id="tray-actions">§
			
				<cfif request.mode.flushcache>
					<li>
						<a href="#application.fapi.fixURL(url='#cgi.HTTP_REFERER#', removevalues="", addvalues='flushcache=0')#" 
							style="background-image:url(#application.url.webtop#/facade/icon.cfm?icon=redled&size=16);">
							Cache OFF
						</a>
					</li>
				<cfelse>
					<li>
						<a href="#application.fapi.fixURL(url='#cgi.HTTP_REFERER#', removevalues="", addvalues='flushcache=1')#"
							style="background-image:url(#application.url.webtop#/facade/icon.cfm?icon=redled&size=16);">
							Cache ON
						</a>
					</li>
					<!--- <span class='ui-icon ui-icon-triangle-1-e' style='margin-top:-8px;position:absolute;top:50%;'/><span style='padding:0.5em 0.5em 0.5em 2.2em;'>Cache On</span> --->
				</cfif>
			
			
			<cfif request.mode.showdraft>		
				<li>
					<skin:buildLink href="#application.fapi.fixURL(url='#cgi.HTTP_REFERER#', addvalues='flushcache=1&showdraft=0')#" 
						style="background-image:url(#application.url.webtop#/facade/icon.cfm?icon=greenled&size=16);">
						Showing Drafts
					</skin:buildLink>
				</li>
			<cfelse>
				<li>
					<skin:buildLink href="#application.fapi.fixURL(url='#cgi.HTTP_REFERER#', addvalues='flushcache=0&showdraft=1')#" 
						style="background-image:url(#application.url.webtop#/facade/icon.cfm?icon=greenled&size=16);">
						Hiding Drafts
					</skin:buildLink>
				</li>
			</cfif>
			
			
			<cfif request.mode.design and request.mode.showcontainers gt 0>	
				<li>
					<skin:buildLink href="#application.fapi.fixURL(url='#cgi.HTTP_REFERER#', addvalues='designmode=0')#" 
						style="background-image:url(#application.url.webtop#/facade/icon.cfm?icon=greenled&size=16);">
						Showing Rules
					</skin:buildLink>
				</li>
			<cfelse>
				<li>
					<skin:buildLink href="#application.fapi.fixURL(url='#cgi.HTTP_REFERER#', addvalues='designmode=1')#" 
						style="background-image:url(#application.url.webtop#/facade/icon.cfm?icon=redled&size=16);">
						Hiding Rules
					</skin:buildLink>
				</li>
			</cfif>
			
		
		</ul>
		</cfoutput>
	</grid:div>


<cfoutput>
	
		</div>
		<br style="clear:both;" />
	</div>
</div>
</cfoutput>