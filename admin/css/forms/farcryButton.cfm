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
</cfoutput>