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

<skin:view typename="farUser" template="displayHeaderLogin" />
	<ft:form>
			
		<cfoutput>
		<div class="loginInfo">
		</cfoutput>	
				
			<cfif structKeyExists(server, "stFarcryProjects") AND listLen(structKeyList(server.stFarcryProjects)) GT 1>
				<cfoutput>
					<fieldset class="formSection">
						<legend>Project Selection</legend>
						<div class="fieldSection string">
							<label class="fieldsectionlabel" for="selectFarcryProject"> Project  : </label>
							<div class="fieldAlign">
								<select id="selectFarcryProject" onchange="window.location='#application.url.webtop#/login.cfm?returnUrl=#urlencodedformat(url.returnUrl)#&farcryProject='+this.value;">						
									<cfloop list="#structKeyList(server.stFarcryProjects)#" index="thisProject">
										<option value="#thisProject#"<cfif cookie.currentFarcryProject eq thisProject> selected</cfif>>#server.stFarcryProjects[thisProject]#</option>
									</cfloop>						
								</select>
							</div>
							<br class="clearer"/>
						</div>	
					</fieldset>
				</cfoutput>		
			</cfif>

			
			<sec:SelectUDLogin />
			

			<ft:object typename="farLogin" lFields="username,password,datetimelastupdated" legend="Login to #application.config.general.siteTitle#" />
				
			
			<ft:farcrybuttonPanel>
			

				<cfif isdefined("arguments.stParam.message") and len(arguments.stParam.message)>
					<cfoutput>
						<div class="error">#arguments.stParam.message#</div>
					</cfoutput>
				</cfif>
				
				<ft:farcrybutton value="Log In" />
			</ft:farcrybuttonPanel>
			
			<cfset stParameters = structNew() />
			<cfset stParameters.returnUrl = "#url.returnUrl#" />
			
			<ft:farcrybuttonPanel>					
				<cfoutput><ul class="fc"></cfoutput>
					<sec:CheckPermission webskinpermission="forgotPassword" type="farUser">
						<skin:buildLink type="farUser" view="forgotPassword" stParameters="#stParameters#"><cfoutput><li>Forgot Password</li></cfoutput></skin:buildLink>
					</sec:CheckPermission>
					<sec:CheckPermission webskinpermission="forgotUserID" type="farUser">
						<skin:buildLink type="farUser" view="forgotUserID" stParameters="#stParameters#"><cfoutput><li>Forgot UserID</li></cfoutput></skin:buildLink>
					</sec:CheckPermission>			
					<sec:CheckPermission webskinpermission="registerNewUser" type="farUser">
						<skin:buildLink type="farUser" view="registerNewUser" stParameters="#stParameters#"><cfoutput><li>Register New User</li></cfoutput></skin:buildLink>
					</sec:CheckPermission>
				<cfoutput></ul></cfoutput>
				
			</ft:farcrybuttonPanel>
	
		<cfoutput>
		</div>
		</cfoutput>		
				
	</ft:form>

<skin:view typename="farUser" template="displayFooterLogin" />


<cfsetting enablecfoutputonly="false">