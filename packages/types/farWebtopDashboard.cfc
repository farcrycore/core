<cfcomponent extends="farcry.core.packages.types.types" displayname="Webtop Dashboard Configuration">

	<cfproperty name="title" type="string" required="false"
		ftSeq="1" ftFieldset="General Details" ftLabel="Title">

	<cfproperty name="aRoles" type="array" required="false"
		ftSeq="2" ftFieldset="General Details" ftLabel="Roles"
		ftType="array" ftJoin="farRole" ftAllowCreate="false"
		ftHint="Select the security roles that will be permitted to see this webtop dashboard">

	<cfproperty name="lCards" type="longchar" required="false"
		ftSeq="3" ftFieldset="General Details" ftLabel="Cards" 
		ftType="list" ftListData="getCards" ftRenderType="checkbox"
		ftHint="Check the boxes to show or hide a card, and drag and drop the list to change the display order">

	<cfproperty name="lRoles" type="longchar" default="" hint="The roles this dashbaord is secured by (list generated automatically)" 
		ftLabel="Roles" ftType="arrayList" ftArrayField="aRoles" ftJoin="farRole">


	<cffunction name="getCards" returntype="query">

		<cfset var qCards = queryNew("value,name")>
		<cfset var iTypename = "">
		<cfset var iWebskin = "">
		<cfset var qWebskins = "">
		<cfset var qDashboardCardWebskins = queryNew("")>
		<cfset var cardDisplayname = "">

		<cfloop collection="#application.stCoapi#" item="iTypename">
			<cfset qWebskins = application.stcoapi[iTypename].qWebskins />

			<cfquery dbtype="query" name="qDashboardCardWebskins">
			SELECT displayname, methodname
			FROM qWebskins
			WHERE lower(qWebskins.name) LIKE 'webtopdashboard%'
			ORDER BY displayname ASC, methodname ASC
			</cfquery>

			<cfloop query="qDashboardCardWebskins">
				<cfset cardDisplayname = qDashboardCardWebskins.methodName>
				<cfif len(qDashboardCardWebskins.displayname)>
					<cfset cardDisplayname = qDashboardCardWebskins.displayname>					
				</cfif>
				<cfset queryAddRow(qCards)>
				<cfset querySetCell(qCards, "value", "#iTypename#:#qDashboardCardWebskins.methodName#")>
				<cfset querySetCell(qCards, "name", cardDisplayname & " (#iTypename#)")>
			</cfloop>

		</cfloop>

		<cfreturn qCards>
	</cffunction>


	<cffunction name="ftEditLCards">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var returnHTML = "">
		<cfset var qCards = getCards()>
		<cfset var qCard = queryNew("")>
		<cfset var lAllCards = valueList(qCards.value)>
		<cfset var lSelectedCards = arguments.stObject.lCards>
		<cfset var item = "">


		<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
		<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
		
		<skin:loadJS id="fc-jquery" />
		<skin:loadJS id="fc-jquery-ui" />
		<skin:loadCSS id="jquery-ui" />
		
		<cfsavecontent variable="returnHTML">	
			<cfoutput>
				<div id="#arguments.fieldname#-library-wrapper">
					<ul id="join-#stObject.objectid#-#arguments.stMetadata.name#" class="arrayDetailView" style="list-style-type:none;border:1px solid ##ebebeb;border-width:1px 1px 0px 1px;margin:0px;">
						<!--- render selected cards --->
						<cfloop list="#lSelectedCards#" index="item">
							<cfquery name="qCard" dbtype="query">
								SELECT *
								FROM qCards
								WHERE [value] = <cfqueryparam cfsqltype="cf_sql_varchar" value="#item#">
							</cfquery>
							<cfif qCard.recordCount>
								<li class="sort" style="border:1px solid ##ebebeb;padding:5px;zoom:1;">
									<table style="width:100%;">
										<tr>
											<td class="" style="cursor:move;padding:3px;"><i class="fa fa-sort"></i></td>
											<td class="" style="cursor:move;padding:3px;">
												<input id="check-#qCard.value#" type="checkbox" value="#qCard.value#" checked="checked">
											</td>
											<td class="" style="cursor:move;width:100%;padding:3px;">
												<label for="check-#qCard.value#" style="display:inline">
												#qCard.name#
												</label>
											</td>
										</tr>
									</table>
								</li>								
							</cfif>
						</cfloop>
						<!--- render all remaining cards --->
						<cfloop query="qCards">
							<cfif NOT listFindNoCase(lSelectedCards, qCards.value)>
								<li class="sort" style="border:1px solid ##ebebeb;padding:5px;zoom:1;">
									<table style="width:100%;">
										<tr>
											<td class="" style="cursor:move;padding:3px;"><i class="fa fa-sort"></i></td>
											<td class="" style="cursor:move;padding:3px;">
												<input id="check-#qCards.value#" type="checkbox" value="#qCards.value#">
											</td>
											<td class="" style="cursor:move;width:100%;padding:3px;">
												<label for="check-#qCards.value#" style="display:inline">
												#qCards.name#
												</label>
											</td>
										</tr>
									</table>
								</li>
							</cfif>
						</cfloop>
					</ul>
				</div>

				<input type="hidden" id="#arguments.fieldname#" name="#arguments.fieldname#" value="#lSelectedCards#">

				<script type="text/javascript">
				$j(function() {

					$j('###arguments.fieldname#-library-wrapper').sortable({
						items: 'li.sort',
						axis: 'y',
						update: function(event,ui){
							updateSelectedCards();
						}
					});

					$j('###arguments.fieldname#-library-wrapper input').on("change", function(){
						updateSelectedCards();
					})

					function updateSelectedCards() {
							var selectedCards = [];
							$j('###arguments.fieldname#-library-wrapper input:checked').each(function(){
								selectedCards.push($j(this).val());
							});
							$j('###arguments.fieldname#').val(selectedCards.join(","));
					}

				});
				</script>
			</cfoutput>

		</cfsavecontent>

		<cfreturn "<div class=""multiField"">#returnHTML#</div>">
	</cffunction>


	<cffunction name="getPermittedWebtopDashboards">
		<cfset var qWebtopDashboards = queryNew("objectid")>
		<cfset var lCurrentRoles = application.security.getCurrentRoles() />

		<cftry>
			<cfif len(lCurrentRoles)>
				<cfquery datasource="#application.dsn#" name="qWebtopDashboards">
					SELECT *
					FROM farWebtopDashboard
					WHERE 
						objectid IN (
							SELECT parentID
							FROM farWebtopDashboard_aRoles
							WHERE data IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#lCurrentRoles#">)
						)
						OR objectid NOT IN (
							SELECT parentID
							FROM farWebtopDashboard_aRoles
						)
				</cfquery>
			</cfif>
			<cfcatch type="any">
			</cfcatch>
		</cftry>

		<cfreturn qWebtopDashboards>
	</cffunction>

	<cffunction name="hasDashboards">
		<cfset var qWebtopDashboards = queryNew("objectid")>
		<cfset var result = 0>

		<cftry>
			<cfquery datasource="#application.dsn#" name="qWebtopDashboards">
			SELECT count(objectid) as counter
			FROM farWebtopDashboard
			</cfquery>
			<cfif qWebtopDashboards.counter GT 0>
				<cfset result = 1>
			</cfif>
			<cfcatch type="any">
			</cfcatch>
		</cftry>

		<cfreturn result>
	</cffunction>

	<cffunction name="dynamicMenu" access="public" output="false" returntype="struct">

		<cfset var stResult = structnew() />
		<cfset var thisitem = "" />
		<cfset var id = "" />
		<cfset var qWebtopDashboards = application.fapi.getContentType("farWebtopDashboard").getPermittedWebtopDashboards() />

		<cfset stResult.children = structnew() />

		<cfif qWebtopDashboards.recordcount>

			<cfloop query="qWebtopDashboards">
				<cfset id = qWebtopDashboards.objectid />

				<cfset stResult.children[id] = structnew() />
				<cfset stResult.children[id].type = "subsection" />
				<cfset stResult.children[id].mergetype = "" />
				<cfset stResult.children[id].sequence = "0" />
				<cfset stResult.children[id].containermanagement = "" />
				<cfset stResult.children[id].icon = "" />
				<cfset stResult.children[id].label = qWebtopDashboards.title />
				<cfset stResult.children[id].rbkey = "dashboard.#id#" />
				<cfset stResult.children[id].children = structnew() />
				<cfset stResult.children[id].id = id />
				<cfset stResult.children[id].labelType = "" />
				<cfset stResult.children[id].relatedType = "" />
				<cfset stResult.children[id].typename = "farWebtopDashboard" />
				<cfset stResult.children[id].bodyView = "webtopBody" />
			</cfloop>

		<cfelse>
			<cfset id = 'Overview' />

			<cfset stResult.children[id] = structnew() />
			<cfset stResult.children[id].type = "subsection" />
			<cfset stResult.children[id].mergetype = "" />
			<cfset stResult.children[id].sequence = "0" />
			<cfset stResult.children[id].containermanagement = "" />
			<cfset stResult.children[id].icon = "" />
			<cfset stResult.children[id].label = application.rb.getResource("webtop.dashboard.webtopdashboard@label","Overview") />
			<cfset stResult.children[id].rbkey = "dashboard.#id#" />
			<cfset stResult.children[id].children = structnew() />
			<cfset stResult.children[id].id = id />
			<cfset stResult.children[id].labelType = "" />
			<cfset stResult.children[id].relatedType = "" />
			<cfset stResult.children[id].typename = "farWebtopDashboard" />
			<cfset stResult.children[id].bodyView = "webtopBody" />
		</cfif>
		<cfreturn stResult />
	</cffunction>


</cfcomponent>