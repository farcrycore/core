
<cfif thistag.executionMode eq "End">
	<!--- Do Nothing --->
</cfif>

<cfif thistag.executionMode eq "Start">
	
	
	<cfparam name="request.inHead.aCSSLibraries" default="#arrayNew(1)#" />
	<cfparam name="request.inHead.stCSSLibraries" default="#structNew()#" />
	

	<cfloop from="1" to="#arrayLen(request.inHead.aCSSLibraries)#" index="i">
		<cfset stCSS = duplicate(request.inHead.stCSSLibraries[request.inHead.aCSSLibraries[i]]) />
		
		<cfset stCSS.path = replaceNoCase(stCSS.path,"\","/","all") /><!--- Change back slashes --->
		<cfif len(stCSS.path) AND right(stCSS.path,1) EQ "/">
			<cfset stCSS.path = mid(stCSS.path,1,len(stCSS.path)-1) /><!--- Remove trailing slash --->
		</cfif>
		
		
		<cfset stCSS.lFiles = replaceNoCase(stCSS.lFiles,"\","/","all") /><!--- Change back slashes --->

	</cfloop>
	
	<cfset stCSS.aFiles = arrayNew(1) />
	
	<cfloop list="#stCSS.lFiles#" index="i">
		<cfif left(i,1) NEQ "/">
			<cfset i = "/#i#" /><!--- add slash --->
		</cfif>
		<cfset arrayAppend(stCSS.aFiles, i) />
	</cfloop>
	
	<cfloop from="1" to="#arrayLen(stCSS.aFiles)#" index="i">
		<cfset filePath = "#stCSS.path##stCSS.aFiles[i]#">
		<cfif fileExists(expandPath(filePath))>
			<cffile action="read" file="#expandPath(filePath)#" variable="sCSS" />
			
			<cfset fileDir = application.factory.oUtils.listSlice(filePath,1,-2,"/") />
			
			<!--------------------------------------- 
			START: REPLACE REQUIRED PATHS IN THE CSS
			 --------------------------------------->		

			<cfset start = findNoCase("url(",sCSS) />
			
			<cfloop condition="start GT 0">
				
				
				<cfset nextCharPos = 4>
				<cfset nextChar = mid(sCSS,start+4,1) />
				
				<cfif nextChar EQ '"'>
					<cfset nextCharPos = 5>
				</cfif>		
				
				<cfif nextChar EQ "'">
					<cfset nextCharPos = 5>
				</cfif>
				
				<cfset nextChar = mid(sCSS,start+nextCharPos,1) />
				
				<cfif nextChar NEQ "/">		
					<cfset sCSS = insert("#fileDir#/",sCSS,start+nextCharPos-1)>					
				</cfif>
				
				<cfset start = findNoCase("url(", sCSS, start+nextCharPos) />	
				
			</cfloop>	
			
			<!--------------------------------------- 
			END: REPLACE REQUIRED PATHS IN THE CSS
			 --------------------------------------->		
		 
			
		<cfelse>
			<cfabort showerror="File Does not Exist (#filePath#)" />
		</cfif>
	</cfloop>
	

		
		
	<cfdump var="#request.inHead#" expand="false" label="request.inHead" />
	<cfabort showerror="debugging" />
</cfif>