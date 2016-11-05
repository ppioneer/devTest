/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v2/Territories/*/ProviderLocations')
global with sharing class RestPrmTerritoryProviderLocController {

	@HttpGet
    global static List<RestPrmLocationController.Location> doGet() {
    	RestPrmLocationController prmLocations = new RestPrmLocationController(); 
    	String territoryId = uRestController.getParentObjectId('Territories/');
        
        List<HC4__ProviderLocationTerritory__c> p = [Select HC4__ProviderLocation__r.HC4__Provider__c, HC4__ProviderLocation__r.HC4__Location__c from 
                                             HC4__ProviderLocationTerritory__c where HC4__Territory__c = :territoryId];
                                             
        Set<id> locationIds = new Set<Id>();
	    for(HC4__ProviderLocationTerritory__c plt : p) {
	        locationIds.add(plt.HC4__ProviderLocation__r.HC4__Location__c);
	    }
	    
	    List<HC4.uCondition> conditions = new List<HC4.uCondition>();
	    
	    if(locationIds != null && !locationIds.isEmpty()){
	    	conditions.add(new HC4.uCondition('HC4__Location__c', 'Id', 'IN', HC4.uSet.joinForIn(locationIds)));	
	    }
        
        if(!String.isBlank(uRestController.getParameterValue('mailingCity'))) {
            String mailingCity = uRestController.getParameterValue('mailingCity');
            Set<String> cities = new Set<String>();            
            for(String city : mailingCity.split(';')) {
            	if(!String.isBlank(city)){
                	cities.add(city);
            	}
            }
            conditions.add(new HC4.uCondition('HC4__Location__c', 'HC4__MailingCity__c', 'IN', HC4.uSet.joinForIn(cities)));
        }
        
        if(!String.isBlank(uRestController.getParameterValue('mailingState'))) {
            String mailingState = uRestController.getParameterValue('mailingState');            
            Set<String> states = new Set<String>();            
            for(String state : mailingState.split(';')) {
            	if(!String.isBlank(state)){
                	states.add(state);
            	}
            }
            conditions.add(new HC4.uCondition('HC4__Location__c', 'HC4__MailingState__c', 'IN', HC4.uSet.joinForIn(states)));
        }
        
        if(!String.isBlank(uRestController.getParameterValue('zipCode'))) {
            String zipCode = uRestController.getParameterValue('zipCode');            
            Set<String> zips = new Set<String>();            
            for(String zip : zipCode.split(';')) {
            	if(!String.isBlank(zip)){
                	zips.add(zip);
            	}
            }
            conditions.add(new HC4.uCondition('HC4__Location__c', 'HC4__MailingPostalCode__c', 'IN', HC4.uSet.joinForIn(zips)));
        }
        
        
        return RestPrmLocationController.performGetSearch(conditions);
    }

}