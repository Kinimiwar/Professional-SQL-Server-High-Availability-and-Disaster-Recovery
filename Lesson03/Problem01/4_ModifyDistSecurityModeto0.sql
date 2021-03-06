:setvar Publisher "Neptune\SQL2016"
:setvar Subscriber "Neptune\SQL2014"
:setvar Distributor "Neptune\SQL2016"
:setvar DatabaseName "AdventureWorks"
:setvar PublicationName "AdventureWorks-Tran_Pub"
:setvar Property "distributor_security_mode"
:setvar Value "1"

:CONNECT $(Subscriber)

USE $(DatabaseName)

EXECUTE sp_change_subscription_properties 
	@publisher="$(Publisher)",
	@publisher_db="$(DatabaseName)",
	@publication = "$(PublicationName)",
	@property= "$(Property)",
	@value = 0

EXECUTE sp_change_subscription_properties 
	@publisher="$(Publisher)",
	@publisher_db="$(DatabaseName)",
	@publication = "$(PublicationName)",
	@property= 'distributor_login',
	@value = 'repluser'


EXECUTE sp_change_subscription_properties 
	@publisher="$(Publisher)",
	@publisher_db="$(DatabaseName)",
	@publication = "$(PublicationName)",
	@property= 'distributor_password',
	@value = 'repl@User123'
