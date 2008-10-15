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
<!--- @@displayname: Farcry UD login form --->
<!--- @@description:   --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY IMPORT FILES
 ------------------>
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />
<cfimport taglib="/farcry/core/tags/extjs/" prefix="extjs" />



<!------------------ 
START WEBSKIN
 ------------------>	

<skin:view typename="farLogin" template="displayHeaderLogin" />
	
			
		<cfoutput>
		<div class="loginInfo">
		</cfoutput>	
		
			<ft:form>	
				
				<sec:selectProject />
				
				<sec:SelectUDLogin />
				
	
				<ft:object typename="farLogin" lFields="username,password" prefix="login" legend="" />
					
				
				<ft:farcryButtonPanel>
				
	
					<cfif isdefined("arguments.stParam.message") and len(arguments.stParam.message)>
						<extjs:bubble message="#arguments.stParam.message#" />
					</cfif>
					
					<ft:button value="Log In" icon="#application.url.webtop#/images/crystal/22x22/actions/lock.png" rbkey="security.buttons.login" />
				</ft:farcryButtonPanel>

				
				<ft:farcryButtonPanel>					
					<cfoutput><ul class="loginForgot"></cfoutput>
						<sec:CheckPermission webskinpermission="forgotPassword" type="farUser">
							<cfoutput> 
								<li><skin:buildLink type="farUser" view="forgotPassword">Forgot Password</skin:buildLink></li></cfoutput>
						</sec:CheckPermission>
						<sec:CheckPermission webskinpermission="forgotUserID" type="farUser">
							<cfoutput> 
								<li><skin:buildLink type="farUser" view="forgotUserID">Forgot UserID</skin:buildLink></li></cfoutput>
						</sec:CheckPermission>			
						<sec:CheckPermission webskinpermission="registerNewUser" type="farUser">
							<cfoutput> 
								<li><skin:buildLink type="farUser" view="registerNewUser">Register New User</skin:buildLink></li></cfoutput>
						</sec:CheckPermission>
					<cfoutput></ul></cfoutput>

				</ft:farcryButtonPanel>
			</ft:form>
			

			
		<cfoutput>
		</div>
		</cfoutput>		
				
	

<skin:view typename="farLogin" template="displayFooterLogin" />


<cfsetting enablecfoutputonly="false">