/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v1/Providers/*/Territories/*')
global with sharing class RestPrmProviderTerritoryController {
    @HttpGet
    global static List<RestPrmTerritoryController.Territory> doGet() {
    	String providerId = uRestController.getParentObjectId('Providers/');
    	List<HC4__ProviderLocationTerritory__c> p = [Select HC4__Territory__c from 
                                             HC4__ProviderLocationTerritory__c where HC4__ProviderLocation__r.HC4__Provider__c = :providerId];
                                             
         Set<id> territoryIds = new Set<Id>();
         for(HC4__ProviderLocationTerritory__c pl : p) {
            territoryIds.add(pl.HC4__Territory__c);
         }
         
	     List<HC4.uCondition> conditions = new List<HC4.uCondition>();
	     conditions.add(new HC4.uCondition('HC4__Territory__c', 'Id', 'IN', HC4.uSet.joinForIn(territoryIds)));
         
        List<RestPrmTerritoryController.Territory> response = new List<RestPrmTerritoryController.Territory>();        
        Map<Id, List<HC4__ProviderLocationTerritory__c>> territoryplts = new Map<Id, List<HC4__ProviderLocationTerritory__c>>(); // Terrritory and PLT  
        
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
        for(RestPrmTerritoryController.Territory t : RestPrmTerritoryController.performGetSearch(conditions)){
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