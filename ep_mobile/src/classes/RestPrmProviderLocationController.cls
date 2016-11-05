/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v1/Providers/*/Locations')
global with sharing class RestPrmProviderLocationController {

    @HttpGet
    global static List<RestPrmLocationController.Location> doGet() {
        return RestPrmProviderLocationController.performGetSearch();
    }
    
    public static Map<String, String> fieldMap {
        get {
           return uRestController.remapFields(RestPrmProviderLocationController.propertyMap);
        }
    }
    
    private static Map<String, String> localPropertyMap {
        get {
            return new Map<String, String> {
                'id' => 'id',
                'phone' => 'HC4__Location__r.HC4__Phone__c',
                'fax' => 'HC4__Location__r.HC4__Fax__c',
                'email' => 'HC4__Location__r.HC4__Email__c'
            };
        }
    }
    
    public static Map<String, String> propertyMap {
        get {
            if(propertyMap == null) {
                propertyMap = localPropertyMap;
            }
            
            return propertyMap;
        }
        
        private set;
    }

    private static List<RestPrmLocationController.Location> performGetSearch() {
        return RestPrmProviderLocationController.performGetSearch(null);
    }
    
    public static List<RestPrmLocationController.Location> performGetSearch(List<HC4.uCondition> additionalConditions) {
        List<String> conditions = new List<String>();
        
        String providerId = uRestController.getParentObjectId('Providers/');
        conditions.add(new HC4.uCondition('HC4__ProviderLocation__c', 'HC4__Provider__c', '=', providerId).toSql());
        
        if(additionalConditions != null) {
            for(HC4.uCondition c : additionalConditions) {
                conditions.add(c.toSql());
            }
        }
        
        conditions.addAll(uRestController.propertyMapToSoql(RestPrmProviderLocationController.propertyMap, 'HC4__ProviderLocation__c'));
        
        Integer pageSize = uRestController.pageSize;
        Integer offSet = uRestController.offset;
        
        List<HC4__ProviderLocation__c> result = 
                    (List<HC4__ProviderLocation__c>)Database.query(RestPrmProviderLocationController.generateLocationSql(conditions));
        
        List<RestPrmLocationController.Location> response = new List<RestPrmLocationController.Location>();
        for(HC4__ProviderLocation__c s : result) {
            response.add(new RestPrmLocationController.Location(s));
        }
        //Check the location is already mapped with Territory Locaiton - PRM-532
        Map<Id, List<HC4__ProviderLocationTerritory__c>> territoryplts = new Map<Id, List<HC4__ProviderLocationTerritory__c>>(); 
        if(!String.isBlank(uRestController.getParameterValue('territoryId'))) {
        	String tId = uRestController.getParameterValue('territoryId');
        	territoryplts = checkTerritoryLocationMapping(tId);  
        	for(RestPrmLocationController.Location loc : response){        		
        		if(territoryplts != null && territoryplts.size() > 0){        			
        				List<HC4__ProviderLocationTerritory__c> plts = territoryplts.get(tId);        				
        				for(HC4__ProviderLocationTerritory__c plt : plts){
        					if(plt.HC4__Territory__c == tId && plt.HC4__ProviderLocation__r.HC4__Provider__c == providerId && loc.Id == plt.HC4__ProviderLocation__r.HC4__Location__c){
        						loc.territoryMapped = true;
        					}
        				}        				       			
        		}        		
        	}
        }
        
        uRestController.setPagingHeaders(pageSize, offSet, response.size());
        return response;
    }
    
    private static String generateLocationSql(List<String> filters) {
        if(filters == null) {
            filters = new List<String>();
        }
        
        String sql = 'Select HC4__IsPrimary__c, HC4__Location__r.Id, HC4__Location__r.HC4__Phone__c,' +
                     'HC4__Location__r.HC4__Fax__c, HC4__Location__r.HC4__Email__c, HC4__Location__r.HC4__OtherStreet__c, ' +
                     'HC4__Location__r.HC4__OtherCity__c, HC4__Location__r.HC4__OtherState__c, HC4__Location__r.HC4__OtherPostalCode__c, ' +
                     'HC4__Location__r.HC4__OtherCountry__c, HC4__Location__r.HC4__MailingStreet__c, HC4__Location__r.HC4__MailingCity__c,' +
                     'HC4__Location__r.HC4__MailingState__c, HC4__Location__r.HC4__MailingPostalCode__c, HC4__Location__r.HC4__MailingCountry__c, ' +
                     'HC4__Location__r.HC4__Practice__c, HC4__Location__r.HC4__PracticeName__c, HC4__Location__r.CreatedDate,' +
                     'HC4__Location__r.CreatedBy.Id, HC4__Location__r.CreatedBy.Name, HC4__Location__r.LastModifiedDate,' +
                     'HC4__Location__r.LastModifiedBy.Id, HC4__Location__r.LastModifiedBy.Name from HC4__ProviderLocation__c';
                     
       if(filters.size() > 0 ) {
         sql += (' WHERE ' + HC4.uList.join(filters, ' AND '));
       }
       sql += uRestController.decodeSortForSoql('name', RestPrmProviderLocationController.propertyMap);
       sql += ' LIMIT :pageSize OFFSET :offset';
       
       System.debug(LoggingLevel.ERROR, sql);
       return sql;
    }
    
    public static Map<Id,List<HC4__ProviderLocationTerritory__c>> checkTerritoryLocationMapping(String territoryId){
    	    	
    	Map<Id, List<HC4__ProviderLocationTerritory__c>> territoryplts = new Map<Id, List<HC4__ProviderLocationTerritory__c>>();   
        
        for(HC4__ProviderLocationTerritory__c plt : [Select Id,HC4__Territory__c, HC4__ProviderLocation__c, HC4__ProviderLocation__r.HC4__Provider__c, HC4__ProviderLocation__r.HC4__Location__c From HC4__ProviderLocationTerritory__c where HC4__Territory__c =: territoryId]){        	        
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
    	
    	return territoryplts;
    }
}