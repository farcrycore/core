<!---
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$


|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/farcry/_stats/deploy.cfm,v 1.16 2003/06/15 23:15:30 brendan Exp $
$Author: brendan $
$Date: 2003/06/15 23:15:30 $
$Name: b131 $
$Revision: 1.16 $


|| DESCRIPTION ||
$Description: creates/populates tables needed for farcry stats $
$TODO: <whatever todo's needed -- can be inline also>$


|| DEVELOPER ||
$Developer: Daniel Morphett (daniel@daemon.com.au) $



|| ATTRIBUTES ||
$in: stArgs.bDropTable 	: means drop the stats table (results in data loss if any rows in it, so would usually only happen on an install!!) $
$out: stStatus			: struct to pass status report back to caller $
--->


<!--- struct to pass report back to caller --->
<cfset stStatus = StructNew()>
	

<!--- drop table to hold hours in a day --->
<cftry>
	<cfswitch expression="#application.dbtype#">
	<cfcase value="ora">
		<cfquery datasource="#stArgs.dsn#" name="qDropTemp">
			drop table #application.dbowner#statsHours
		</cfquery>
	</cfcase>
	<cfcase value="mysql">
		<cfquery datasource="#stArgs.dsn#" name="qDropTemp">
			drop table #application.dbowner#statsHours
		</cfquery>
	</cfcase>
	<cfdefaultcase>
		<cfquery datasource="#stArgs.dsn#" name="qDropTemp">
			drop table #application.dbowner#statsHours
		</cfquery>
	</cfdefaultcase>
	</cfswitch>
	<cfcatch><!--- suppress table exists error ---></cfcatch>
</cftry>
	
<!--- create table to hold hours in a day, plus one to hold days in week --->
<cfswitch expression="#application.dbtype#">
	<cfcase value="ora">
		<cfquery datasource="#stArgs.dsn#" name="qCreateTemp">
			create table #application.dbowner#statsHours (
				HOUR NUMBER NOT NULL,
				CONSTRAINT PK_STATSHOURS PRIMARY KEY (HOUR)
			)
		</cfquery>
	
		<!--- populate table --->
		<cfscript>
			sql = "
			declare
			vhour NUMBER;
			BEGIN
				vhour := 0;
				WHILE vHOUR < 24 LOOP
					INSERT INTO statsHours (hour) VALUES (vhour);
					vhour := vHour + 1;
				END LOOP;
			END;
			";		
		</cfscript>
		<cfquery datasource="#stArgs.dsn#" name="qPopulateTemp">
			#sql#
		</cfquery>
		<cfquery datasource="#stArgs.dsn#" name="qCheckdays">
			SELECT count(*) AS tblExists FROM #application.dbowner#USER_TABLES
			WHERE TABLE_NAME = 'STATSDAYS'
		</cfquery>
		<cfif qCheckdays.recordcount neq 0>
			<!--- create the stats days table and populate it--->
			<cfquery datasource="#stArgs.dsn#" name="qCreate">
				drop table #application.dbowner#StatsDays
			</cfquery>
		</cfif>
		<cfquery datasource="#stArgs.dsn#" name="qCreate">					
			CREATE TABLE #application.dbowner#StatsDays (
				Day number NOT NULL ,
				Name varchar2(10) NOT NULL 
			) 
						
			insert into statsdays (day,name) values (1,'Sunday')
			insert into statsdays (day,name) values (2,'Monday')
			insert into statsdays (day,name) values (3,'Tuesday')
			insert into statsdays (day,name) values (4,'Wednesday')
			insert into statsdays (day,name) values (5,'Thursday')
			insert into statsdays (day,name) values (6,'Friday')
			insert into statsdays (day,name) values (7,'Saturday')
			
			-- dummy query to stop cf bombing out
			select 'blah'
		</cfquery>
		<!--- check main stats table exists, for later --->		
		<cfquery datasource="#stArgs.dsn#" name="qCheck">
			SELECT count(*) AS tblExists FROM #application.dbowner#USER_TABLES
			WHERE TABLE_NAME = 'STATS'
		</cfquery>
	</cfcase>
	<cfcase value="mysql">
		<cfquery datasource="#stArgs.dsn#" name="qCreateTemp">
			drop table if exists #application.dbowner#statsHours 
		</cfquery>
		<cfquery datasource="#stArgs.dsn#" name="qCreateTemp">
			create table #application.dbowner#statsHours (
				HOUR INTEGER NOT NULL,
				CONSTRAINT PK_STATSHOURS PRIMARY KEY (HOUR)
			)
		</cfquery>
		
		<!--- populate table --->
		<cfloop index="vHour" from="0" to="23">
			<cfscript>
				sql = "";			
				sql = sql & "INSERT INTO statsHours (hour) VALUES (" & vhour & ")";			
			</cfscript>
			<cfquery datasource="#stArgs.dsn#" name="qPopulateTemp">
				#sql#
			</cfquery>
		</cfloop>
		
		<!--- make a dummy tblexists --->
		<cftry>
			<cfparam name="qCheck.tblExists" default="0">
			<cfquery datasource="#stArgs.dsn#" name="qCheck">
				select count(*) as tblexists from stats	
			</cfquery>
			<cfcatch>
				<!--- do nothing --->
			</cfcatch>		
		</cftry>
		<!--- create the stats days table and populate it--->
		<cfquery datasource="#stArgs.dsn#" name="qDrop">
			drop table if exists StatsDays
		</cfquery>
		<cfquery datasource="#stArgs.dsn#" name="qCreate">
			CREATE TABLE StatsDays (
				Day int NOT NULL ,
				Name varchar (10) NOT NULL 
			) 
		</cfquery>
		<cfquery datasource="#stArgs.dsn#" name="qPop">					
			insert into statsdays (day,name) values (1,'Sunday')
		</cfquery>
		<cfquery datasource="#stArgs.dsn#" name="qPop">		
			insert into statsdays (day,name) values (2,'Monday')
		</cfquery>
		<cfquery datasource="#stArgs.dsn#" name="qPop">		
			insert into statsdays (day,name) values (3,'Tuesday')
		</cfquery>
		<cfquery datasource="#stArgs.dsn#" name="qPop">		
			insert into statsdays (day,name) values (4,'Wednesday')
		</cfquery>
		<cfquery datasource="#stArgs.dsn#" name="qPop">		
			insert into statsdays (day,name) values (5,'Thursday')
		</cfquery>
		<cfquery datasource="#stArgs.dsn#" name="qPop">		
			insert into statsdays (day,name) values (6,'Friday')
		</cfquery>
		<cfquery datasource="#stArgs.dsn#" name="qPop">		
			insert into statsdays (day,name) values (7,'Saturday')
		</cfquery>
			
	</cfcase>
	<cfdefaultcase>
		<cfquery datasource="#stArgs.dsn#" name="qCreateTemp">
			create table #application.dbowner#statsHours (hour tinyint identity(0,1))
		</cfquery>
	
		<!--- populate table --->
		<cfquery datasource="#stArgs.dsn#" name="qPopulateTemp">
		declare @hour tinyint
		set @hour = 0
		while @hour < 24
		begin
		insert into #application.dbowner#statsHours
		default values
		set @hour=@hour+1
		end
		</cfquery>
		<cfquery datasource="#stArgs.dsn#" name="qCheck">
			SELECT count(*) AS tblExists FROM sysobjects 
			WHERE name = 'stats'
		</cfquery>
		<!--- create the stats days table and populate it--->
		<cfquery datasource="#stArgs.dsn#" name="qCreate">
			if exists (select * from sysobjects where id = object_id(N'#application.dbowner#StatsDays') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
			drop table #application.dbowner#StatsDays
						
			CREATE TABLE #application.dbowner#StatsDays (
				[Day] [int] NOT NULL ,
				[Name] [varchar] (10) NOT NULL 
			) ON [PRIMARY]
						
			insert into #application.dbowner#statsdays (day,name) values (1,'Sunday')
			insert into #application.dbowner#statsdays (day,name) values (2,'Monday')
			insert into #application.dbowner#statsdays (day,name) values (3,'Tuesday')
			insert into #application.dbowner#statsdays (day,name) values (4,'Wednesday')
			insert into #application.dbowner#statsdays (day,name) values (5,'Thursday')
			insert into #application.dbowner#statsdays (day,name) values (6,'Friday')
			insert into #application.dbowner#statsdays (day,name) values (7,'Saturday')
			
			-- dummy query to stop cf bombing out
			select 'blah'
		</cfquery>
	</cfdefaultcase>
</cfswitch>
	
	
<!--- if stats table exists, and they are not asking us to drop it, just give them some info --->
<cfif qCheck.tblExists AND NOT stArgs.bDropTable>
       <cfset stStatus.bSuccess = "false">
	<cfset stStatus.message = "stats already exists in the database.">
	<cfset stStatus.detail = "stats can be dropped and redeployed by setting the bDropTable=true argument. Dropping the table will result in a loss of all data.">
<cfelse>
	<!--- drop the Audit tables --->
	<cfswitch expression="#application.dbtype#">
		<cfcase value="ora">
			<cfif qCheck.tblExists>
				<cfquery datasource="#stArgs.dsn#" name="qDrop">
					DROP TABLE #application.dbowner#stats
				</cfquery>
			</cfif>
			
			<!--- create the stats --->
			<cfscript>
				sql = "CREATE TABLE #application.dbowner#STATS (
LOGID VARCHAR2(50) NOT NULL ,
PAGEID VARCHAR2(50) NOT NULL ,
NAVID VARCHAR2(50) NOT NULL , 
USERID VARCHAR2(50) NOT NULL ,
REMOTEIP VARCHAR2(50) NOT NULL,
LOGDATETIME date NOT NULL,
SESSIONID VARCHAR2(100) NOT NULL,
BROWSER VARCHAR2(100) NOT NULL,
REFERER VARCHAR2(1024) NOT NULL,
LOCALE VARCHAR2(100) NOT NULL,
OS VARCHAR2(50) NOT NULL,
CONSTRAINT PK_STATS PRIMARY KEY (LOGID))
";
				
			</cfscript>
			
			<cfquery datasource="#stArgs.dsn#" name="qCreate">
				#sql#
			</cfquery>
			<cfscript>
				sql = "CREATE INDEX #application.dbowner#IDX_STATS ON STATS(pageid,logdatetime)";
			</cfscript>
			<cfquery datasource="#stArgs.dsn#" name="qCreate">
				#sql#
			</cfquery>
			
		</cfcase>
		<cfcase value="mysql">
			
			<cfquery datasource="#stArgs.dsn#" name="qDrop">
				DROP TABLE IF EXISTS #application.dbowner#stats
			</cfquery>			
			
			<!--- create the stats --->
			<cfscript>
				sql = "CREATE TABLE #application.dbowner#STATS (
LOGID VARCHAR(50) NOT NULL ,
PAGEID VARCHAR(50) NOT NULL ,
NAVID VARCHAR(50) NOT NULL , 
USERID VARCHAR(50) NOT NULL ,
REMOTEIP VARCHAR(50) NOT NULL,
LOGDATETIME datetime NOT NULL,
SESSIONID VARCHAR(100) NOT NULL,
BROWSER VARCHAR(100) NOT NULL,
REFERER TEXT,
LOCALE VARCHAR(100) NOT NULL,
OS VARCHAR(50) NOT NULL,
CONSTRAINT PK_STATS PRIMARY KEY (LOGID))
";
				
			</cfscript>
			
			<cfquery datasource="#stArgs.dsn#" name="qCreate">
				#sql#
			</cfquery>
			<cfscript>
				sql = "CREATE INDEX #application.dbowner#IDX_STATS ON STATS(pageid,logdatetime)";
			</cfscript>
			<cfquery datasource="#stArgs.dsn#" name="qCreate">
				#sql#
			</cfquery>
			
		</cfcase>
	
		<cfdefaultcase>
		
			<cfquery datasource="#stArgs.dsn#" name="qDrop">
			if exists (select * from sysobjects where name = 'stats')
			DROP TABLE stats
	
			-- return recordset to stop CF bombing out?!?
			select count(*) as blah from sysobjects
			</cfquery>
			
			
			<!--- create the stats --->
			<cfquery datasource="#stArgs.dsn#" name="qCreate">
			CREATE TABLE #application.dbowner#stats (
				[logId] [varchar] (50) NOT NULL ,
				[pageid] [varchar] (50) NOT NULL ,
				[navid] [varchar] (50) NOT NULL ,
				[userid] [varchar] (50) NOT NULL ,
				[remoteip] [varchar] (50) NOT NULL ,
				[sessionid] [varchar] (100) NOT NULL ,
				[browser] [varchar] (100) NOT NULL ,
				[referer] [varchar] (1024) NOT NULL ,
				[locale] [varchar] (100) NOT NULL ,
				[os] [varchar] (50) NOT NULL ,
				[logDateTime] [datetime] NOT NULL			
			) ON [PRIMARY];
			
			ALTER TABLE #application.dbowner#stats WITH NOCHECK ADD 
				CONSTRAINT [PK_stats] PRIMARY KEY CLUSTERED 
				(
					[logId]
				)  ON [PRIMARY];
				
			CREATE NONCLUSTERED INDEX [stats0] ON #application.dbowner#stats([pageid], [logdatetime])
			</cfquery>
			
		</cfdefaultcase>
	</cfswitch>
	
	<!--- set up countries table --->
	<cftry>
		<cfquery datasource="#stArgs.dsn#" name="qDrop">
			drop table #application.dbowner#statsCountries
		</cfquery>
		<cfcatch><!--- Supress table doesn't exists error ---></cfcatch>
	</cftry>
	
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
	
	<cfset stStatus.message = "stats created.">
	<cfset stStatus.detail = "stats created.">
       <cfset stStatus.bSuccess = "true">
	<cfset stStatus.status = "true">
</cfif>

