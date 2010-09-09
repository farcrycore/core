<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/farcry/_stats/deploy.cfm,v 1.22 2005/09/16 07:25:39 guy Exp $
$Author: guy $
$Date: 2005/09/16 07:25:39 $
$Name: p300_b113 $
$Revision: 1.22 $


|| DESCRIPTION ||
$Description: creates/populates tables needed for farcry stats $
$TODO: <whatever todo's needed -- can be inline also>$


|| DEVELOPER ||
$Developer: Daniel Morphett (daniel@daemon.com.au) $



|| ATTRIBUTES ||
$in: arguments.bDropTable 	: means drop the stats table (results in data loss if any rows in it, so would usually only happen on an install!!) $
$out: stStatus			: struct to pass status report back to caller $
--->


<!--- struct to pass report back to caller --->
<cfset stStatus = StructNew()>
	

<!--- drop table to hold hours in a day --->
<cftry>
	<cfswitch expression="#arguments.dbtype#">
	<cfcase value="ora">
		<cfquery datasource="#arguments.dsn#" name="qExists">
			SELECT * FROM USER_TABLES
			WHERE TABLE_NAME = 'STATSHOURS'
		</cfquery>
		<cfif qExists.recordCount>
		<cfquery datasource="#arguments.dsn#" name="qDropTemp">
			DROP TABLE #arguments.dbowner#statsHours
		</cfquery>
		</cfif>	
	</cfcase>
	<cfcase value="mysql,mysql5">
		<cfquery datasource="#arguments.dsn#" name="qDropTemp">
			drop table #arguments.dbowner#statsHours
		</cfquery>
	</cfcase>
	<cfcase value="postgresql">
		<cfquery datasource="#arguments.dsn#" name="qDropTemp">
			drop table #arguments.dbowner#statsHours
		</cfquery>
	</cfcase>
	
	<!--- TODO: Move to gateway? --->
	<cfcase value="HSQLDB">
		<cfquery datasource="#arguments.dsn#" name="qDropTemp">
			DROP TABLE statsHours IF EXISTS;
		</cfquery>
	</cfcase>
	
	<cfdefaultcase>
		<cfquery datasource="#arguments.dsn#" name="qDropTemp">
			drop table #arguments.dbowner#statsHours
		</cfquery>
	</cfdefaultcase>
	</cfswitch>
	<cfcatch><!--- suppress table exists error ---></cfcatch>
</cftry>

<!--- create table to hold hours in a day, plus one to hold days in week --->
<cfswitch expression="#arguments.dbtype#">
	<cfcase value="ora">
		<cfquery datasource="#arguments.dsn#" name="qCreateTemp">
			create table #arguments.dbowner#statsHours (
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
					INSERT INTO #arguments.dbowner#statsHours (hour) VALUES (vhour);
					vhour := vHour + 1;
				END LOOP;
			END;
			";
		</cfscript>
		<cfquery datasource="#arguments.dsn#" name="qPopulateTemp">
			#sql#
		</cfquery>
		<cfquery datasource="#arguments.dsn#" name="qCheckdays">
			SELECT count(*) AS tblExists FROM USER_TABLES
			WHERE TABLE_NAME = 'STATSDAYS'
		</cfquery>
		<cfif qCheckdays.tblExists neq 0>
			<!--- create the stats days table and populate it--->
			<cfquery datasource="#arguments.dsn#" name="qCreate">
				drop table #arguments.dbowner#StatsDays
			</cfquery>
		</cfif>
		<cfquery datasource="#arguments.dsn#" name="qCreate">
			CREATE TABLE #arguments.dbowner#StatsDays (
				Day number NOT NULL ,
				Name varchar2(10) NOT NULL
			)
		</cfquery>

		<cfquery datasource="#arguments.dsn#" name="qCreate">
			insert into #arguments.dbowner#StatsDays (day,name) values (1,'Sunday')
		</cfquery>
		<cfquery datasource="#arguments.dsn#" name="qCreate">
			insert into #arguments.dbowner#StatsDays (day,name) values (2,'Monday')
		</cfquery>
		<cfquery datasource="#arguments.dsn#" name="qCreate">
			insert into #arguments.dbowner#StatsDays (day,name) values (3,'Tuesday')
		</cfquery>
		<cfquery datasource="#arguments.dsn#" name="qCreate">
			insert into #arguments.dbowner#StatsDays (day,name) values (4,'Wednesday')
		</cfquery>
		<cfquery datasource="#arguments.dsn#" name="qCreate">
			insert into #arguments.dbowner#StatsDays (day,name) values (5,'Thursday')
		</cfquery>
		<cfquery datasource="#arguments.dsn#" name="qCreate">
			insert into #arguments.dbowner#StatsDays (day,name) values (6,'Friday')
		</cfquery>
		<cfquery datasource="#arguments.dsn#" name="qCreate">
			insert into #arguments.dbowner#StatsDays (day,name) values (7,'Saturday')
		</cfquery>

		<!--- check main stats table exists, for later --->
		<cfquery datasource="#arguments.dsn#" name="qCheck">
			SELECT count(*) AS tblExists FROM USER_TABLES
			WHERE TABLE_NAME = 'STATS'
		</cfquery>
	</cfcase>

	<cfcase value="mysql,mysql5">
		<cfquery datasource="#arguments.dsn#" name="qCreateTemp">
			drop table if exists #arguments.dbowner#statsHours
		</cfquery>
		<cfquery datasource="#arguments.dsn#" name="qCreateTemp">
			create table #arguments.dbowner#statsHours (
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
			<cfquery datasource="#arguments.dsn#" name="qPopulateTemp">
				#sql#
			</cfquery>
		</cfloop>

		<!--- make a dummy tblexists --->
		<cftry>
			<cfparam name="qCheck.tblExists" default="0">
			<cfquery datasource="#arguments.dsn#" name="qCheck">
				select count(*) as tblexists from stats
			</cfquery>
			<cfcatch>
				<!--- do nothing --->
			</cfcatch>
		</cftry>
		<!--- create the stats days table and populate it--->
		<cfquery datasource="#arguments.dsn#" name="qDrop">
			drop table if exists statsDays
		</cfquery>
		<cfquery datasource="#arguments.dsn#" name="qCreate">
			CREATE TABLE statsDays (
				Day int NOT NULL ,
				Name varchar (10) NOT NULL
			)
		</cfquery>
		<cfquery datasource="#arguments.dsn#" name="qPop">
			insert into statsDays (day,name) values (1,'Sunday')
		</cfquery>
		<cfquery datasource="#arguments.dsn#" name="qPop">
			insert into statsDays (day,name) values (2,'Monday')
		</cfquery>
		<cfquery datasource="#arguments.dsn#" name="qPop">
			insert into statsDays (day,name) values (3,'Tuesday')
		</cfquery>
		<cfquery datasource="#arguments.dsn#" name="qPop">
			insert into statsDays (day,name) values (4,'Wednesday')
		</cfquery>
		<cfquery datasource="#arguments.dsn#" name="qPop">
			insert into statsDays (day,name) values (5,'Thursday')
		</cfquery>
		<cfquery datasource="#arguments.dsn#" name="qPop">
			insert into statsDays (day,name) values (6,'Friday')
		</cfquery>
		<cfquery datasource="#arguments.dsn#" name="qPop">
			insert into statsDays (day,name) values (7,'Saturday')
		</cfquery>

	</cfcase>
	<cfcase value="postgresql">
		<cftry>
			<cfquery datasource="#arguments.dsn#" name="qCreateTemp">
			DROP TABLE #arguments.dbowner#statsHours
			</cfquery>

			<cfcatch>
				<cflog text="#cfcatch.message# #cfcatch.detail# [SQL: #cfcatch.sql#]" file="coapi" type="warning" application="yes">
			</cfcatch>
		</cftry>

		<cfquery datasource="#arguments.dsn#" name="qCreateTemp">
		CREATE TABLE #arguments.dbowner#statsHours(HOUR INTEGER NOT NULL PRIMARY KEY)
		</cfquery>

		<!--- populate table --->
		<cfloop index="vHour" from="0" to="23">
			<cfscript>
				sql = "";
				sql = sql & "INSERT INTO statsHours (hour) VALUES (" & vhour & ")";
			</cfscript>
			<cfquery datasource="#arguments.dsn#" name="qPopulateTemp">
				#sql#
			</cfquery>
		</cfloop>

		<!--- make a dummy tblexists --->
		<cftry>
			<cfparam name="qCheck.tblExists" default="0">

			<cfquery datasource="#arguments.dsn#" name="qCheck">
			SELECT count(*) AS tblexists FROM stats
			</cfquery>

			<cfcatch>
				<cflog text="#cfcatch.message# #cfcatch.detail# [SQL: #cfcatch.sql#]" file="coapi" type="warning" application="yes">
			</cfcatch>
		</cftry>

		<!--- create the stats days table and populate it--->
		<cftry>
			<cfquery datasource="#arguments.dsn#" name="qDrop">
			DROP TABLE statsDays
			</cfquery>

			<cfcatch>
				<cflog text="#cfcatch.message# #cfcatch.detail# [SQL: #cfcatch.sql#]" file="coapi" type="warning" application="yes">
			</cfcatch>
		</cftry>

		<cftry>
			<cfquery datasource="#arguments.dsn#" name="qCreate">
			CREATE TABLE statsDays (Day int NOT NULL ,Name varchar (10) NOT NULL)
			</cfquery>

			<cfquery datasource="#arguments.dsn#" name="qPop">
			INSERT INTO statsDays (day,name) VALUES (1,'Sunday')
			</cfquery>

			<cfquery datasource="#arguments.dsn#" name="qPop">
			INSERT INTO statsDays (day,name) VALUES (2,'Monday')
			</cfquery>

			<cfquery datasource="#arguments.dsn#" name="qPop">
			INSERT INTO statsDays (day,name) VALUES (3,'Tuesday')
			</cfquery>

			<cfquery datasource="#arguments.dsn#" name="qPop">
			INSERT INTO statsDays (day,name) VALUES (4,'Wednesday')
			</cfquery>

			<cfquery datasource="#arguments.dsn#" name="qPop">
			INSERT INTO statsDays (day,name) VALUES (5,'Thursday')
			</cfquery>

			<cfquery datasource="#arguments.dsn#" name="qPop">
			INSERT INTO statsDays (day,name) VALUES (6,'Friday')
			</cfquery>

			<cfquery datasource="#arguments.dsn#" name="qPop">
			INSERT INTO statsDays (day,name) VALUES (7,'Saturday')
			</cfquery>

			<cfcatch>
				<cflog text="#cfcatch.message# #cfcatch.detail# [SQL: #cfcatch.sql#]" file="coapi" type="error" application="yes">
			</cfcatch>
		</cftry>
	</cfcase>
	
	
	<!--- TODO: move to gateway? --->
	<cfcase value="HSQLDB">
		<cfquery datasource="#arguments.dsn#" name="qCreateTemp">
			DROP TABLE #arguments.dbowner#statsHours IF EXISTS;
		</cfquery>

		<cfquery datasource="#arguments.dsn#" name="qCreateTemp">
			CREATE TABLE statsHours(HOUR INTEGER NOT NULL PRIMARY KEY)
		</cfquery>

		<!--- populate table --->
		<cfloop index="vHour" from="0" to="23">
			<cfscript>
				sql = "";
				sql = sql & "INSERT INTO statsHours (hour) VALUES (" & vhour & ")";
			</cfscript>
			<cfquery datasource="#arguments.dsn#" name="qPopulateTemp">
				#sql#
			</cfquery>
		</cfloop>

		<!--- make a dummy tblexists --->
		<cftry>
			<cfparam name="qCheck.tblExists" default="0">

			<cfquery datasource="#arguments.dsn#" name="qCheck">
				SELECT count(*) AS tblexists FROM stats
			</cfquery>

			<cfcatch>
				<cflog text="#cfcatch.message# #cfcatch.detail# [SQL: #cfcatch.sql#]" file="coapi" type="warning" application="yes">
			</cfcatch>
		</cftry>

		<!--- create the stats days table and populate it--->
		<cfquery datasource="#arguments.dsn#" name="qDrop">
			DROP TABLE statsDays IF EXISTS
		</cfquery>

		<cftry>
			<cfquery datasource="#arguments.dsn#" name="qCreate">
				CREATE TABLE statsDays (Day int NOT NULL, Name varchar(10) NOT NULL)
			</cfquery>

			<cfquery datasource="#arguments.dsn#" name="qPop">
				INSERT INTO statsDays (day,name) VALUES (1,'Sunday')
			</cfquery>

			<cfquery datasource="#arguments.dsn#" name="qPop">
				INSERT INTO statsDays (day,name) VALUES (2,'Monday')
			</cfquery>

			<cfquery datasource="#arguments.dsn#" name="qPop">
				INSERT INTO statsDays (day,name) VALUES (3,'Tuesday')
			</cfquery>

			<cfquery datasource="#arguments.dsn#" name="qPop">
				INSERT INTO statsDays (day,name) VALUES (4,'Wednesday')
			</cfquery>

			<cfquery datasource="#arguments.dsn#" name="qPop">
				INSERT INTO statsDays (day,name) VALUES (5,'Thursday')
			</cfquery>

			<cfquery datasource="#arguments.dsn#" name="qPop">
				INSERT INTO statsDays (day,name) VALUES (6,'Friday')
			</cfquery>

			<cfquery datasource="#arguments.dsn#" name="qPop">
				INSERT INTO statsDays (day,name) VALUES (7,'Saturday')
			</cfquery>

			<cfcatch>
				<cflog text="#cfcatch.message# #cfcatch.detail# [SQL: #cfcatch.sql#]" file="coapi" type="error" application="yes">
			</cfcatch>
		</cftry>
	</cfcase>
	
	
	
	
	
	
	<cfdefaultcase>
		<cfquery datasource="#arguments.dsn#" name="qCreateTemp">
			create table #arguments.dbowner#statsHours (hour tinyint identity(0,1))
		</cfquery>

		<!--- populate table --->
		<cfquery datasource="#arguments.dsn#" name="qPopulateTemp">
		declare @hour tinyint
		set @hour = 0
		while @hour < 24
		begin
		insert into #arguments.dbowner#statsHours
		default values
		set @hour=@hour+1
		end
		</cfquery>
		<cfquery datasource="#arguments.dsn#" name="qCheck">
			SELECT count(*) AS tblExists FROM sysobjects
			WHERE name = 'stats'
		</cfquery>
		<!--- create the stats days table and populate it--->
		<cfquery datasource="#arguments.dsn#" name="qCreate">
			if exists (select * from sysobjects where id = object_id(N'#arguments.dbowner#StatsDays') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
			drop table #arguments.dbowner#StatsDays

			CREATE TABLE #arguments.dbowner#StatsDays (
				[Day] [int] NOT NULL ,
				[Name] [varchar] (10) NOT NULL
			) ON [PRIMARY]

			insert into #arguments.dbowner#statsdays (day,name) values (1,'Sunday')
			insert into #arguments.dbowner#statsdays (day,name) values (2,'Monday')
			insert into #arguments.dbowner#statsdays (day,name) values (3,'Tuesday')
			insert into #arguments.dbowner#statsdays (day,name) values (4,'Wednesday')
			insert into #arguments.dbowner#statsdays (day,name) values (5,'Thursday')
			insert into #arguments.dbowner#statsdays (day,name) values (6,'Friday')
			insert into #arguments.dbowner#statsdays (day,name) values (7,'Saturday')

			-- dummy query to stop cf bombing out
			select 'blah'
		</cfquery>
	</cfdefaultcase>
</cfswitch>


<!--- if stats table exists, and they are not asking us to drop it, just give them some info --->
<cfif qCheck.tblExists AND NOT arguments.bDropTable>
       <cfset stStatus.bSuccess = "false">
	<cfset stStatus.message = "stats already exists in the database.">
	<cfset stStatus.detail = "stats can be dropped and redeployed by setting the bDropTable=true argument. Dropping the table will result in a loss of all data.">
<cfelse>
	<!--- drop the Audit tables --->
	<cfswitch expression="#arguments.dbtype#">
		<cfcase value="ora">
			<cfif qCheck.tblExists>
				<cfquery datasource="#arguments.dsn#" name="qDrop">
					DROP TABLE #arguments.dbowner#stats
				</cfquery>
			</cfif>

			<!--- create the stats --->
			<cfscript>
				sql = "CREATE TABLE #arguments.dbowner#STATS (
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

			<cfquery datasource="#arguments.dsn#" name="qCreate">
				#sql#
			</cfquery>
			<cfscript>
				sql = "CREATE INDEX #arguments.dbowner#IDX_STATS ON #arguments.dbowner#STATS(pageid,logdatetime)";
			</cfscript>
			<cfquery datasource="#arguments.dsn#" name="qCreate">
				#sql#
			</cfquery>

		</cfcase>
		<cfcase value="mysql,mysql5">

			<cfquery datasource="#arguments.dsn#" name="qDrop">
				DROP TABLE IF EXISTS #arguments.dbowner#stats
			</cfquery>

			<!--- create the stats --->
			<cfscript>
				sql = "CREATE TABLE #arguments.dbowner#stats (
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

			<cfquery datasource="#arguments.dsn#" name="qCreate">
				#sql#
			</cfquery>
			<cfscript>
				sql = "CREATE INDEX #arguments.dbowner#IDX_STATS ON #arguments.dbowner#stats(pageid,logdatetime)";
			</cfscript>
			<cfquery datasource="#arguments.dsn#" name="qCreate">
				#sql#
			</cfquery>

		</cfcase>

		<cfcase value="postgresql">

			<cftry><cfquery datasource="#arguments.dsn#" name="qDrop">
				DROP TABLE #arguments.dbowner#stats
			</cfquery><cfcatch></cfcatch></cftry>

			<!--- create the stats --->
			<cfscript>
				sql = "CREATE TABLE #arguments.dbowner#stats (
LOGID VARCHAR(50) NOT NULL PRIMARY KEY,
PAGEID VARCHAR(50) NOT NULL ,
NAVID VARCHAR(50) NOT NULL ,
USERID VARCHAR(50) NOT NULL ,
REMOTEIP VARCHAR(50) NOT NULL,
LOGDATETIME timestamp NOT NULL,
SESSIONID VARCHAR(100) NOT NULL,
BROWSER VARCHAR(100) NOT NULL,
REFERER TEXT,
LOCALE VARCHAR(100) NOT NULL,
OS VARCHAR(50) NOT NULL)
";

			</cfscript>

			<cfquery datasource="#arguments.dsn#" name="qCreate">
				#sql#
			</cfquery>
			<cfscript>
				sql = "CREATE INDEX #arguments.dbowner#IDX_STATS ON #arguments.dbowner#stats(pageid,logdatetime)";
			</cfscript>
			<cfquery datasource="#arguments.dsn#" name="qCreate">
				#sql#
			</cfquery>

		</cfcase>

		<!--- TODO: move to gateway? --->
		<cfcase value="HSQLDB">
			<cfquery datasource="#arguments.dsn#" name="qDrop">
				DROP TABLE stats IF EXISTS
			</cfquery>

			<!--- create the stats --->
			<cfscript>
				sql = "CREATE TABLE stats (
LOGID VARCHAR(50) NOT NULL PRIMARY KEY,
PAGEID VARCHAR(50) NOT NULL ,
NAVID VARCHAR(50) NOT NULL ,
USERID VARCHAR(50) NOT NULL ,
REMOTEIP VARCHAR(50) NOT NULL,
LOGDATETIME timestamp NOT NULL,
SESSIONID VARCHAR(100) NOT NULL,
BROWSER VARCHAR(100) NOT NULL,
REFERER LONGVARCHAR,
LOCALE VARCHAR(100) NOT NULL,
OS VARCHAR(50) NOT NULL)";

			</cfscript>

			<cfquery datasource="#arguments.dsn#" name="qCreate">
				#sql#
			</cfquery>
			<cfscript>
				sql = "CREATE INDEX IDX_STATS ON stats(pageid,logdatetime)";
			</cfscript>
			<cfquery datasource="#arguments.dsn#" name="qCreate">
				#sql#
			</cfquery>
		</cfcase>


		<cfdefaultcase>

			<cfquery datasource="#arguments.dsn#" name="qDrop">
			if exists (select * from sysobjects where name = 'stats')
			DROP TABLE stats

			-- return recordset to stop CF bombing out?!?
			select count(*) as blah from sysobjects
			</cfquery>


			<!--- create the stats --->
			<cfquery datasource="#arguments.dsn#" name="qCreate">
			CREATE TABLE #arguments.dbowner#stats (
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

			ALTER TABLE #arguments.dbowner#stats WITH NOCHECK ADD
				CONSTRAINT [PK_stats] PRIMARY KEY CLUSTERED
				(
					[logId]
				)  ON [PRIMARY];

			CREATE NONCLUSTERED INDEX [stats0] ON #arguments.dbowner#stats([pageid], [logdatetime])
			</cfquery>

		</cfdefaultcase>
	</cfswitch>

	<!--- set up countries table --->
	<cftry>
		<cfquery datasource="#arguments.dsn#" name="qDrop">
			drop table #arguments.dbowner#statsCountries
		</cfquery>
		<cfcatch><!--- Supress table doesn't exists error ---></cfcatch>
	</cftry>

	<cfswitch expression="#arguments.dbtype#">
		<cfcase value="ora">
			<cfquery name="update" datasource="#arguments.dsn#">
				create table #arguments.dbowner#statsCountries (
					COUNTRY VARCHAR2(255) NOT NULL,
					ISOCODE CHAR (2) NOT NULL
				)
			</cfquery>
		</cfcase>

		<cfcase value="mysql,mysql5">
			<cfquery name="update" datasource="#arguments.dsn#">
				create table #arguments.dbowner#statsCountries (
					COUNTRY VARCHAR(255) NOT NULL,
					ISOCODE CHAR (2) NOT NULL
				)
			</cfquery>
		</cfcase>

		<cfcase value="postgresql">
			<cfquery name="update" datasource="#arguments.dsn#">
				create table #arguments.dbowner#statsCountries (
					COUNTRY VARCHAR(255) NOT NULL,
					ISOCODE CHAR (2) NOT NULL
				)
			</cfquery>
		</cfcase>
		
		<!--- TODO: move to gatway --->
		<cfcase value="HSQLDB">
			<cfquery name="update" datasource="#arguments.dsn#">
				create table statsCountries (
					COUNTRY VARCHAR(255) NOT NULL,
					ISOCODE CHAR(2) NOT NULL
				)
			</cfquery>
		</cfcase>

		<cfdefaultcase>
			<cfquery name="update" datasource="#arguments.dsn#">
				CREATE TABLE #arguments.dbowner#statsCountries (
					[Country] [varchar] (250) NOT NULL ,
					[ISOCode] [char] (2) NOT NULL
				)
			</cfquery>
		</cfdefaultcase>
	</cfswitch>

	<!--- add country code data --->
	<cfquery name="update" datasource="#arguments.dsn#">
		insert into statsCountries (country,isoCode) 
		values ('AFGHANISTAN ','AF'), 
			   ('ALBANIA','AL'), 
			   ('ALGERIA','DZ'), 
			   ('AMERICAN SAMOA','AS'), 
			   ('ANDORRA','AD'),
			   ('ANGOLA','AO'), 
			   ('ANGUILLA','AI'), 
			   ('ANTARCTICA','AQ'), 
			   ('ANTIGUA AND BARBUDA','AG'), 
			   ('ARGENTINA','AR'),
			   ('ARMENIA','AM'),
			   ('ARUBA','AW'),
			   ('AUSTRALIA','AU'),
			   ('AUSTRIA','AT'),
			   ('AZERBAIJAN','AZ'),
			   ('BAHAMAS','BS'),
			   ('BAHRAIN','BH'),
			   ('BANGLADESH','BD'),
			   ('BARBADOS','BB'),
			   ('BELARUS','BY'),
			   ('BELGIUM','BE'),
			   ('BELIZE','BZ'),
			   ('BENIN','BJ'),
			   ('BERMUDA','BM'),
			   ('BHUTAN','BT'),
			   ('BOLIVIA','BO'),
			   ('BOSNIA AND HERZEGOVINA','BA'),
			   ('BOTSWANA','BW'),
			   ('BOUVET ISLAND','BV'),
			   ('BRAZIL','BR'),
			   ('BRITISH INDIAN OCEAN TERRITORY','IO'),
			   ('BRUNEI DARUSSALAM','BN'),
			   ('BULGARIA','BG'),
			   ('BURKINA FASO','BF'),
			   ('BURUNDI','BI'),
			   ('CAMBODIA','KH'),
			   ('CAMEROON','CM'),
			   ('CANADA','CA'),
			   ('CAPE VERDE','CV'),
			   ('CAYMAN ISLANDS','KY'),
			   ('CENTRAL AFRICAN REPUBLIC','CF'),
			   ('CHAD','TD'),
			   ('CHILE','CL'),
			   ('CHINA','CN'),
			   ('CHRISTMAS ISLAND','CX'),
			   ('COCOS (KEELING) ISLANDS','CC'),
			   ('COLOMBIA','CO'),
			   ('COMOROS','KM'),
			   ('CONGO','CG'),
			   ('CONGO, THE DEMOCRATIC REPUBLIC OF THE','CD'),
			   ('COOK ISLANDS','CK'),
			   ('COSTA RICA','CR'),
			   ('COTE D''IVOIRE','CI'),
			   ('CROATIA','HR'),
			   ('CUBA','CU'),
			   ('CYPRUS','CY'),
			   ('CZECH REPUBLIC','CZ'),
			   ('DENMARK','DK'),
			   ('DJIBOUTI','DJ'),
			   ('DOMINICA','DM'),
			   ('DOMINICAN REPUBLIC','DO'),
			   ('ECUADOR','EC'),
			   ('EGYPT','EG'),
			   ('EL SALVADOR','SV'),
			   ('EQUATORIAL GUINEA','GQ'),
			   ('ERITREA','ER'),
			   ('ESTONIA','EE'),
			   ('ETHIOPIA','ET'),
			   ('FALKLAND ISLANDS (MALVINAS)','FK'),
			   ('FAROE ISLANDS','FO'),
			   ('FIJI','FJ'),
			   ('FINLAND','FI'),
			   ('FRANCE','FR'),
			   ('FRENCH GUIANA','GF'),
			   ('FRENCH POLYNESIA','PF'),
			   ('FRENCH SOUTHERN TERRITORIES','TF'),
			   ('GABON ','GA'),
			   ('GAMBIA','GM'),
			   ('GEORGIA','GE'),
			   ('GERMANY','DE'),
			   ('GHANA','GH'),
			   ('GIBRALTAR','GI'),
			   ('GREECE','GR'),
			   ('GREENLAND','GL'),
			   ('GRENADA','GD'),
			   ('GUADELOUPE','GP'),
			   ('GUAM','GU'),
			   ('GUATEMALA','GT'),
			   ('GUINEA','GN'),
			   ('GUINEA-BISSAU','GW'),
			   ('GUYANA','GY'),
			   ('HAITI','HT'),
			   ('HEARD ISLAND AND MCDONALD ISLANDS','HM'),
			   ('VATICAN CITY STATE','VA'),
			   ('HONDURAS','HN'),
			   ('HONG KONG','HK'),
			   ('HUNGARY','HU'),
			   ('ICELAND','IS'),
			   ('INDIA','IN'),
			   ('INDONESIA','ID'),
			   ('IRAN, ISLAMIC REPUBLIC OF','IR'),
			   ('IRAQ','IQ'),
			   ('IRELAND','IE'),
			   ('ISRAEL','IL'),
			   ('ITALY','IT'),
			   ('JAMAICA','JM'),
			   ('JAPAN','JP'),
			   ('JORDAN','JO'),
			   ('KAZAKHSTAN','KZ'),
			   ('KENYA','KE'),
			   ('KIRIBATI','KI'),
			   ('KOREA, DEMOCRATIC PEOPLE''S REPUBLIC OF','KP'),
			   ('KOREA, REPUBLIC OF','KR'),
			   ('KUWAIT','KW'),
			   ('KYRGYZSTAN','KG'),
			   ('LAO PEOPLE''S DEMOCRATIC REPUBLIC','LA'),
			   ('LATVIA','LV'),
			   ('LEBANON','LB'),
			   ('LESOTHO','LS'),
			   ('LIBERIA','LR'),
			   ('LIBYAN ARAB JAMAHIRIYA','LY'),
			   ('LIECHTENSTEIN','LI'),
			   ('LITHUANIA','LT'),
			   ('LUXEMBOURG','LU'),
			   ('MACAO','MO'),
			   ('MACEDONIA, THE FORMER YUGOSLAV REPUBLIC OF','MK'),
			   ('MADAGASCAR','MG'),
			   ('MALAWI','MW'),
			   ('MALAYSIA','MY'),
			   ('MALDIVES','MV'),
			   ('MALI','ML'),
			   ('MALTA','MT'),
			   ('MARSHALL ISLANDS','MH'),
			   ('MARTINIQUE','MQ'),
			   ('MAURITANIA','MR'),
			   ('MAURITIUS','MU'),
			   ('MAYOTTE','YT'),
			   ('MEXICO','MX'),
			   ('MICRONESIA, FEDERATED STATES OF','FM'),
			   ('MOLDOVA, REPUBLIC OF','MD'),
			   ('MONACO','MC'),
			   ('MONGOLIA','MN'),
			   ('MONTSERRAT','MS'),
			   ('MOROCCO','MA'),
			   ('MOZAMBIQUE','MZ'),
			   ('MYANMAR','MM'),
			   ('NAMIBIA','NA'),
			   ('NAURU','NR'),
			   ('NEPAL','NP'),
			   ('NETHERLANDS','NL'),
			   ('NETHERLANDS ANTILLES','AN'),
			   ('NEW CALEDONIA','NC'),
			   ('NEW ZEALAND','NZ'),
			   ('NICARAGUA','NI'),
			   ('NIGER','NE'),
			   ('NIGERIA','NG'),
			   ('NIUE','NU'),
			   ('NORFOLK ISLAND','NF'),
			   ('NORTHERN MARIANA ISLANDS','MP'),
			   ('NORWAY','NO'),
			   ('OMAN','OM'),
			   ('PAKISTAN','PK'),
			   ('PALAU','PW'),
			   ('PALESTINIAN TERRITORY, OCCUPIED','PS'),
			   ('PANAMA','PA'),
			   ('PAPUA NEW GUINEA','PG'),
			   ('PARAGUAY','PY'),
			   ('PERU','PE'),
			   ('PHILIPPINES','PH'),
			   ('PITCAIRN','PN'),
			   ('POLAND','PL'),
			   ('PORTUGAL','PT'),
			   ('PUERTO RICO','PR'),
			   ('QATAR','QA'),
			   ('REUNION','RE'),
			   ('ROMANIA','RO'),
			   ('RUSSIAN FEDERATION','RU'),
			   ('RWANDA','RW'),
			   ('SAINT HELENA ','SH'),
			   ('SAINT KITTS AND NEVIS','KN'),
			   ('SAINT LUCIA','LC'),
			   ('SAINT PIERRE AND MIQUELON','PM'),
			   ('SAINT VINCENT AND THE GRENADINES','VC'),
			   ('SAMOA','WS'),
			   ('SAN MARINO','SM'),
			   ('SAO TOME AND PRINCIPE','ST'),
			   ('SAUDI ARABIA','SA'),
			   ('SENEGAL','SN'),
			   ('SEYCHELLES','SC'),
			   ('SIERRA LEONE','SL'),
			   ('SINGAPORE','SG'),
			   ('SLOVAKIA','SK'),
			   ('SLOVENIA','SI'),
			   ('SOLOMON ISLANDS','SB'),
			   ('SOMALIA','SO'),
			   ('SOUTH AFRICA','ZA'),
			   ('SOUTH GEORGIA AND THE SOUTH SANDWICH ISLANDS','GS'),
			   ('SPAIN','ES'),
			   ('SRI LANKA','LK'),
			   ('SUDAN','SD'),
			   ('SURINAME','SR'),
			   ('SVALBARD AND JAN MAYEN','SJ'),
			   ('SWAZILAND','SZ'),
			   ('SWEDEN','SE'),
			   ('SWITZERLAND','CH'),
			   ('SYRIAN ARAB REPUBLIC','SY'),
			   ('TAIWAN, PROVINCE OF CHINA','TW'),
			   ('TAJIKISTAN','TJ'),
			   ('TANZANIA, UNITED REPUBLIC OF','TZ'),
			   ('THAILAND','TH'),
			   ('TIMOR-LESTE','TL'),
			   ('TOGO','TG'),
			   ('TOKELAU','TK'),
			   ('TONGA','TO'),
			   ('TRINIDAD AND TOBAGO','TT'),
			   ('TUNISIA','TN'),
			   ('TURKEY','TR'),
			   ('TURKMENISTAN','TM'),
			   ('TURKS AND CAICOS ISLANDS','TC'),
			   ('TUVALU','TV'),
			   ('UGANDA','UG'),
			   ('UKRAINE','UA'),
			   ('UNITED ARAB EMIRATES','AE'),
			   ('UNITED KINGDOM','GB'),
			   ('UNITED STATES','US'),
			   ('UNITED STATES MINOR OUTLYING ISLANDS','UM'),
			   ('URUGUAY','UY'),
			   ('UZBEKISTAN','UZ'),
			   ('VANUATU','VU'),
			   ('VENEZUELA','VE'),
			   ('VIET NAM','VN'),
			   ('VIRGIN ISLANDS, BRITISH','VG'),
			   ('VIRGIN ISLANDS, U.S.','VI'),
			   ('WALLIS AND FUTUNA','WF'),
			   ('WESTERN SAHARA','EH'),
			   ('YEMEN','YE'),
			   ('YUGOSLAVIA','YU'),
			   ('ZAMBIA','ZM'),
			   ('ZIMBABWE','ZW');
	</cfquery>

	<cfset stStatus.message = "stats created.">
	<cfset stStatus.detail = "stats created.">
       <cfset stStatus.bSuccess = "true">
	<cfset stStatus.status = "true">
</cfif>

<!--- deploy stats search table --->
<cfswitch expression="#arguments.dbtype#">
	<cfcase value="ora">
		<!--- check search stats table exists, for later --->
		<cfquery datasource="#arguments.dsn#" name="qCheck">
			SELECT count(*) AS tblExists FROM USER_TABLES
			WHERE TABLE_NAME = 'STATSSEARCH'
		</cfquery>

		<cfif qCheck.tblExists>
			<cfquery datasource="#arguments.dsn#" name="qDrop">
				DROP TABLE #arguments.dbowner#statsSearch
			</cfquery>
		</cfif>

		<!--- create the stats --->
		<cfscript>
			sql = "CREATE TABLE #arguments.dbowner#STATSSEARCH (
LOGID VARCHAR2(50) NOT NULL ,
SEARCHSTRING VARCHAR2(255) NOT NULL ,
LCOLLECTIONS VARCHAR2(1024) NOT NULL ,
RESULTS NUMBER NOT NULL,
REMOTEIP VARCHAR2(50) NOT NULL,
LOGDATETIME date NOT NULL,
REFERER VARCHAR2(1024) NOT NULL,
LOCALE VARCHAR2(100) NOT NULL,
CONSTRAINT PK_STATSSEARCH PRIMARY KEY (LOGID))
";
		</cfscript>

		<cfquery datasource="#arguments.dsn#" name="qCreate">
			#sql#
		</cfquery>
		<cfscript>
			sql = "CREATE INDEX #arguments.dbowner#IDX_STATSSEARCH ON #arguments.dbowner#STATSSEARCH(searchstring,logdatetime)";
		</cfscript>
		<cfquery datasource="#arguments.dsn#" name="qCreate">
			#sql#
		</cfquery>

	</cfcase>
	<cfcase value="mysql,mysql5">

		<cfquery datasource="#arguments.dsn#" name="qDrop">
			DROP TABLE IF EXISTS #arguments.dbowner#statsSearch
		</cfquery>

		<!--- create the stats --->
		<cfscript>
			sql = "CREATE TABLE #arguments.dbowner#statsSearch (
LOGID VARCHAR(50) NOT NULL ,
SEARCHSTRING VARCHAR(255) NOT NULL ,
LCOLLECTIONS TEXT ,
RESULTS INTEGER NOT NULL,
REMOTEIP VARCHAR(50) NOT NULL,
LOGDATETIME datetime NOT NULL,
REFERER TEXT,
LOCALE VARCHAR(100) NOT NULL,
CONSTRAINT PK_STATSSEARCH PRIMARY KEY (LOGID))
";
		</cfscript>

		<cfquery datasource="#arguments.dsn#" name="qCreate">
			#sql#
		</cfquery>
		<cfscript>
			sql = "CREATE INDEX #arguments.dbowner#IDX_STATSSEARCH ON #arguments.dbowner#statsSearch(searchString,logdatetime)";
		</cfscript>
		<cfquery datasource="#arguments.dsn#" name="qCreate">
			#sql#
		</cfquery>

	</cfcase>

	<cfcase value="postgresql">

		<cftry><cfquery datasource="#arguments.dsn#" name="qDrop">
			DROP TABLE #arguments.dbowner#statsSearch
		</cfquery><cfcatch></cfcatch></cftry>

		<!--- create the stats --->
		<cfscript>
			sql = "CREATE TABLE #arguments.dbowner#statsSearch (
LOGID VARCHAR(50) NOT NULL PRIMARY KEY,
SEARCHSTRING VARCHAR(255) NOT NULL ,
LCOLLECTIONS TEXT ,
RESULTS INT NOT NULL,
REMOTEIP VARCHAR(50) NOT NULL,
LOGDATETIME timestamp NOT NULL,
REFERER TEXT,
LOCALE VARCHAR(100) NOT NULL)
";
		</cfscript>

		<cfquery datasource="#arguments.dsn#" name="qCreate">
			#sql#
		</cfquery>
		<cfscript>
			sql = "CREATE INDEX #arguments.dbowner#IDX_STATSSEARCH ON #arguments.dbowner#statsSearch(searchString,logdatetime)";
		</cfscript>
		<cfquery datasource="#arguments.dsn#" name="qCreate">
			#sql#
		</cfquery>

	</cfcase>
	
	
	<cfcase value="HSQLDB">
		<cfquery datasource="#arguments.dsn#" name="qDrop">
			DROP TABLE statsSearch IF EXISTS;
		</cfquery>

		<!--- create the stats --->
		<cfscript>
			sql = "CREATE TABLE statsSearch (
LOGID VARCHAR(50) NOT NULL PRIMARY KEY,
SEARCHSTRING VARCHAR(255) NOT NULL ,
LCOLLECTIONS LONGVARCHAR,
RESULTS INT NOT NULL,
REMOTEIP VARCHAR(50) NOT NULL,
LOGDATETIME TIMESTAMP NOT NULL,
REFERER LONGVARCHAR,
LOCALE VARCHAR(100) NOT NULL)
";
		</cfscript>

		<cfquery datasource="#arguments.dsn#" name="qCreate">
			#sql#
		</cfquery>
		<cfscript>
			sql = "CREATE INDEX IDX_STATSSEARCH ON statsSearch(searchString,logdatetime)";
		</cfscript>
		<cfquery datasource="#arguments.dsn#" name="qCreate">
			#sql#
		</cfquery>
	</cfcase>
	

	<cfdefaultcase>

		<cfquery datasource="#arguments.dsn#" name="qDrop">
		if exists (select * from sysobjects where name = 'statsSearch')
		DROP TABLE statsSearch

		-- return recordset to stop CF bombing out?!?
		select count(*) as blah from sysobjects
		</cfquery>


		<!--- create the stats --->
		<cfquery datasource="#arguments.dsn#" name="qCreate">
		CREATE TABLE #arguments.dbowner#statsSearch (
			[logId] [varchar] (50) NOT NULL ,
			[searchString] [varchar] (255) NOT NULL ,
			[lCollections] [varchar] (1024) NOT NULL ,
			[results] [int] NOT NULL,
			[remoteip] [varchar] (50) NOT NULL ,
			[referer] [varchar] (1024) NOT NULL ,
			[locale] [varchar] (100) NOT NULL ,
			[logDateTime] [datetime] NOT NULL
		) ON [PRIMARY];

		ALTER TABLE #arguments.dbowner#statsSearch WITH NOCHECK ADD
			CONSTRAINT [PK_statsSearch] PRIMARY KEY CLUSTERED
			(
				[logId]
			)  ON [PRIMARY];

		CREATE NONCLUSTERED INDEX [statsSearch0] ON #arguments.dbowner#statsSearch([searchString], [logdatetime])
		</cfquery>

	</cfdefaultcase>
</cfswitch>