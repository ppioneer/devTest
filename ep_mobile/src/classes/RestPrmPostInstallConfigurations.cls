/* Copyright (c) 2008-2014 Evariant */
global class RestPrmPostInstallConfigurations implements InstallHandler {
	
	global void onInstall(InstallContext context) {
		String nsPrefix = uString.Empty;
		String soql = uString.Empty;
        String filedName = 'EmailNotifyDomain__c';
        String objectName =  'PRMConfig__c';
        
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        sObject config = null;
        List<sObject> configs = new List<sObject>(); 
        for(Schema.SObjectType typeof: gd.values()){
        	String sTemp = String.valueOf(typeof);
        	if(sTemp.toLowerCase() == 'hc4m__prmconfig__c'){ 
	        	nsPrefix = 'HC4M';
	        	break;                
	        }
        }        
        if(!String.isBlank(nsPrefix)){
        	filedName = nsPrefix + '__'  + filedName;
        	objectName = nsPrefix + '__'  + objectName; 
        }
                 
        soql += 'SELECT Name, ' + filedName + ' From ' + objectName; 
        System.debug(LoggingLevel.ERROR, soql);
        
        configs = Database.query(soql);
        
        if(configs.isEmpty() || Test.isRunningTest()){ //Check if Config record exist?, if not create PRM Go! record
        	config = Schema.getGlobalDescribe().get(objectName).newSObject();
        	config.put('Name', 'NotifyEmailDomain');
        	config.put(filedName, 'All');        	
        	insert config; 
        	System.debug(LoggingLevel.ERROR, 'PRMGo!>>Custom Setting created.');
        }
        
	}	
}