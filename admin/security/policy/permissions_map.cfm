<cfparam name="form.action" default="" />
<cfparam name="form.filterPolicyGroupId" default="" />
<cfparam name="form.filterPermissionId" default="" />

<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">

<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

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

<cfoutput>
	
    <form method="POST" action="" name="theForm" class="f-wrap-1 f-bg-short wider">
    <h3>#application.adminBundle[session.dmProfile.locale].permissionsMap#</h3>
        <input type="hidden" name="action" value="filter" />
        <label for="filterPolicyGroupId"><b>Policy Group:</b>
	        <select name="filterPolicyGroupId" class="formselectlist">
	          <cfloop index="i" from="1" to="#arrayLen(aPolicyGroup)#">
	            <option value="#aPolicyGroup[i].policyGroupId#" <cfif aPolicyGroup[i].policyGroupId eq form.filterPolicyGroupId>selected</cfif>>#aPolicyGroup[i].policyGroupName#</option>
	          </cfloop>
	        </select><br />
	   </label>

        <label for="filterPermissionId"><b>Permission:</b>
	        <select name="filterPermissionId">
	          <cfloop index="i" from="1" to="#arrayLen(aPermissions)#">
	            <option value="#aPermissions[i].permissionId#" <cfif aPermissions[i].permissionId eq form.filterPermissionId>selected</cfif>>#aPermissions[i].permissionName#</option>
	          </cfloop>
	        </select><br />
        </label>
		<div class="f-submit-wrap">
        <input type="submit" value="Apply Filter" class="f-submit"/> <br />

        <cfif bFilter>
          <input type="button" value="Remove Filter" onClick="document.theForm.action.value = ''; document.theForm.submit()" class="f-submit"/> <br />
        <cfelse>
          (no filter applied)
        </cfif>
    </form>
</cfoutput>
    <p>
	<table cellpadding="2" cellspacing="0" border="1" style="margin-left:30px;">
	<tr class="dataheader">
		<td>Navigation Node</td>
		<cfif bFilter>
		  <td>Allowed</td>
          <td>Inherited</td>
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

 <!--- <cfsetting enablecfoutputonly="true" showdebugoutput="false">
<cfprocessingDirective pageencoding="utf-8">
<cfparam name="fatalErrorMessage" default=""> <!--- fatal [ie something wrong with the db and page cant render] --->
<cfparam name="errorMessage" default=""> <!--- normal error [ie server side validation] --->
<cfparam name="form.action" default="">

<cfset bFilter = form.action eq "filter" />

<!--- set up page header --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">

<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">
<cfoutput>
<h3>#application.adminBundle[session.dmProfile.locale].permissionsMap#</h3>
<cfif fatalErrorMessage NEQ "">
		<span class="error">#fatalErrorMessage#</span>
<cfelse>
	<cfif errorMessage NEQ "">
		<span class="error">#errorMessage#</span>
	</cfif>
	<form name="frm" method="post" class="f-wrap-1 f-bg-short wider" action="#cgi.script_name#">
	<fieldset>
		<label for="polgroup"><b>Policy Group:</b>
			<select name="polgroup" id="polgroup" class="formselectlist">
				<option value="Anonymous" >Anonymous</option>
			</select><br />
		</label>
		
		<label for="permaction"><b>Permission:</b>
			<select name="permaction" id="permaction" class="formselectlist">
				<option value="Approve" >Approve</option>
			</select><br />
		</label>
		
		<div class="f-submit-wrap">
		<input type="submit" name="Submit" value="Apply Filter" class="f-submit" /><br />
		<cfif bFilter>
		<input type="submit" name="Submit" value="#application.adminBundle[session.dmProfile.locale].removeFilter#" class="f-submit" /><br />
		<cfelse>
		<a href="##" onclick="generateRandomPassword()" class="f-extratext">#application.adminBundle[session.dmProfile.locale].noFilterAppled#</a>
		</cfif>
		</div>		
	</fieldset>		
	</form>
	
	<hr />	

</cfif></cfoutput>


<!--- setup footer --->
<admin:footer>
<cfsetting enablecfoutputonly="false"> --->