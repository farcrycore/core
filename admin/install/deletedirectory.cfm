<!--- 
	Program: deletedirectory.cfm
	Programmer: Jijo Jacob Palayoor
	Date : 8/15/02
	
	Copywrite : 1Global City, Inc 2001
	All rights Reserved
	
	Description:	Recursive Procedure to Delete a Directory with all its file 
	and any deeper subdirectory levels
		
	
	Usage
	-----
	Call this file with a complete directory name and will delete all the subdirectories 
	and files present on it (Until unless its a read only).	
	
	Emaple of calling this 
	----------------------
	<cf_deletedirectory directory="c:\yourdirectory">
		
						
	Change History
	
	Who				when			what
	---				----			----


--->  


<cfparam name="Attributes.directory">

<!--- Main Directory --->
<cftry>

	<CFDIRECTORY NAME ="MainDirectory" DIRECTORY="#Attributes.directory#">
	<cfoutput query="MainDirectory" >
	
		<!--- If its a Diretoory Under main Diretory --->
		<cfif directoryExists("#Attributes.directory#/#MainDirectory.Name#") AND MainDirectory.Name NEQ "." and MainDirectory.Name NEQ "..">
						
			<cf_deletedirectory directory="#Attributes.directory#/#MainDirectory.Name#">
			
			<cfif directoryExists("#Attributes.directory#/#MainDirectory.Name#")>
				<cfdirectory action="DELETE" directory="#Attributes.directory#/#MainDirectory.Name#">	
			</cfif>
						
		<cfelse>  <!--- No Directory Under Main Diretory , its File Delete it --->
	
				<cfif MainDirectory.Name neq "." and MainDirectory.Name neq "..">
					<cffile action="DELETE" file="#Attributes.directory#/#MainDirectory.Name#">
				</cfif>
		
		</cfif>
		
	</cfoutput>

	<cfif DirectoryExists("#Attributes.directory#/#MainDirectory.Name#")>
		<cfdirectory action="DELETE" directory="#Attributes.directory#/#MainDirectory.Name#">	
	</cfif> 
	
    <cfdirectory action="DELETE" directory="#Attributes.directory#">

	<cfcatch>
    <cfdump var="#cfcatch#">
	</cfcatch>
</cftry>