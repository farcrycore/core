
<cfimport taglib="/farcry/core/tags/grid" prefix="grid" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="../../tags" prefix="toro" />


<skin:loadJS id="jquery" />
<skin:loadJS id="masonry" lFiles="#application.url.webtop#/thirdparty/masonry/masonry.pkgd.min.js" />

<skin:loadJS>
<cfoutput>
function initDashboardCardToggle() {
	$j.each( $j('.dashboard-card') , function( index, value ) {
		var cardID = $j(this).attr('id');
		var $card = $j('##' + cardID);
		var $cardInner = $j('##' + cardID + '-inner');
		var $cardToggle = $j('##' + cardID + '-toggle');
		var offset = $card.offset();

		if( $cardInner.outerHeight() > $card.innerHeight() ) {
			console.log(cardID, $cardInner.outerHeight() , $card.innerHeight());
			$cardToggle.show();
		}
	});
}
function moreDashboardCard(cardID) {
	var $card = $j('##' + cardID);
	var $cardInner = $j('##' + cardID + '-inner');
	var $cardToggle = $j('##' + cardID + '-toggle');
	var $cardShowMore = $j('##' + cardID + '-show-more');
	var $cardShowLess = $j('##' + cardID + '-show-less');

	$card.css('height','auto');
	$cardShowMore.hide();
	$cardShowLess.show();
	$container.masonry();
	return false;
}
function lessDashboardCard(cardID) {
	var $card = $j('##' + cardID);
	var $cardInner = $j('##' + cardID + '-inner');
	var $cardToggle = $j('##' + cardID + '-toggle');
	var $cardShowMore = $j('##' + cardID + '-show-more');
	var $cardShowLess = $j('##' + cardID + '-show-less');
	
	$card.css('height','100px');
	$cardShowMore.show();
	$cardShowLess.hide();
	$container.masonry();
	return false;
}
</cfoutput>
</skin:loadJS>

<skin:loadCSS>
<cfoutput>
.dashboard-card-toggle a {
	opacity:0.2;
	filter:alpha(opacity=20);
	color:##0E65A2;
}
.dashboard-card-toggle a:hover {
	opacity:1;
	filter:alpha(opacity=100);
}
</cfoutput>
</skin:loadCSS>


<cfset qPermittedWebtopDashboards = application.fapi.getContentType("farWebtopDashboard").getPermittedWebtopDashboards() />
<!--- 
<cfparam name="session.webtopDashboardID" default="">

<ft:processForm action="Change Dashboard" url="refresh">
	<cfset session.webtopDashboardID = form.selectedObjectID>
</ft:processForm> --->

<cfparam name="url.id" default="dashboard.overview" />

<cfset currentWebtopDashboardID = listLast(url.id,".")>


<ft:form>



<cfset aDashboardCardWebskins = arrayNew(1)>



<cfif isValid("uuid", currentWebtopDashboardID) AND listFindNoCase(valueList(qPermittedWebtopDashboards.objectid),currentWebtopDashboardID)>
	<cfset stCurrentDashboard = application.fapi.getContentObject(typename="farWebtopDashboard", objectid="#currentWebtopDashboardID#")>
	

	
	<!--- <cfdump var="#qPermittedWebtopDashboards#"> --->
<!--- 
	<cfif qPermittedWebtopDashboards.recordCount GT 1>
		<cfoutput>
		<div class="farcry-button-bar btn-group pull-left" style="margin-bottom: 5px">
		<div class="btn-group">
			<button data-toggle="dropdown" class="btn btn-group dropdown-toggle" type="button"><i class="fa fa-tachometer fa-2x"></i> Select Dashboard: #stCurrentDashboard.title#</button>
			<ul class="dropdown-menu">
				<cfloop query="qPermittedWebtopDashboards">
				<li>
					<ft:button 
						value="Change Dashboard" 
						text="#qPermittedWebtopDashboards.title#"
						selectedObjectID="#qPermittedWebtopDashboards.objectid#"
						validate="false" 
						renderType="link" /> 
					<!--- <a href="##" class="" onclick="$selectedObjectID('#qPermittedWebtopDashboards.objectid#'); btnSubmit('#request.farcryform.name#','Change Dashboard'); return false;"><i class="fa fa-tachometer fa-fw"></i> #qPermittedWebtopDashboards.title#</a> --->
				</li>
				</cfloop>
			</ul>
		</div>
	</div>

		</cfoutput>
	</cfif> --->
	
	<cfloop list="#stCurrentDashboard.lCards#" index="iCard">
	
		<cfif application.fapi.checkWebskinPermission(type="#listFirst(iCard,':')#",webskin="#listLast(iCard,':')#")>
			<cfset stDashboardCard = structNew()>
			<cfset stDashboardCard.typename = listFirst(iCard,':')>
			<cfset stDashboardCard.webskin = listLast(iCard,':')>
			<cfset stDashboardCard.displayname = application.stCoapi[stDashboardCard.typename].stWebskins[stDashboardCard.webskin].displayname>
			
			<cfloop list="bAjax:0,cardWidth:auto,cardHeight:auto" index="iCardMetadata">
				<cfif structKeyExists(application.stCoapi[stDashboardCard.typename].stWebskins[stDashboardCard.webskin], listFirst(iCardMetadata,":"))>
					<cfset stDashboardCard[listFirst(iCardMetadata,":")] = application.stCoapi[stDashboardCard.typename].stWebskins[stDashboardCard.webskin][listFirst(iCardMetadata,":")]>
				<cfelse>
					<cfset stDashboardCard[listFirst(iCardMetadata,":")] = listLast(iCardMetadata,":") />
				</cfif>
			</cfloop>
		
			<cfset arrayAppend(aDashboardCardWebskins, stDashboardCard)>

		</cfif>

	</cfloop>
		
<cfelseif NOT application.fapi.getContentType("farWebtopDashboard").hasDashboards()>

	<cfloop collection="#application.stCoapi#" item="iTypename">
		<cfset qWebskins = application.stcoapi[iTypename].qWebskins />
		
		<cfquery dbtype="query" name="qDashboardCardWebskins">
		SELECT * FROM qWebskins
		WHERE lower(qWebskins.name) LIKE 'webtopdashboard%'
		</cfquery>
	
		<cfoutput query="qDashboardCardWebskins">
			<cfif application.fapi.checkWebskinPermission(type="#iTypename#",webskin="#qDashboardCardWebskins.methodname#")>
				<cfset stDashboardCard = structNew()>
				<cfset stDashboardCard.typename = iTypename>
				<cfset stDashboardCard.webskin = qDashboardCardWebskins.methodname>
				<cfset stDashboardCard.displayname = application.stCoapi[stDashboardCard.typename].stWebskins[stDashboardCard.webskin].displayname>
				
				<cfloop list="bAjax:0,cardHeight:auto,cardClass:fc-card-medium" index="iCardMetadata">
					<cfif structKeyExists(application.stCoapi[stDashboardCard.typename].stWebskins[stDashboardCard.webskin], listFirst(iCardMetadata,":"))>
						<cfset stDashboardCard[listFirst(iCardMetadata,":")] = application.stCoapi[stDashboardCard.typename].stWebskins[stDashboardCard.webskin][listFirst(iCardMetadata,":")]>
					<cfelse>
						<cfset stDashboardCard[listFirst(iCardMetadata,":")] = listLast(iCardMetadata,":") />
					</cfif>
				</cfloop>
				
				<cfset arrayAppend(aDashboardCardWebskins, stDashboardCard)>
	
			</cfif>
		</cfoutput>
		
	</cfloop>
	
</cfif>

<!--- 300,620,940,1260 --->
<cfif arrayLen(aDashboardCardWebskins)>
		<grid:div id="card-container">
			<cfloop from="1" to="#arrayLen(aDashboardCardWebskins)#" index="i">

				<grid:div id="card-#i#" class="dashboard-card well" style="position:relative;padding:0px;height:100px;width:620px;overflow:hidden;"><!--- #aDashboardCardWebskins[i].cardHeight# --->
					<grid:div id="card-#i#-inner" class="dashboard-card-inner clearfix" style="padding:10px;">
						<skin:view typename="#aDashboardCardWebskins[i].typename#" webskin="#aDashboardCardWebskins[i].webskin#"  bAjax="#aDashboardCardWebskins[i].bAjax#" ajaxShowloadIndicator="true" ajaxindicatorText="Loading #aDashboardCardWebskins[i].displayName#...">
					</grid:div>

					<cfoutput>
					<div id="card-#i#-toggle" class="dashboard-card-toggle" style="position:absolute;bottom:0px;display:none;width:100%;text-align:center;">
						<a id="card-#i#-show-more" href="##" class="card-show-more" onclick="return moreDashboardCard('card-#i#');"><i class="fa fa-caret-square-o-down fa-2x"></i></a>
						<a id="card-#i#-show-less" href="##" class="card-show-less" style="display:none;" onclick="return lessDashboardCard('card-#i#');"><i class="fa fa-caret-square-o-up fa-2x"></i></a>
					</div>
					</cfoutput>


				</grid:div>



				

			</cfloop>
		</grid:div>
<cfelse>
	<cfoutput><h1>WELCOME TO FARCRY</h1></cfoutput>
</cfif>

<skin:onReady>
<cfoutput>
	initDashboardCardToggle();
	
 	$container = $j('##card-container');
		// initialize
		$container.masonry({
		  columnWidth: 50,
		  itemSelector: '.dashboard-card'
		});


</cfoutput>
</skin:onReady>


</ft:form>