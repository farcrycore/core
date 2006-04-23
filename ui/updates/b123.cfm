<!--- @@description:
Deploys new Stats Countries Table
--->
<html>
<head>
<title>Farcry Core b123 Update: <cfoutput>#application.applicationname#</cfoutput></title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="<cfoutput>#application.url.farcry#</cfoutput>/css/admin.css" rel="stylesheet" type="text/css">
</head>

<body style="margin-left:20px;margin-top:20px;">

<cfif isdefined("form.submit")>
	<cfset error = 0>
	<!--- add statsCountries table --->
	<cftry>
		<cfswitch expression="#application.dbtype#">
			<cfcase value="ora">
				<cfquery name="update" datasource="#application.dsn#">
					create table #application.dbowner#statsCountries (
						COUNTRY VARCHAR2(255) NOT NULL,
						ISOCODE CHAR (2) NOT NULL
					)
				</cfquery>
			</cfcase>
			
			<cfcase value="mysql">
				<cfquery name="update" datasource="#application.dsn#">
					create table #application.dbowner#statsCountries (
						COUNTRY VARCHAR(255) NOT NULL,
						ISOCODE CHAR (2) NOT NULL
					)
				</cfquery>
			</cfcase>
			
			<cfdefaultcase>
				<cfquery name="update" datasource="#application.dsn#">
					CREATE TABLE #application.dbowner#statsCountries (
						[Country] [varchar] (250) NOT NULL ,
						[ISOCode] [char] (2) NOT NULL 
					) 
				</cfquery>
			</cfdefaultcase>
		</cfswitch>
		
		<cfcatch><cfset error=1><cfoutput><span class="frameMenuBullet">&raquo;</span> <span class="error"><cfdump var="#cfcatch.detail#"></span><p></p></cfoutput></cfcatch>
	</cftry>
	
	<!--- add country code data --->
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('AFGHANISTAN ','AF')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('ALBANIA','AL')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('ALGERIA','DZ')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('AMERICAN SAMOA','AS')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('ANDORRA','AD')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('ANGOLA','AO')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('ANGUILLA','AI')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('ANTARCTICA','AQ')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('ANTIGUA AND BARBUDA','AG')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('ARGENTINA','AR')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('ARMENIA','AM')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('ARUBA','AW')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('AUSTRALIA','AU')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('AUSTRIA','AT')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('AZERBAIJAN','AZ')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('BAHAMAS','BS')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('BAHRAIN','BH')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('BANGLADESH','BD')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('BARBADOS','BB')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('BELARUS','BY')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('BELGIUM','BE')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('BELIZE','BZ')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('BENIN','BJ')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('BERMUDA','BM')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('BHUTAN','BT')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('BOLIVIA','BO')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('BOSNIA AND HERZEGOVINA','BA')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('BOTSWANA','BW')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('BOUVET ISLAND','BV')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('BRAZIL','BR')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('BRITISH INDIAN OCEAN TERRITORY','IO')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('BRUNEI DARUSSALAM','BN')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('BULGARIA','BG')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('BURKINA FASO','BF')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('BURUNDI','BI')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('CAMBODIA','KH')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('CAMEROON','CM')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('CANADA','CA')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('CAPE VERDE','CV')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('CAYMAN ISLANDS','KY')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('CENTRAL AFRICAN REPUBLIC','CF')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('CHAD','TD')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('CHILE','CL')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('CHINA','CN')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('CHRISTMAS ISLAND','CX')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('COCOS (KEELING) ISLANDS','CC')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('COLOMBIA','CO')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('COMOROS','KM')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('CONGO','CG')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('CONGO, THE DEMOCRATIC REPUBLIC OF THE','CD')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('COOK ISLANDS','CK')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('COSTA RICA','CR')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('CÔTE D''IVOIRE','CI')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('CROATIA','HR')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('CUBA','CU')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('CYPRUS','CY')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('CZECH REPUBLIC','CZ')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('DENMARK','DK')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('DJIBOUTI','DJ')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('DOMINICA','DM')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('DOMINICAN REPUBLIC','DO')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('ECUADOR','EC')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('EGYPT','EG')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('EL SALVADOR','SV')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('EQUATORIAL GUINEA','GQ')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('ERITREA','ER')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('ESTONIA','EE')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('ETHIOPIA','ET')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('FALKLAND ISLANDS (MALVINAS)','FK')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('FAROE ISLANDS','FO')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('FIJI','FJ')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('FINLAND','FI')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('FRANCE','FR')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('FRENCH GUIANA','GF')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('FRENCH POLYNESIA','PF')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('FRENCH SOUTHERN TERRITORIES','TF')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('GABON ','GA')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('GAMBIA','GM')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('GEORGIA','GE')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('GERMANY','DE')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('GHANA','GH')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('GIBRALTAR','GI')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('GREECE','GR')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('GREENLAND','GL')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('GRENADA','GD')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('GUADELOUPE','GP')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('GUAM','GU')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('GUATEMALA','GT')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('GUINEA','GN')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('GUINEA-BISSAU','GW')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('GUYANA','GY')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('HAITI','HT')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('HEARD ISLAND AND MCDONALD ISLANDS','HM')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('VATICAN CITY STATE','VA')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('HONDURAS','HN')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('HONG KONG','HK')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('HUNGARY','HU')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('ICELAND','IS')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('INDIA','IN')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('INDONESIA','ID')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('IRAN, ISLAMIC REPUBLIC OF','IR')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('IRAQ','IQ')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('IRELAND','IE')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('ISRAEL','IL')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('ITALY','IT')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('JAMAICA','JM')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('JAPAN','JP')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('JORDAN','JO')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('KAZAKHSTAN','KZ')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('KENYA','KE')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('KIRIBATI','KI')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('KOREA, DEMOCRATIC PEOPLE''S REPUBLIC OF','KP')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('KOREA, REPUBLIC OF','KR')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('KUWAIT','KW')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('KYRGYZSTAN','KG')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('LAO PEOPLE''S DEMOCRATIC REPUBLIC','LA')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('LATVIA','LV')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('LEBANON','LB')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('LESOTHO','LS')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('LIBERIA','LR')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('LIBYAN ARAB JAMAHIRIYA','LY')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('LIECHTENSTEIN','LI')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('LITHUANIA','LT')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('LUXEMBOURG','LU')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('MACAO','MO')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('MACEDONIA, THE FORMER YUGOSLAV REPUBLIC OF','MK')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('MADAGASCAR','MG')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('MALAWI','MW')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('MALAYSIA','MY')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('MALDIVES','MV')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('MALI','ML')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('MALTA','MT')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('MARSHALL ISLANDS','MH')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('MARTINIQUE','MQ')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('MAURITANIA','MR')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('MAURITIUS','MU')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('MAYOTTE','YT')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('MEXICO','MX')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('MICRONESIA, FEDERATED STATES OF','FM')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('MOLDOVA, REPUBLIC OF','MD')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('MONACO','MC')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('MONGOLIA','MN')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('MONTSERRAT','MS')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('MOROCCO','MA')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('MOZAMBIQUE','MZ')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('MYANMAR','MM')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('NAMIBIA','NA')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('NAURU','NR')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('NEPAL','NP')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('NETHERLANDS','NL')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('NETHERLANDS ANTILLES','AN')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('NEW CALEDONIA','NC')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('NEW ZEALAND','NZ')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('NICARAGUA','NI')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('NIGER','NE')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('NIGERIA','NG')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('NIUE','NU')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('NORFOLK ISLAND','NF')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('NORTHERN MARIANA ISLANDS','MP')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('NORWAY','NO')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('OMAN','OM')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('PAKISTAN','PK')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('PALAU','PW')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('PALESTINIAN TERRITORY, OCCUPIED','PS')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('PANAMA','PA')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('PAPUA NEW GUINEA','PG')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('PARAGUAY','PY')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('PERU','PE')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('PHILIPPINES','PH')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('PITCAIRN','PN')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('POLAND','PL')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('PORTUGAL','PT')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('PUERTO RICO','PR')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('QATAR','QA')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('RÉUNION','RE')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('ROMANIA','RO')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('RUSSIAN FEDERATION','RU')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('RWANDA','RW')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('SAINT HELENA ','SH')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('SAINT KITTS AND NEVIS','KN')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('SAINT LUCIA','LC')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('SAINT PIERRE AND MIQUELON','PM')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('SAINT VINCENT AND THE GRENADINES','VC')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('SAMOA','WS')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('SAN MARINO','SM')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('SAO TOME AND PRINCIPE','ST')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('SAUDI ARABIA','SA')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('SENEGAL','SN')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('SEYCHELLES','SC')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('SIERRA LEONE','SL')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('SINGAPORE','SG')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('SLOVAKIA','SK')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('SLOVENIA','SI')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('SOLOMON ISLANDS','SB')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('SOMALIA','SO')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('SOUTH AFRICA','ZA')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('SOUTH GEORGIA AND THE SOUTH SANDWICH ISLANDS','GS')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('SPAIN','ES')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('SRI LANKA','LK')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('SUDAN','SD')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('SURINAME','SR')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('SVALBARD AND JAN MAYEN','SJ')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('SWAZILAND','SZ')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('SWEDEN','SE')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('SWITZERLAND','CH')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('SYRIAN ARAB REPUBLIC','SY')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('TAIWAN, PROVINCE OF CHINA','TW')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('TAJIKISTAN','TJ')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('TANZANIA, UNITED REPUBLIC OF','TZ')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('THAILAND','TH')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('TIMOR-LESTE','TL')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('TOGO','TG')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('TOKELAU','TK')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('TONGA','TO')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('TRINIDAD AND TOBAGO','TT')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('TUNISIA','TN')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('TURKEY','TR')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('TURKMENISTAN','TM')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('TURKS AND CAICOS ISLANDS','TC')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('TUVALU','TV')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('UGANDA','UG')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('UKRAINE','UA')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('UNITED ARAB EMIRATES','AE')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('UNITED KINGDOM','GB')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('UNITED STATES','US')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('UNITED STATES MINOR OUTLYING ISLANDS','UM')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('URUGUAY','UY')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('UZBEKISTAN','UZ')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('VANUATU','VU')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('VENEZUELA','VE')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('VIET NAM','VN')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('VIRGIN ISLANDS, BRITISH','VG')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('VIRGIN ISLANDS, U.S.','VI')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('WALLIS AND FUTUNA','WF')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('WESTERN SAHARA','EH')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('YEMEN','YE')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('YUGOSLAVIA','YU')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('ZAMBIA','ZM')
	</cfquery>
	<cfquery name="update" datasource="#application.dsn#">
		insert into statsCountries (country,isoCode) values ('ZIMBABWE','ZW')
	</cfquery>
	
	<cfif not error>
		<cfoutput><span class="frameMenuBullet">&raquo;</span> Stats Countries table deployed<p></p></cfoutput><cfflush>
	</cfif>
	
	<cfoutput><span class="frameMenuBullet">&raquo;</span> Update Complete</cfoutput><cfflush>	
	
<cfelse>
	<cfoutput>
	<p>
	<strong>This script :</strong>
	<ul>
		<li type="square">Deploys new Stats Countries Table</li>
	</ul> 
	</p>
	<form action="" method="post">
		<input type="hidden" name="dummy" value="1">
		<input type="submit" value="Run b123 Updates" name="submit">
	</form>
	
	</cfoutput>
</cfif>

</body>
</html>
