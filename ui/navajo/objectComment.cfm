<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header>

<cfif isdefined("form.submit")>
	<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">
	<!--- update status --->
	<nj:objectStatus_dd lObjectIDs="#form.objectID#" status="#form.status#" commentLog="#form.commentlog#" rMsg="msg">
	<!--- return to overview page --->
	<cflocation url="#application.url.farcry#/navajo/GenericAdmin.cfm?typename=#form.typename#" addtoken="no">
<cfelse>
	<!--- show comment form --->
	
	<!--- get object details --->
	<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
	<q4:contentobjectget objectid="#listgetat(url.objectID,1)#" r_stobject="stObj">

	<cfif isdefined("stObj.status")>
		<cfoutput>
			<form action="" method="post">
			<!--- hack to pass attributes through form --->
			<input type="hidden" name="objectid" value="#url.objectid#">
			<input type="hidden" name="status" value="#url.status#">
			<input type="hidden" name="typename" value="#stObj.typename#">
			
			<span class="formTitle">Add your comments:</span><br>
			<textarea rows="8" cols="50"  name="commentLog"></textarea><br>
			<input type="submit" name="submit" value="Submit" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';">
			<input type="button" name="Cancel" value="Cancel" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';" onClick="location.href='#application.url.farcry#/navajo/genericadmin.cfm?typename=#stObj.typename#';"></div>     
			<cfif listlen(url.objectid) eq 1>
				<!--- display existing comments --->
				<cfif structKeyExists(stObj,"commentLog")>
					<cfif len(trim(stObj.commentLog)) AND structKeyExists(stObj,"commentLog")>
						<p></p><span class="formTitle">Previous Comments</span><P></P>
						#htmlcodeformat(stObj.commentLog)#
					</cfif>
				</cfif>
			</cfif>
			</form>
		</cfoutput>
	</cfif>
</cfif>

<!--- setup footer --->
<admin:footer>