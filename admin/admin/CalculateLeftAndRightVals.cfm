<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/admin/Attic/CalculateLeftAndRightVals.cfm,v 1.4 2003/04/02 04:56:52 andrewr Exp $
$Author: andrewr $
$Date: 2003/04/02 04:56:52 $
$Name: b131 $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: This tag is a component of fixtree.
It works out the left and right values for a given objectid, based on its parentid, older sibling and the number
of descendants it has.
If it has an older sibling, then its left hand value will be one more than the right hand value of the older sibling. If not, 
it will be one more than the right hand value of the parent. (Assumed: that the older sibling and parent have been "fixed" before 
we deal with this object.)
Its right hand value will be : lefthand value + (count of descendants*2) - 1$
$TODO: $

|| DEVELOPER ||
$Developer: Daniel Morphett (daniel@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->
<cfsetting enablecfoutputonly="Yes">

<!--- check atts --->
<cfif  not IsDefined("attributes.objectID") 
    or not IsDefined("attributes.parentID") 
    or not IsDefined("attributes.datasource") 
    or not IsDefined("attributes.typename") 
    or not IsDefined("attributes.r_nleft")  
    or not IsDefined("attributes.r_nright")
    or not IsDefined("attributes.debug")>
    <cfabort showerror="missing attribute. can't do it">
</cfif>

<cfset TableName = "#attributes.temptablename#">

<!--- work out the left hand value---------------------------------------------------------------->
<!--- see if the object has an older sibling. If so we need the right hand val of its next oldest one --->
<cfquery name="qOlderSibling" datasource="#attributes.datasource#">
    select isnull(max(nright),0) as nright from #TableName# 
    where parentid = '#attributes.parentid#'     
</cfquery>

<cfif qOlderSibling.nright gt 0>
   	<cfset nleft = qOlderSibling.nright + 1>	
<cfelse>    
	<!--- If no older sibling, we need the left hand val of its parent --->
    <cfquery name="qParent" datasource="#attributes.datasource#">
        select nleft from #TableName# 
        where objectid = '#attributes.parentid#'
    </cfquery>
    <cfif attributes.parentid eq ""><!--- no parent: it is the root. set the left to 1 --->
        <cfset nleft = 1>
	<cfelseif qParent.recordcount eq 0>
		<!--- it is an orphan --->
		<cfset nleft = 0>
		<!--- TODO: work out what to do with these --->
    <cfelse>
		<cfset nleft = qParent.nleft + 1>
    </cfif>
</cfif>

<!--- now work out the right hand value---------------------------------------------------------------->
<!--- we get a count of its descendants --->
<cf_getCountDescendants 
    datasource="#attributes.datasource#" 
    objectID="#attributes.objectID#"
    r_count="numDescendants">
        
<!--- whatever the count is, the right hand value will be : lefthand value + (count of descendants*2) - 1 --->
<cfset nright = nleft + (numDescendants*2) + 1>

<!--- return the values --->
<cfset "caller.#attributes.r_nleft#" = nleft>
<cfset "caller.#attributes.r_nright#" = nright>

<cfsetting enablecfoutputonly="No">