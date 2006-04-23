<cfprocessingDirective pageencoding="utf-8">
<cfparam name="form.action" default="" />
<cfparam name="form.filterPolicyGroupId" default="" />
<cfparam name="form.filterPermissionId" default="" />

<cfset bFilter = form.action eq "filter" />

<cfscript>
    oAuthorisation = request.dmsec.oAuthorisation;
	aPolicyGroup = request.dmsec.oAuthorisation.getAllPolicyGroups();
	aPermissions = oAuthorisation.getAllPermissions(permissionType="dmNavigation");
</cfscript>


<cffunction name="getPermission" hint="checks whether permissions are set in the permmision barnacle.">
	<cfargument name="q" hint="This is assumed to be a query of dmPermissionBarnacle">
	<cfargument name="objectid">
	<cfargument name="lPolicyGroupIds" required="No" default="">
	<cfargument name="lPermissionIds" required="No" default="">
	<cfargument name="lStatus" required="No" default="1">
	
	<cfset bPermsSet = false>
	<cfquery name="q" dbtype="query">
		SELECT status FROM arguments.q
		WHERE reference1 = <cfqueryparam value="#arguments.objectid#" />
	</cfquery>
	<cfif q.recordcount>
		<cfreturn q.status />
	</cfif>
	<cfreturn 0 />
</cffunction>

<cfquery name="qPerms" datasource="#application.dsn#">
	SELECT * from dmPermissionBarnacle
	<cfif bFilter>
	    where permissionId = <cfqueryparam value="#form.filterPermissionId#" />
	    and policyGroupId = <cfqueryparam value="#form.filterPolicyGroupId#" />
	</cfif>
</cfquery>


<cfscript>
	oTree = createObject("component","#application.packagepath#.farcry.tree");
	qDesc = oTree.getDescendants(objectid='#application.navid.root#',dsn=application.dsn,bIncludeSelf=1);
</cfscript>

<cfoutput><p class="formtitle">#application.adminBundle[session.dmProfile.locale].permissionsMap#</p></cfoutput>

<cfoutput>
    <form method="POST" action="" name="theForm">
        <input type="hidden" name="action" value="filter" />
        #application.adminBundle[session.dmProfile.locale].policyGroupLabel#
        <select name="filterPolicyGroupId">
          <cfloop index="i" from="1" to="#arrayLen(aPolicyGroup)#">
            <option value="#aPolicyGroup[i].policyGroupId#" <cfif aPolicyGroup[i].policyGroupId eq form.filterPolicyGroupId>selected</cfif>>#aPolicyGroup[i].policyGroupName#</option>
          </cfloop>
        </select>

        #application.adminBundle[session.dmProfile.locale].permissionLabel#
        <select name="filterPermissionId">
          <cfloop index="i" from="1" to="#arrayLen(aPermissions)#">
            <option value="#aPermissions[i].permissionId#" <cfif aPermissions[i].permissionId eq form.filterPermissionId>selected</cfif>>#aPermissions[i].permissionName#</option>
          </cfloop>
        </select>

        <input type="submit" value="#application.adminBundle[session.dmProfile.locale].applyFilter#" />

        <cfif bFilter>
          <input type="button" value="#application.adminBundle[session.dmProfile.locale].removeFilter#" onClick="document.theForm.action.value = ''; document.theForm.submit()" />
        <cfelse>
          #application.adminBundle[session.dmProfile.locale].noFilterAppled#
        </cfif>
    </form>
</cfoutput>
    <p>
	<table cellpadding="2" cellspacing="0" border="1" style="margin-left:30px;">
	
	<tr class="dataheader">
		<td><cfoutput>#application.adminBundle[session.dmProfile.locale].navigationNode#</cfoutput></td>
		<cfif bFilter>
			<cfoutput>
		  	<td>#application.adminBundle[session.dmProfile.locale].Allowed#</td>
          	<td>#application.adminBundle[session.dmProfile.locale].inherited#</td>
			</cfoutput>  
        </cfif>
	</tr>
	
    <cfoutput query="qDesc">
        <cfset permission = getPermission(qPerms, objectId) />
        <cfset bInherited = permission eq 0 />
        <cfset bAllowed = permission eq 1 />
        <tr>
          <td>
              #repeatString("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;", nLevel)#
              <cfif not bInherited>
                  <a href="#application.url.farcry#/navajo/permissions.cfm?objectId=#objectid#">#objectName#</a>
              <cfelse>
                  #objectName#
              </cfif>
          </td>
		<cfif bFilter>
          <td align="center">
            <cfif bAllowed>
                <img src="#application.url.farcry#/images/yes.gif">
            <cfelseif not bInherited>
                <img src="#application.url.farcry#/images/no.gif">
            <cfelse>
                &nbsp;
            </cfif>
          </td>
          <td align="center">
            <cfif bInherited>
                <img src="#application.url.farcry#/images/yes.gif">
            <cfelse>
                &nbsp;
            </cfif>
          </td>
        </cfif>
        </tr>
    </cfoutput>
    </table>
    </p>
