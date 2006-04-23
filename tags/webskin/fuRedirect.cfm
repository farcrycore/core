<!--- 

 Friendly URL redirect handler.

 Created: Mon Aug 29  20:00:20 2005
 $Revision 0.2$
 Modified: $Date: 2005/08/29 20:06:33 $

 Author: Spike
 E-mail: spike@spike.org.uk

 Description: The purpose of this file is to provide a 
			  default implementation of a CF redirect
			  handler for Friendly URLS.
			  
			  In order to use this file you will need to have
			  the following or something similar in web.xml

				<servlet>
					<servlet-name>FUServlet</servlet-name>
					<display-name>FriendlyUrlServlet</display-name>
					<description>Translates friendly URLs to objects</description>
					<servlet-class>FriendlyURLServlet</servlet-class>
					<init-param>
						<param-name>redirectHandler</param-name>
						<param-value>/go.cfm</param-value>
					</init-param>
				</servlet>
				
				<servlet-mapping>
					<servlet-name>FUServlet</servlet-name>
					<url-pattern>/go/*</url-pattern>
				</servlet-mapping> 

			  Specifically, the init-param for the servlet is what
			  allows the handling of the redirect in ColdFusion
			  rather than through the servlet.
			  
			  You can specify anything you like as the value for the 
			  redirectHandler as long as it points to a valid URL
			  on the server.
			  
			  A simple implementation of /go.cfm in the webroot would be:
			  
			  <cfimport taglib="/farcry/farcry_core/tags/webskin" prefix="skin" />
			  <skin:fuRedirect>
			  

--->


<!--- Make sure this only gets run once. The code below should prevent a 
second execution, but this should make it a bit more reliable if future
additions change that.
--->
<cfif thisTag.ExecutionMode NEQ 'start'>
	<cfexit method="exittag" />
</cfif>

<!--- Make sure the mappings struct exists --->
<cfparam name="application.fu.mappings" type="struct" default="#structNew()#" />

<!--- The handler to include in the case of a missing mapping. By default a simple not found message is displayed. --->
<cfparam name="attributes.notFoundHandler" default="">

<cfif structKeyExists(application.fu.mappings,cgi.server_name & url.path)>
	<!--- For J2EE systems we need to strip the context root out of the redirect --->
	<cfset cr = getPageContext().getRequest().getContextPath() />
	<cfset redirect = application.fu.mappings[cgi.server_name & url.path] />
	<cfif len(cr) GT 1>
		<cfset redirect = mid(redirect,len(cr)+2,len(redirect)) />
	</cfif>
	<!--- Do a server side redirect to the true URL --->
	<cfset getPageContext().forward(redirect) />
<cfelse>
	<!--- No mapping found... Try to include the not found handler if it exists. --->
	<cfif len(trim(attributes.notFoundHandler))>
		<cftry>
			<cfinclude template="#attributes.notFoundHandler#" />
			<cfabort />
			<cfcatch>
				<!--- do nothing. The output below will handle the problem --->
				<cftrace type="error" text="Not found handler passed to go.cfm caused an exception." />
			</cfcatch>
		</cftry>
	</cfif>
	
	<!--- 
		If we got here, either there wasn't a 404 handler passed as an attribute, or something is wrong with it.
		For now we'll just show a simple message, but this should probably have some FarCry branding added
	 --->
	<cfoutput>
		<h3>Sorry, that page could not be found.</h3>
	</cfoutput>
	<cfabort />
</cfif>