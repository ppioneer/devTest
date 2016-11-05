/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v1/Territories/myTerritories')
global with sharing class RestPrmTerritoryMyTerritoriesController {
     @HttpGet
    global static List<RestPrmTerritoryController.Territory> doGet() {    	
    	List<HC4.uCondition> additionalConditions = new List<HC4.uCondition>();
        additionalConditions.add(new HC4.uCondition('HC4__Territory__c', 'OwnerId', '=', UserInfo.getUserId()));
        //PRM-102
        List<RestPrmTerritoryController.Territory> response = new List<RestPrmTerritoryController.Territory>();
        Set<Id> territoryIds = new Set<Id>();
        Map<Id, List<HC4__ProviderLocationTerritory__c>> territoryplts = new Map<Id, List<HC4__ProviderLocationTerritory__c>>(); // Terrritory and PLT        
        
        for(RestPrmTerritoryController.Territory t : RestPrmTerritoryController.performGetSearch(additionalConditions)){
        	territoryIds.add(t.Id);
        }     
        
        for(HC4__ProviderLocationTerritory__c plt : [Select Id,HC4__Territory__c, HC4__ProviderLocation__c, HC4__ProviderLocation__r.HC4__Provider__c From HC4__ProviderLocationTerritory__c where HC4__Territory__c IN : territoryIds]){        	        
        	        List<HC4__ProviderLocationTerritory__c> lstplt = territoryplts.get(plt.HC4__Territory__c); 
        			if(territoryplts.get(plt.HC4__Territory__c) == null){
	         			lstplt = new List<HC4__ProviderLocationTerritory__c>();	         			
	         			lstplt.add(plt);
	         			territoryplts.put(plt.HC4__Territory__c, lstplt);	         			 	         			 
	         		}
	         		else{	         			
	         			lstplt.add(plt);
	         		}
        }
        
        /* Providers count for Territory */  
        for(RestPrmTerritoryController.Territory t : RestPrmTerritoryController.performGetSearch(additionalConditions)){
        	 if(territoryplts != null && territoryplts.get(t.Id) != null){
        	 	Set<Id> providers = new Set<Id>();
        	 	for(HC4__ProviderLocationTerritory__c plt : territoryplts.get(t.Id)){
        	 		if(plt.HC4__ProviderLocation__c != null && plt.HC4__ProviderLocation__r.HC4__Provider__c != null){
        	 			providers.add(plt.HC4__ProviderLocation__r.HC4__Provider__c);
        	 		}
        	 	}        	 	
        	 	t.providersCount = providers.size(); 
        	 }        	 
        	 response.add(t);
        }        
        return response;
    }    
}