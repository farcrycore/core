<cfoutput>
	div.farcryButtonWrap-outer{
		background:transparent url(#application.url.farcry#/css/forms/images/farcryButtonSprite-left.gif) no-repeat top left;
		border:0px;
		padding:0px 15px 0px 0px;
		margin:0px 0px 0px 0px;
		height:21px;
		float:left;
		
	}
	div.farcryButtonWrap-inner{
		background:transparent url(#application.url.farcry#/css/forms/images/farcryButtonSprite-right.gif) no-repeat top right;
		border:0px solid green;
		padding:0px 3px 0px 0px;
		margin:0px 0px 0px 3px;
		float:none;
	}	
	
	button.farcryButton{
		border:0px solid red;
		padding:0px 0px 0px 0px;
		margin:0px 0px 0px 0px;
		vertical-align:middle;					
		background:transparent;
		background-image:none;
		height:21px;
		width:auto;
		text-align:center;
		overflow:hidden;
		font-size:11px;
	}			
	div.farcryButtonWrap-outer-hover{
		background-position: bottom left;					
	}
	div.farcryButtonWrap-inner-hover{
		background-position: center right;
	}
	div.farcryButtonWrap-outer-click{
		background-position: bottom left;					
	}
	div.farcryButtonWrap-inner-click{
		background-position: bottom right;
	}
	
	
.f-btn{
	font:normal 11px tahoma, verdana, helvetica;
	cursor:pointer;
	white-space: nowrap;
	margin:5px;
	float:left;
	border:none;
}
.f-btn button{
    border:0 none;
    background-color:transparent;
    font:normal 11px tahoma,verdana,helvetica;
    padding-left:3px;
    padding-right:3px;
    cursor:pointer;
    margin:0;
    overflow:visible;
    width:auto;
    -moz-outline:0 none;
    outline:0 none;
    color:##333;
}


.f-btn .f-btn-bg {
	background-color:transparent;
	background-image: url(#application.url.webtop#/css/forms/images/f-btn-blue.gif);
	padding:0 !important;
	border:none !important;
}

body.ext-gecko .f-btn button {
    padding-left:0;
    padding-right:0;
}
body.ext-ie6 .f-btn button {
	width:1px;
    padding-top:2px;
}
body.ext-opera .f-btn button {
    padding-left:4px;
    padding-right:4px;
}
 body.ext-opera .f-btn-small button {
    padding-top:2px;
}
 body.ext-opera .f-btn-medium button {
    padding-top:5px;
}
body.ext-opera .f-btn-large button {
    padding-top:9px;
}
.f-btn em {
    font-style:normal;
    font-weight:normal;
}
.f-btn-text {
    cursor:pointer;
	white-space: nowrap;
    padding:0;
}
.f-btn-noicon .f-btn-small .f-btn-text{
	height: 16px;
}
.f-btn-noicon .f-btn-medium .f-btn-text{
    height: 24px;
}
.f-btn-noicon .f-btn-large .f-btn-text{
    height: 32px;
}
.f-btn-icon .f-btn-text{
    background-position: center;
	background-repeat: no-repeat;
}
.f-btn-icon .f-btn-small .f-btn-text{
	height: 16px;
	width: 16px;
}
.f-btn-icon .f-btn-medium .f-btn-text{
    height: 24px;
	width: 24px;
}
.f-btn-icon .f-btn-large .f-btn-text{
    height: 32px;
	width: 32px;
}
.f-btn-text-icon .f-btn-icon-small-left .f-btn-text{
    background-position: 0 center;
	background-repeat: no-repeat;
    padding-left:18px;
    height:16px;
}
.f-btn-text-icon .f-btn-icon-medium-left .f-btn-text{
    background-position: 0 center;
	background-repeat: no-repeat;
    padding-left:26px;
    height:24px;
}
.f-btn-text-icon .f-btn-icon-large-left .f-btn-text{
    background-position: 0 center;
	background-repeat: no-repeat;
    padding-left:34px;
    height:32px;
}
.f-btn-text-icon .f-btn-icon-small-top .f-btn-text{
    background-position: center 0;
	background-repeat: no-repeat;
    padding-top:18px;
}
.f-btn-text-icon .f-btn-icon-medium-top .f-btn-text{
    background-position: center 0;
	background-repeat: no-repeat;
    padding-top:26px;
}
.f-btn-text-icon .f-btn-icon-large-top .f-btn-text{
    background-position: center 0;
	background-repeat: no-repeat;
    padding-top:34px;
}
.f-btn-text-icon .f-btn-icon-small-right .f-btn-text{
    background-position: right center;
	background-repeat: no-repeat;
    padding-right:18px;
    height:16px;
}
.f-btn-text-icon .f-btn-icon-medium-right .f-btn-text{
    background-position: right center;
	background-repeat: no-repeat;
    padding-right:26px;
    height:24px;
}
.f-btn-text-icon .f-btn-icon-large-right .f-btn-text{
    background-position: right center;
	background-repeat: no-repeat;
    padding-right:34px;
    height:32px;
}
.f-btn-text-icon .f-btn-icon-small-bottom .f-btn-text{
    background-position: center bottom;
	background-repeat: no-repeat;
    padding-bottom:18px;
}
.f-btn-text-icon .f-btn-icon-medium-bottom .f-btn-text{
    background-position: center bottom;
	background-repeat: no-repeat;
    padding-bottom:26px;
}
.f-btn-text-icon .f-btn-icon-large-bottom .f-btn-text{
    background-position: center bottom;
	background-repeat: no-repeat;
    padding-bottom:34px;
}
.f-btn-tr i, .f-btn-tl i, .f-btn-mr i, .f-btn-ml i, .f-btn-br i, .f-btn-bl i{
	font-size:1px;
    line-height:1px;
    width:3px;
    display:block;
    overflow:hidden;
}
.f-btn-tr i, .f-btn-tl i, .f-btn-br i, .f-btn-bl i{
	height:3px;
}
.f-btn .f-btn-tl{
	width:3px;
	height:3px;
	background-repeat:no-repeat;
	background-position: 0 0;
}
.f-btn .f-btn-tr{
	width:3px;
	height:3px;
	background-repeat:no-repeat;
	background-position: -3px 0;
}
.f-btn .f-btn-tc{
	height:3px;
	background-repeat: repeat-x;
	background-position: 0 -6px;
}
.f-btn .f-btn-ml{
	width:3px;
	background-repeat:no-repeat;
	background-position: 0 -24px;
}
.f-btn .f-btn-mr{
	width:3px;
	background-repeat:no-repeat;
	background-position: -3px -24px;
}
.f-btn .f-btn-mc{
	background-repeat:repeat-x;
	background-position: 0 -96px;
    vertical-align: middle;
	text-align:center;
	padding:0 5px;
	cursor:pointer;
	white-space:nowrap;
}
.f-btn .f-btn-bl{
	width:3px;
	height:3px;
	background-repeat:no-repeat;
	background-position:0 -3px;
}
.f-btn .f-btn-br{
	width:3px;
	height:3px;
	background-repeat:no-repeat;
	background-position: -3px -3px;
}
.f-btn .f-btn-bc{
	height:3px;
	background-repeat:repeat-x;
	background-position: 0 -15px;
}
.f-btn-over .f-btn-tl{
	background-position: -6px 0;
}
.f-btn-over .f-btn-tr{
	background-position: -9px 0;
}
.f-btn-over .f-btn-tc{
	background-position: 0 -9px;
}
.f-btn-over .f-btn-ml{
	background-position: -6px -24px;
}
.f-btn-over .f-btn-mr{
	background-position: -9px -24px;
}
.f-btn-over .f-btn-mc{
	background-position: 0 -168px;
}
.f-btn-over .f-btn-bl{
	background-position: -6px -3px;
}
.f-btn-over .f-btn-br{
	background-position: -9px -3px;
}
.f-btn-over .f-btn-bc{
	background-position: 0 -18px;
}
.f-btn-click .f-btn-tl, .f-btn-menu-active .f-btn-tl, .f-btn-pressed .f-btn-tl{
	background-position: -12px 0;
}
.f-btn-click .f-btn-tr, .f-btn-menu-active .f-btn-tr, .f-btn-pressed .f-btn-tr{
	background-position: -15px 0;
}
.f-btn-click .f-btn-tc, .f-btn-menu-active .f-btn-tc, .f-btn-pressed .f-btn-tc{
	background-position: 0 -12px;
}

.f-btn-click .f-btn-ml, .f-btn-menu-active .f-btn-ml, .f-btn-pressed .f-btn-ml{
	background-position: -12px -24px;
}
.f-btn-click .f-btn-mr, .f-btn-menu-active .f-btn-mr, .f-btn-pressed .f-btn-mr{
	background-position: -15px -24px;
}
.f-btn-click .f-btn-mc, .f-btn-menu-active .f-btn-mc, .f-btn-pressed .f-btn-mc{
	background-position: 0 -240px;
}
.f-btn-click .f-btn-bl, .f-btn-menu-active .f-btn-bl, .f-btn-pressed .f-btn-bl{
	background-position: -12px -3px;
}
.f-btn-click .f-btn-br, .f-btn-menu-active .f-btn-br, .f-btn-pressed .f-btn-br{
	background-position: -15px -3px;
}
.f-btn-click .f-btn-bc, .f-btn-menu-active .f-btn-bc, .f-btn-pressed .f-btn-bc{
	background-position: 0 -21px;
}
.f-btn-disabled *{
	color:gray !important;
	cursor:default !important;
}	
	
</cfoutput>