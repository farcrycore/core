<cfimport taglib="/farcry/core/tags/grid" prefix="grid" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />


<skin:loadJS id="fc-jquery" />
<skin:loadJS id="fc-moment" />
<skin:loadJS id="masonry" core="true" bCombine="false" baseHREF="#application.url.webtop#" lFiles="thirdparty/masonry/masonry.pkgd.min.js" />

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


<cfparam name="url.id" default="dashboard.overview" />
<cfset currentWebtopDashboardID = listLast(url.id,".")>

<cfset qPermittedWebtopDashboards = application.fapi.getContentType("farWebtopDashboard").getPermittedWebtopDashboards() />
<cfset aDashboardCardWebskins = arrayNew(1)>


<cfif isValid("uuid", currentWebtopDashboardID) AND listFindNoCase(valueList(qPermittedWebtopDashboards.objectid),currentWebtopDashboardID)>

	<cfset stCurrentDashboard = application.fapi.getContentObject(typename="farWebtopDashboard", objectid="#currentWebtopDashboardID#")>
	
	<cfloop list="#stCurrentDashboard.lCards#" index="iCard">
	
		<cfif application.fapi.checkWebskinPermission(type="#listFirst(iCard,':')#",webskin="#listLast(iCard,':')#")>
			<cfset stDashboardCard = structNew()>
			<cfset stDashboardCard.typename = listFirst(iCard,':')>
			<cfset stDashboardCard.webskin = listLast(iCard,':')>
			<cfset stDashboardCard.displayname = application.stCoapi[stDashboardCard.typename].stWebskins[stDashboardCard.webskin].displayname>
			
			<cfloop list="bAjax:0,cardWidth:auto,cardHeight:auto,cardClass:fc-dashboard-card-medium" index="iCardMetadata">
				<cfif structKeyExists(application.stCoapi[stDashboardCard.typename].stWebskins[stDashboardCard.webskin], listFirst(iCardMetadata,":"))>
					<cfset stDashboardCard[listFirst(iCardMetadata,":")] = application.stCoapi[stDashboardCard.typename].stWebskins[stDashboardCard.webskin][listFirst(iCardMetadata,":")]>
				<cfelse>
					<cfset stDashboardCard[listFirst(iCardMetadata,":")] = listLast(iCardMetadata,":") />
				</cfif>
			</cfloop>
		
			<cfset arrayAppend(aDashboardCardWebskins, stDashboardCard)>

		</cfif>

	</cfloop>
		
<cfelseif currentWebtopDashboardID eq "overview" OR NOT application.fapi.getContentType("farWebtopDashboard").hasDashboards()>

	<cfset qWebskins = application.stcoapi["farCOAPI"].qWebskins />
	<cfquery dbtype="query" name="qCards">
	SELECT *, '' AS typename, 1000 AS seq FROM qWebskins
	WHERE 1=0
	</cfquery>

	<cfloop collection="#application.stCoapi#" item="iTypename">
		<cfset qWebskins = application.stcoapi[iTypename].qWebskins />
		
		<cfquery dbtype="query" name="qTypeCards">
		SELECT *, '#iTypename#' AS typename, 1000 AS seq FROM qWebskins
		WHERE lower(qWebskins.name) LIKE 'webtopdashboard%'
		</cfquery>

		<cfloop query="qTypeCards">
			<cfif structKeyExists(application.stCoapi[qTypeCards.typename].stWebskins[qTypeCards.methodname], "seq")>
				<cfset querySetCell(qTypeCards, "seq", application.stCoapi[qTypeCards.typename].stWebskins[qTypeCards.methodname].seq, qTypeCards.currentRow)>
			</cfif>
		</cfloop>

		<cfquery dbtype="query" name="qCards">
		SELECT * FROM qCards
		UNION
		SELECT * FROM qTypeCards
		</cfquery>

	</cfloop>

	<cfquery dbtype="query" name="qDashboardCardWebskins">
	SELECT * FROM qCards
	ORDER BY seq ASC
	</cfquery>

	<cfoutput query="qDashboardCardWebskins">
		<cfif application.fapi.checkWebskinPermission(type=qDashboardCardWebskins.typename,webskin=qDashboardCardWebskins.methodname)>
			<cfset stDashboardCard = structNew()>
			<cfset stDashboardCard.typename = qDashboardCardWebskins.typename>
			<cfset stDashboardCard.webskin = qDashboardCardWebskins.methodname>
			<cfset stDashboardCard.displayname = application.stCoapi[stDashboardCard.typename].stWebskins[stDashboardCard.webskin].displayname>
			
			<cfloop list="bAjax:0,cardWidth:auto,cardHeight:auto,cardClass:fc-dashboard-card-medium" index="iCardMetadata">
				<cfif structKeyExists(application.stCoapi[stDashboardCard.typename].stWebskins[stDashboardCard.webskin], listFirst(iCardMetadata,":"))>
					<cfset stDashboardCard[listFirst(iCardMetadata,":")] = application.stCoapi[stDashboardCard.typename].stWebskins[stDashboardCard.webskin][listFirst(iCardMetadata,":")]>
				<cfelse>
					<cfset stDashboardCard[listFirst(iCardMetadata,":")] = listLast(iCardMetadata,":") />
				</cfif>
			</cfloop>
			
			<cfset arrayAppend(aDashboardCardWebskins, stDashboardCard)>

		</cfif>
	</cfoutput>
		
	
</cfif>


<!--- output dashboard cards --->

<cfif arrayLen(aDashboardCardWebskins)>

	<skin:loadCSS>
	<cfoutput>
	.farcry-main {
		border: none;
		background: none;
		padding: 12px;
	}
	##card-container {
		max-width: 954px;
		margin-left: auto;
		margin-right: auto;
	}
	</cfoutput>
	</skin:loadCSS>

	<grid:div id="card-container">
		<cfloop from="1" to="#arrayLen(aDashboardCardWebskins)#" index="i">

			<grid:div id="card-#i#" class="dashboard-card #aDashboardCardWebskins[i].cardClass#" style="height:#aDashboardCardWebskins[i].cardHeight#;min-height:#aDashboardCardWebskins[i].cardHeight#;">
				<grid:div id="card-#i#-inner" class="dashboard-card-inner clearfix">
					<skin:view typename="#aDashboardCardWebskins[i].typename#" webskin="#aDashboardCardWebskins[i].webskin#"  bAjax="#aDashboardCardWebskins[i].bAjax#" ajaxShowloadIndicator="true" ajaxindicatorText="Loading #aDashboardCardWebskins[i].displayName#...">
				</grid:div>
				<cfoutput>
					<div id="card-#i#-toggle" class="dashboard-card-toggle">
						<a id="card-#i#-show-more" href="##" class="card-show-more" onclick="return moreDashboardCard('card-#i#');"><i class="fa fa-caret-down"></i></a>
						<a id="card-#i#-show-less" href="##" class="card-show-less" style="display:none;" onclick="return lessDashboardCard('card-#i#');"><i class="fa fa-caret-up"></i></a>
					</div>
				</cfoutput>
			</grid:div>

		</cfloop>
	</grid:div>

	<skin:onReady>
	<cfoutput>
		initDashboardCardToggle();
		
	 	$container = $j('##card-container');
		$container.masonry({
			columnWidth: 232,
			gutter: 8,
			itemSelector: ".dashboard-card"
		});

	</cfoutput>
	</skin:onReady>

<cfelse>
	<cfoutput><h1><i class="fa fa-exclamation-circle"></i> Dashboard not found</h1></cfoutput>
</cfif>

