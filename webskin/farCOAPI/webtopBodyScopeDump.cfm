<cfsetting enablecfoutputonly="true">

<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfparam name="url.var" default="application" />

<skin:loadJS id="fc-jquery" />
<skin:htmlHead><cfoutput>
	<script type="text/javascript">
		$j(function(){
			$j("##filter").bind("keyup",function(){
				$j("table.keys td").removeClass("filtered");
				if (this.value.length)
					$j("table.keys td:contains("+this.value+")").addClass("filtered");
			});
		});
	</script>
	<style type="text/css">
		a.breadcrumb { font-weight:bold; }
		##filter { width:100%; }
		table.keys { width:100%; }
			table.keys td { padding:3px; }
			table.keys td.filtered { font-weight:bold; color:##FFFFFF; background-color:##E17000; }
			table.keys td.filtered a { font-weight:bold; color:##FFFFFF; background-color:##E17000; }
	</style>
</cfoutput></skin:htmlHead>

<cfoutput>
	<h1>Scope Dump</h1>
	<p>
</cfoutput>

<cfset scopes = 'cgi,server,application,session,request' />
<cfset scopes = listdeleteat(scopes,listfindnocase(scopes,listfirst(url.var,'.'))) />
<cfoutput>[ </cfoutput>
<cfloop list="#scopes#" index="thisscope">
	<cfoutput><a href="#application.fapi.fixURL(addvalues='var=#thisscope#')#">#thisscope#</a></cfoutput>
	<cfif thisscope neq listlast(scopes)>
		<cfoutput> | </cfoutput>
	</cfif>
</cfloop>
<cfoutput> ]</cfoutput>

<cfset selectedvar = 0 />
<cfset selectedtype = "N/A" />
<cfset varsofar = "" />
<cfloop list="#url.var#" index="i" delimiters=".">
	<cfset varsofar = listappend(varsofar,i,".") />
	
	<cfif issimplevalue(selectedvar) and selectedvar eq 0 and listfindnocase("cgi,server,application,request,session",i)>
		<cfswitch expression="#i#">
			<cfcase value="cgi">
				<cfset selectedvar = cgi />
			</cfcase>
			<cfcase value="server">
				<cfset selectedvar = server />
			</cfcase>
			<cfcase value="application">
				<cfset selectedvar = application />
			</cfcase>
			<cfcase value="session">
				<cfset selectedvar = session />
			</cfcase>
			<cfcase value="request">
				<cfset selectedvar = request />
			</cfcase>
		</cfswitch>
	<cfelseif isarray(selectedvar)>
		<cfset selectedvar = selectedvar[i] />
	<cfelseif isstruct(selectedvar)>
		<cfset selectedvar = selectedvar[i] />
	<cfelse>
		<cfset selectedvar = "#varsofar# is not valid" />
	</cfif>
	
	<cfif listfindnocase("cgi,server,application,request,session",i)>
		<cfset selectedtype = "SCOPE" />
	<cfelseif isarray(selectedvar)>
		<cfset selectedtype = "ARRAY" />
	<cfelseif isstruct(selectedvar)>
		<cfset selectedtype = "STRUCT" />
	<cfelseif isquery(selectedvar)>
		<cfset selectedtype = "QUERY" />
	<cfelseif isnumeric(selectedvar)>
		<cfset selectedtype = "NUMERIC" />
	<cfelseif lsisdate(selectedvar)>
		<cfset selectedtype = "DATETIME" />
	<cfelse>
		<cfset selectedtype = "STRING" />
	</cfif>
	
	<cfoutput><a class="breadcrumb" href="#application.fapi.fixURL(addvalues="var=#varsofar#")#">#i#</a> #selectedtype# &gt; </cfoutput>
</cfloop>

<cfoutput></p><br></cfoutput>

<cfswitch expression="#selectedtype#">
	<cfcase value="ARRAY">
		<cfif arraylen(selectedvar)>
			<cfset colcount = 10 />
			<cfset rowcount = ceiling(arraylen(selectedvar) / colcount) />
			
			<cfoutput>
				<table class="keys">
			</cfoutput>
			<cfloop from="1" to="#rowcount * colcount#" index="i">
				<cfset x = (i-1) % colcount + 1 />
				<cfset y = ceiling(i / colcount) />
				<cfset ind = y + (x - 1) * rowcount />
				
				<cfif i % colcount eq 1>
					<cfoutput><tr></cfoutput>
				</cfif>
				
				<cfif ind lte arraylen(selectedvar)>
					<cfoutput><td style="width:#round(100/colcount)#%;"><a href="#application.fapi.fixURL(addvalues="var=#varsofar#.#ind#")#">#ind#</a></td></cfoutput>
				<cfelse>
					<cfoutput><td style="width:#round(100/colcount)#%;">&nbsp;</td></cfoutput>
				</cfif>
				
				<cfif i % colcount eq 0>
					<cfoutput></tr></cfoutput>
				</cfif>
			</cfloop>
			<cfoutput></table></cfoutput>
		<cfelse>
			<cfoutput>Array contains no values</cfoutput>
		</cfif>
	</cfcase>
	
	<cfcase value="SCOPE,STRUCT" delimiters=",">
		<cfset keys = listtoarray(listsort(structkeylist(selectedvar),"textnocase")) />
		
		<cfif arraylen(keys)>
			<cfset maxLength = 0 />
			<cfloop array="#keys#" index="i">
				<cfif len(i) gt maxLength>
					<cfset maxLength = len(i) />
				</cfif>
			</cfloop>
			<cfset colcount = round(100/maxLength) />
			<cfset rowcount = ceiling(arraylen(keys) / colcount) />
			
			<cfoutput>
				<table class="keys">
					<tr>
						<td style="width:#round(100/colcount)#%;"><input id="filter" /></td>
						<cfloop from="2" to="#colcount#" index="i">
							<td style="width:#round(100/colcount)#%;">&nbsp;</td>
						</cfloop>
					</tr>
			</cfoutput>
			<cfloop from="1" to="#rowcount * colcount#" index="i">
				<cfset x = (i-1) % colcount + 1 />
				<cfset y = ceiling(i / colcount) />
				<cfset ind = y + (x - 1) * rowcount />
				
				<cfif x eq 1>
					<cfoutput><tr></cfoutput>
				</cfif>
				
				<cfif ind lte arraylen(keys)>
					<cfoutput><td style="width:#round(100/colcount)#%;"><a href="#application.fapi.fixURL(addvalues="var=#varsofar#.#keys[ind]#")#">#keys[ind]#</a></td></cfoutput>
				<cfelse>
					<cfoutput><td style="width:#round(100/colcount)#%;">&nbsp;</td></cfoutput>
				</cfif>
				
				<cfif x eq colcount>
					<cfoutput></tr></cfoutput>
				</cfif>
			</cfloop>
			<cfoutput></table></cfoutput>
		<cfelse>
			<cfoutput>Struct contains no values</cfoutput>
		</cfif>
	</cfcase>
	
	<cfcase value="QUERY">
		
		<cfparam name="form.q" default="" />
		<cfif len(form.q)>
			<cfquery dbtype="query" name="selectedvar">#preservesinglequotes(form.q)#</cfquery>
		</cfif>
		
		<cfoutput>
			<form action="" method="POST">
				<p>Refer to original query as 'selectedvar'</p>
				<textarea name="q" cols="100" rows="2">#form.q#</textarea>
				<input type="submit" value="Filter">
			</form>
			<br>
		</cfoutput>
		
		<cfdump var="#selectedvar#" depth="1" />
		
	</cfcase>
	
	<cfdefaultcase>

		<cfdump var="#selectedvar#" depth="1" />
	
	</cfdefaultcase>
</cfswitch>

<cfsetting enablecfoutputonly="false">