<cfimport taglib="/farcry/core/tags/grid" prefix="grid" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />


<skin:loadJS id="fc-jquery" />
<skin:loadJS id="fc-moment" />
<skin:loadJS id="masonry" core="true" lFiles="#application.url.webtop#/thirdparty/masonry/masonry.pkgd.min.js" />

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
.farcry-main {
	border: none;
	background: none;
	padding: 12px;
}
##card-container {
	max-width: 980px;
	margin-left: auto;
	margin-right: auto;
}

.dashboard-card {
	min-height: 200px;
	border: 1px solid ##ddd;
	background: white;
	margin-bottom: 8px;
	box-shadow: 0 0 2px rgba(0,0,0,0.05);
}

.dashboard-card-inner {
	padding: 10px;
}

.dashboard-card-toggle a {
	opacity:0.2;
	filter:alpha(opacity=20);
	color:##0E65A2;
}
.dashboard-card-toggle a:hover {
	opacity:1;
	filter:alpha(opacity=100);
}

.fc-dashboard-card-small {
	width: 230px;
}
.fc-dashboard-card-medium {
	width: 470px;
}
.fc-dashboard-card-large {
	width: 710px;
}
.fc-dashboard-card-xlarge {
	width: 950px;
}

@media (max-width: 767px) {
	.fc-dashboard-card-small,
	.fc-dashboard-card-medium,
	.fc-dashboard-card-large,
	.fc-dashboard-card-xlarge {
		width: 100%;
	}

}


</cfoutput>
</skin:loadCSS>


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
		
	</cfloop>
	
</cfif>


<!--- output dashboard cards --->

<cfif arrayLen(aDashboardCardWebskins)>
	<grid:div id="card-container">
		<cfloop from="1" to="#arrayLen(aDashboardCardWebskins)#" index="i">

			<grid:div id="card-#i#" class="dashboard-card #aDashboardCardWebskins[i].cardClass#" style="position:relative;padding:0px;height:#aDashboardCardWebskins[i].cardHeight#;overflow:hidden;"><!---  --->
				<grid:div id="card-#i#-inner" class="dashboard-card-inner clearfix">
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
	<cfoutput><h1>Welcome to FarCry</h1></cfoutput>
</cfif>

<skin:onReady>
<cfoutput>
	initDashboardCardToggle();
	
 	$container = $j('##card-container');
	// initialize
	$container.masonry({
	  "gutter": 8,
	  "itemSelector": '.dashboard-card'
	});


</cfoutput>
</skin:onReady>

