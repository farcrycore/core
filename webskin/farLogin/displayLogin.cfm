<cfsetting enablecfoutputonly="Yes">
<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!--- @@displayname: FarCry UD login form --->
<!--- @@description:   --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY IMPORT FILES
 ------------------>
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />



<cfset qExtraOptions = querynew("label,url,selected","varchar,varchar,bit") />

<cfif structKeyExists(url,'returnurl') and len(trim(url.returnurl))>
	<cfset stLocal.loginparams = 'returnurl='&application.fc.lib.esapi.encodeForURL(url.returnurl) />
<cfelse>
	<cfset stLocal.loginparams = '' />
</cfif>

<cfif structKeyExists(server, "stFarcryProjects") AND structcount(server.stFarcryProjects) GT 1>
	<cfset aDomainProjects = arraynew(1) />
	<cfloop collection="#server.stFarcryProjects#" item="thisproject">
		<cfif isstruct(server.stFarcryProjects[thisproject]) and listcontains(server.stFarcryProjects[thisproject].domains,cgi.http_host)>
			<cfset arrayappend(aDomainProjects,thisproject) />
		</cfif>
	</cfloop>
	
	<cfif arraylen(aDomainProjects) gt 1>
		<cfloop from="1" to="#arraylen(aDomainProjects)#" index="i">
			<cfset queryaddrow(qExtraOptions) />
			<cfset querysetcell(qExtraOptions,"label",server.stFarcryProjects[aDomainProjects[i]].displayname) />
			<cfset querysetcell(qExtraOptions,"url",application.fapi.getLink(href=application.url.webtoplogin,urlParameters="#stLocal.loginparams#&farcryProject=#aDomainProjects[i]#")) />
			<cfset querysetcell(qExtraOptions,"selected",cookie.currentFarcryProject eq aDomainProjects[i]) />
		</cfloop>
	</cfif>
</cfif>			

<cfif listlen(application.security.getAllUD()) gt 1>
	<cfif qExtraOptions.recordcount>
		<cfset queryaddrow(qExtraOptions) />
		<cfset querysetcell(qExtraOptions,"label","divider") />
		<cfset querysetcell(qExtraOptions,"url","divider") />
	</cfif>
	
	<cfloop list="#application.security.getAllUD()#" index="thisud">
		<cfset queryaddrow(qExtraOptions) />
		<cfset querysetcell(qExtraOptions,"label",application.security.userdirectories[thisud].title) />
		<cfset querysetcell(qExtraOptions,"url",application.fapi.getLink(href=application.url.webtoplogin,urlParameters="#stLocal.loginparams#&ud=#thisud#")) />
		<cfset querysetcell(qExtraOptions,"selected",application.security.getDefaultUD() eq thisud) />
	</cfloop>
</cfif>

<!--- Get alternate sessions --->
<cfset qSessions = application.fc.lib.session.getSessions(bCurrent=0) />
<cfif qSessions.recordcount>
	<cfif qExtraOptions.recordcount>
		<cfset queryaddrow(qExtraOptions) />
		<cfset querysetcell(qExtraOptions,"label","divider") />
		<cfset querysetcell(qExtraOptions,"url","divider") />
	</cfif>
	
	<cfset queryaddrow(qExtraOptions) />
	<cfset querysetcell(qExtraOptions,"label","Select User") />
	<cfset querysetcell(qExtraOptions,"url","nav-header") />

	<cfloop query="qSessions">
		<cfset queryaddrow(qExtraOptions) />
		<cfset querysetcell(qExtraOptions,"label","#qSessions.user# (last used #timeformat(qSessions.lastAccessed, 'h:mmtt')#)") />
		<cfset querysetcell(qExtraOptions,"url",application.fapi.fixURL(url=arguments.stParam.loginReturnURL, addvalues='switchsession=#qSessions.sessionID#')) />
		<cfset querysetcell(qExtraOptions,"selected",false) />
	</cfloop>
</cfif>

<skin:view typename="farLogin" template="displayHeaderLogin" />

<ft:form bAddFormCSS="false" class="clearfix">
	<skin:pop><cfoutput>
		<div class="alert alert-error">
			<cfif len(trim(message.title))><strong>#message.title#</strong></cfif>
			<cfif len(trim(message.message))>#message.message#</cfif>
		</div>
	</cfoutput></skin:pop>
	
	<cfif isdefined("arguments.stParam.message") and len(arguments.stParam.message)>
		<cfoutput><div class="alert alert-warning"><admin:resource key="security.message.#rereplace(arguments.stParam.message,'[^\w]','','ALL')#">#arguments.stParam.message#</admin:resource></div></cfoutput>
	</cfif>
	
	<ft:object typename="farLogin" lFields="username,password" prefix="login" legend="" focusField="username" r_stFields="stFields" />
	
	<cfoutput>
		<fieldset>
			<label for="#stFields.username.formfieldname#">#stFields.username.ftLabel#</label>
			#stFields.username.html#
		</fieldset>
		<fieldset>
			<label for="#stFields.password.formfieldname#">#stFields.password.ftLabel#</label>
			#stFields.password.html#
		</fieldset>

		<div class="btn-group dropdown pull-right">
			<ft:button rendertype="button" class="btn btn-primary btn-large" rbkey="security.buttons.login" value="Log In" />
			<cfif qExtraOptions.recordcount>
				<a class="btn btn-primary btn-large dropdown-toggle" data-toggle="dropdown"><span class="caret"></span></a>
				<ul class="dropdown-menu">
					<cfloop query="qExtraOptions">
						<cfif qExtraOptions.url eq "divider">
							<li class="divider"></li>
						<cfelseif qExtraOptions.url eq "nav-header">
							<li class="nav-header" style="padding-left:15px;">#qExtraOptions.label#</li>
						<cfelse>
							<li <cfif qExtraOptions.selected> class="active"</cfif>><a href="#qExtraOptions.url#">#qExtraOptions.label#</a></li>
						</cfif>
					</cfloop>
				</ul><!-- /.dropdown-menu -->
			</cfif>
		</div><!-- /.btn-group -->
	
		<p class="help-inline">

			<cfset hasPrev = false />
			<sec:CheckPermission webskinpermission="forgotUserID" type="farUser">
				<skin:buildLink type="farUser" view="forgotUserID" rbkey="coapi.farLogin.login.forgotuserid">Forgot Username</skin:buildLink>
				<cfset hasPrev = true />
			</sec:CheckPermission>
			<sec:CheckPermission webskinpermission="forgotPassword" type="farUser">
				<cfif hasPrev>
					&middot;
				</cfif>
				<skin:buildLink type="farUser" view="forgotPassword" rbkey="coapi.farLogin.login.forgotpassword">Forgot Password</skin:buildLink>
				<cfset hasPrev = true />
			</sec:CheckPermission>
			<sec:CheckPermission webskinpermission="registerNewUser" type="farUser">
				<cfif hasPrev>
					&middot;
				</cfif>
				<skin:buildLink type="farUser" view="registerNewUser" rbkey="coapi.farLogin.login.registernewuser">Register New User</skin:buildLink>
			</sec:CheckPermission>

		</p>
	</cfoutput>
</ft:form>

<skin:view typename="farLogin" template="displayFooterLogin" />

<cfsetting enablecfoutputonly="false">