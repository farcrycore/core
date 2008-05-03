<cfsetting enablecfoutputonly="Yes">
<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
<!--- @@displayname: Farcry UD login form --->
<!--- @@description:   --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY IMPORT FILES
 ------------------>
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />



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
						<cfoutput>
							<div class="error">#arguments.stParam.message#</div>
						</cfoutput>
					</cfif>
					
					<ft:button value="Log In" icon="#application.url.webtop#/images/crystal/22x22/actions/lock.png" />
				</ft:farcryButtonPanel>
				
				<cfset stParameters = structNew() />
				<cfset stParameters.returnUrl = "#url.returnUrl#" />
				<!--- 
				<ft:farcryButtonPanel>					
					<cfoutput><ul class="fc"></cfoutput>
						<sec:CheckPermission webskinpermission="forgotPassword" type="farUser">
							<cfoutput><li><skin:buildLink type="farUser" view="forgotPassword" stParameters="#stParameters#">Forgot Password</skin:buildLink></li></cfoutput>
						</sec:CheckPermission>
						<sec:CheckPermission webskinpermission="forgotUserID" type="farUser">
							<cfoutput><li><skin:buildLink type="farUser" view="forgotUserID" stParameters="#stParameters#">Forgot UserID</skin:buildLink></li></cfoutput>
						</sec:CheckPermission>			
						<sec:CheckPermission webskinpermission="registerNewUser" type="farUser">
							<cfoutput><li><skin:buildLink type="farUser" view="registerNewUser" stParameters="#stParameters#">Register New User</skin:buildLink></li></cfoutput>
						</sec:CheckPermission>
					<cfoutput></ul></cfoutput>
					
				</ft:farcryButtonPanel> --->
			</ft:form>
			
		<cfoutput>
		</div>
		</cfoutput>		
				
	

<skin:view typename="farLogin" template="displayFooterLogin" />


<cfsetting enablecfoutputonly="false">