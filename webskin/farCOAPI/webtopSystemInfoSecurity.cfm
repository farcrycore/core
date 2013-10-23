<cfsetting enablecfoutputonly="true">
<!--- @@displayname: Security --->
<!--- @@seq: 300 --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />


<cfset qLogins = application.fapi.getContentObjects(typename="dmProfile",lProperties="objectid,username,firstname,lastname,lastLogin",orderby="lastLogin desc",maxrows="5") />

<ft:field label="Latest Users">
	<cfoutput>
		<table class="table table-striped">
			<tbody>
	</cfoutput>

	<cfoutput query="qLogins">
		<tr>
			<td>
				<cfif len(qLogins.firstname) or len(qLogins.lastname)>
					#qLogins.firstname# #qLogins.lastname# (#qLogins.username#)
				<cfelse>
					Unknown Name (#qLogins.username#)
				</cfif>
			</td>
			<td>
				#lcase(timeformat(qLogins.lastLogin,'hh:mmtt'))#, #dateformat(qLogins.lastLogin,'d mmm yyyy')#
			</td>
		</tr>
	</cfoutput>

	<cfoutput>
			</tbody>
		</table>
	</cfoutput>
</ft:field>

<cfsetting enablecfoutputonly="false">