:setvar Publisher "Windows10Ent\SQL2016"
:setvar Subscriber "Windows10Ent\SQL2014"
:setvar Distributor "Windows10Ent\SQL2016"
:setvar DatabaseName "AdventureWorks"
:setvar PublicationName "Pub-AdventureWorks"

-- connect to the publisher and set replication options
:CONNECT $(Publisher)
USE "$(DatabaseName)"

-- Enable database for publication
EXEC sp_replicationdboption 
  @dbname = "$(DatabaseName)", 
  @optname = N'publish', 
  @value = N'true' 

-- Create the log reader agent
-- If this isn't specified, log reader agent is implicily created 
-- by the sp_addpublication procedure
EXEC sp_addlogreader_agent 
	@job_login = NULL, 
	@job_password = NULL,
	@publisher_security_mode = 1;
GO
-- Create publication 
EXEC sp_addpublication 
  @publication = "$(PublicationName)", 
  @description = 
N'Transactional publication of database ''AdventureWorks'' from Publisher ''Windows10Ent\SQL2016''.'
, 
@sync_method = N'concurrent', 
@retention = 0, 
@allow_push = N'true', 
@allow_pull = N'true', 
@allow_anonymous = N'true', 
@snapshot_in_defaultfolder = N'true', 
@compress_snapshot = N'false',
@repl_freq = N'continuous', 
@status = N'active', 
@independent_agent = N'true', 
@immediate_sync = N'true', 
@replicate_ddl = 1

GO

-- Create the snapshot agent
EXEC sp_addpublication_snapshot 
  @publication = "$(PublicationName)", 
  @frequency_type = 1, 
  @frequency_interval = 1, 
  @frequency_relative_interval = 1, 
  @frequency_recurrence_factor = 0, 
  @frequency_subday = 8, 
  @frequency_subday_interval = 1, 
  @active_start_time_of_day = 0, 
  @active_end_time_of_day = 235959, 
  @active_start_date = 0, 
  @active_end_date = 0, 
  @job_login = NULL, 
  @job_password = NULL, 
  @publisher_security_mode = 1 

EXEC sp_addarticle 
  @publication = "$(PublicationName)", 
  @article = N'SalesOrderDetail', 
  @source_owner = N'Sales', 
  @source_object = N'SalesOrderDetail', 
  @type = N'logbased', 
  @description = NULL, 
  @creation_script = NULL, 
  @pre_creation_cmd = N'drop', 
  @schema_option = 0x000000000803509F, 
  @identityrangemanagementoption = N'manual', 
  @destination_table = N'SalesOrderDetail', 
  @destination_owner = N'Sales', 
  @vertical_partition = N'false', 
  @ins_cmd = N'CALL sp_MSins_SalesSalesOrderDetail', 
  @del_cmd = N'CALL sp_MSdel_SalesSalesOrderDetail', 
  @upd_cmd = N'SCALL sp_MSupd_SalesSalesOrderDetail' 

GO



EXEC sp_addarticle 
  @publication = "$(PublicationName)", 
  @article = N'SalesOrderHeader', 
  @source_owner = N'Sales', 
  @source_object = N'SalesOrderHeader', 
  @type = N'logbased', 
  @description = NULL, 
  @creation_script = NULL, 
  @pre_creation_cmd = N'drop', 
  @schema_option = 0x000000000803509F, 
  @identityrangemanagementoption = N'manual', 
  @destination_table = N'SalesOrderHeader', 
  @destination_owner = N'Sales', 
  @vertical_partition = N'false', 
  @ins_cmd = N'CALL sp_MSins_SalesSalesOrderHeader', 
  @del_cmd = N'CALL sp_MSdel_SalesSalesOrderHeader', 
  @upd_cmd = N'SCALL sp_MSupd_SalesSalesOrderHeader' 

GO

-- Start the snapshot agent job so as to generate the snapshot.
-- This will cause the subscriber to sync immediately (if this option is selected when
-- creating the subscriber)
-- Get the snapshot agent job name from the distribution database

DECLARE @jobname NVARCHAR(200)
SELECT @jobname=name FROM [distribution].[dbo].[MSsnapshot_agents]
WHERE [publication]='$(PublicationName)' AND [publisher_db]='$(DatabaseName)'

Print 'Starting Snapshot Agent ' + @jobname + '....'

-- Start the snapshot agent to generate the snapshot
-- The snapshot is picked up and applied to the subscriber by the distribution agent
EXECUTE msdb.dbo.sp_start_job @job_name=@jobname

