/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v1/Territories/*/Providers')
global with sharing class RestPrmTerritoryProviderController {
    @HttpGet
    global static List<RestPrmProviderController.Provider> doGet() {
        String territoryId = uRestController.getParentObjectId('Territories/');
        
        List<HC4__ProviderLocationTerritory__c> p = [Select HC4__ProviderLocation__r.HC4__Provider__c from 
                                             HC4__ProviderLocationTerritory__c where HC4__Territory__c = :territoryId];
                                             
         Set<id> providerIds = new Set<Id>();
         for(HC4__ProviderLocationTerritory__c plt : p) {
            providerIds.add(plt.HC4__ProviderLocation__r.HC4__Provider__c);
         }
         
         List<HC4.uCondition> conditions = new List<HC4.uCondition>();
         conditions.add(new HC4.uCondition('Contact', 'Id', 'IN', HC4.uSet.joinForIn(providerIds)));
         
         return RestPrmProviderController.performGetSearch(conditions, true);
    }
    
    //PRM-532
    @HttpPost
    global static RestPrmTerritoryProviderController.Territory doPost(RestPrmTerritoryProviderController.Territory data) {
    	RestPrmTerritoryProviderController.Territory response = new RestPrmTerritoryProviderController.Territory(); 
    	List<HC4__ProviderLocationTerritory__c> lstPLT = new List<HC4__ProviderLocationTerritory__c>(); 
    	
    	if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest); 
           return null;
        }
        else{        	 
        	 Set<String> providerIds = new Set<String>();
        	 Set<String> territoryIds = new Set<String>();
        	         	       	 
        	 for(RestPrmTerritoryProviderController.TerritoryProviders tp : data.territoryInfo){
        	 	providerIds.add(tp.providerId);
        	 }        	 
        	       	        	
        	 for(Contact provider :[SELECT Id, Name, (SELECT Id, HC4__Provider__c, HC4__Location__c  FROM HC4__ProviderLocations__r) FROM Contact WHERE Id IN :providerIds ORDER BY Name]){           		
           		if(provider.HC4__ProviderLocations__r.isEmpty()){
           			response.responseCode = uRestController.BadRequest; 
					response.responseMessage = provider.Name + ' has no Provider Locations. Please create Provider Location records before adding to your territories.'; 
           		}
           		else {
           			list<String> deleteplts = new list<String>();
           			//Add the providers to Territories           			
			        for(RestPrmTerritoryProviderController.TerritoryProviders t : data.territoryInfo) {
			        	if(t.providerLocations != null && t.providerLocations.size() > 0 ){
			        		for(String pl : t.providerLocations){
			        			lstPLT.add(new HC4__ProviderLocationTerritory__c(HC4__ProviderLocation__c = pl, HC4__Territory__c = t.territoryId));
			        		}
			        	}
			        	if(t.deletepls != null && t.deletepls.size() > 0){
			        		territoryIds.add(t.territoryId); 
			        		deleteplts.addAll(t.deletepls);
			        	}			             
			        }
			        
			        //Delete the existing Territory mapping
			        if(deleteplts.size() > 0 ){			        	
			        	try{			        		
			        		delete [select id from HC4__ProviderLocationTerritory__c where HC4__ProviderLocation__c IN: deleteplts AND HC4__Territory__c IN :territoryIds]; 
			        	}
			        	catch (System.DmlException ex) {
				        	System.debug(LoggingLevel.ERROR, ex);
				            response.responseMessage = ex.getDmlMessage(0); 
			        		response.responseCode = uRestController.BadRequest;
				        }
			        	catch(Exception ex){
			        		response.responseMessage = ex.getMessage(); 
			        		response.responseCode = uRestController.BadRequest; 
			        	} 
			        }
			        
			        if(lstPLT.size() > 0){
			        	try{
			        		insert lstPLT;			        				        		
			        		response.responseMessage = 'Created.'; 
			        		response.responseCode = uRestController.Created; 
			        	}
			        	catch (System.DmlException ex) {
				        	System.debug(LoggingLevel.ERROR, ex);
				            response.responseMessage = ex.getDmlMessage(0); 
			        		response.responseCode = uRestController.BadRequest;
				        }
			        	catch(Exception ex){
			        		response.responseMessage = ex.getMessage(); 
			        		response.responseCode = uRestController.BadRequest; 
			        	}
			        }	
           		}
           	 }
        }
        
        return response;
    }
    
    global class Territory {
    	public List<RestPrmTerritoryProviderController.TerritoryProviders> territoryInfo { get; set; }
    	public uRestController.StatusCode responseCode { get; set; }
    	public String responseMessage { get { return String.isBlank(this.responseMessage) ? uString.EMPTY : this.responseMessage; } set; } 
    }
    
    global class TerritoryProviders {
    	public String territoryId { get { return String.isBlank(this.territoryId) ? uString.EMPTY : this.territoryId; } set; }
    	public String providerId { get { return String.isBlank(this.providerId) ? uString.EMPTY : this.providerId; } set; }
    	public List<String> providerLocations { get; set; }
    	public List<String> deletepls { get; set; }	
    }
     
}