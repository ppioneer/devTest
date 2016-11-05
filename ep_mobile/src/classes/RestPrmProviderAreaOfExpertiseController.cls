/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v1/Providers/*/AreasOfExpertise')
global with sharing class RestPrmProviderAreaOfExpertiseController {
    
    @HttpGet
    global static List<RestPrmAreaOfExpertiseController.AreaOfExpertise> doGet() {        
            return RestPrmProviderAreaOfExpertiseController.performGetSearch();
    }
    
    public static Map<String, String> fieldMap {
        get {
           return uRestController.remapFields(RestPrmProviderAreaOfExpertiseController.propertyMap);
        }
    }
    
    private static Map<String, String> localPropertyMap {
        get {
            return new Map<String, String> {
                'id' => 'HC4__AreaOfExpertise__r.id',
                'name' => 'HC4__AreaOfExpertise__r.Name',
                'code' => 'HC4__AreaOfExpertise__r.HC4__Code__c'
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

    private static List<RestPrmAreaOfExpertiseController.AreaOfExpertise> performGetSearch() {    	
        return RestPrmProviderAreaOfExpertiseController.performGetSearch(null);
    }
    
    public static List<RestPrmAreaOfExpertiseController.AreaOfExpertise> performGetSearch(List<HC4.uCondition> additionalConditions) {
        List<String> conditions = new List<String>();
        
        String providerId = uRestController.getParentObjectId('Providers/');
        conditions.add(new HC4.uCondition('HC4__ProviderAreaOfExpertise__c', 'HC4__Provider__c','=', providerId).toSql());
                	
        if(additionalConditions != null) {
            for(HC4.uCondition c : additionalConditions) {
                conditions.add(c.toSql());
            }
        }
        
        conditions.addAll(uRestController.propertyMapToSoql(RestPrmProviderAreaOfExpertiseController.propertyMap, 'HC4__ProviderAreaOfExpertise__c'));
        
        Integer pageSize = uRestController.pageSize;
        Integer offSet = uRestController.offset;
        
        List<HC4__ProviderAreaOfExpertise__c> result = 
                    (List<HC4__ProviderAreaOfExpertise__c>)Database.query(RestPrmProviderAreaOfExpertiseController.generateAreaOfExpertiseSql(conditions));
        
        List<RestPrmAreaOfExpertiseController.AreaOfExpertise> response = new List<RestPrmAreaOfExpertiseController.AreaOfExpertise>();
        for(HC4__ProviderAreaOfExpertise__c s : result) {
            response.add(new RestPrmAreaOfExpertiseController.AreaOfExpertise(s));
        }
        
        uRestController.setPagingHeaders(pageSize, offSet, response.size());
        return response;
    }
    
    private static String generateAreaOfExpertiseSql(List<String> filters) {
        if(filters == null) {
            filters = new List<String>();
        }
        
        String sql = 'Select HC4__IsPrimary__c, HC4__AreaOfExpertise__r.Id, HC4__AreaOfExpertise__r.Name,' +
                     'HC4__AreaOfExpertise__r.HC4__Code__c, HC4__AreaOfExpertise__r.CreatedDate, HC4__AreaOfExpertise__r.CreatedBy.Id, ' +
                     'HC4__AreaOfExpertise__r.CreatedBy.Name, HC4__AreaOfExpertise__r.LastModifiedDate, HC4__AreaOfExpertise__r.LastModifiedBy.Id,' +
                     'HC4__AreaOfExpertise__r.LastModifiedBy.Name from HC4__ProviderAreaOfExpertise__c';
                     
       if(filters.size() > 0 ) {
         sql += (' WHERE ' + HC4.uList.join(filters, ' AND '));
       }
       sql += uRestController.decodeSortForSoql('name', RestPrmProviderAreaOfExpertiseController.propertyMap);
       sql += ' LIMIT :pageSize OFFSET :offset';
       
       System.debug(LoggingLevel.ERROR, sql);
       return sql;
    }
}