/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v1/Providers/*/Territories/*/Locations')
global with sharing class RestPrmProviderTerrLocController {
    @HttpGet
    global static List<RestPrmLocationController.Location> doGet() {
    	return RestPrmProviderTerrLocController.performGetSearch();
    }
    
    public static Map<String, String> fieldMap {
        get {
           return uRestController.remapFields(RestPrmProviderTerrLocController.propertyMap);
        }
    }
    
    private static Map<String, String> localPropertyMap {
        get {
            return new Map<String, String> {
                'id' => 'HC4__ProviderLocation__r.HC4__Location__r.Id',
                'phone' => 'HC4__ProviderLocation__r.HC4__Location__r.HC4__Phone__c',
                'fax' => 'HC4__ProviderLocation__r.HC4__Location__r.HC4__Fax__c',
                'email' => 'HC4__ProviderLocation__r.HC4__Location__r.HC4__Email__c'
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
        return RestPrmProviderTerrLocController.performGetSearch(null);
    }
    
    public static List<RestPrmLocationController.Location> performGetSearch(List<HC4.uCondition> additionalConditions) {
        List<String> conditions = new List<String>();
        
        String providerId = uRestController.getParentObjectId('Providers/');
        String territoyId = uRestController.getParentObjectId('Territories/');
        conditions.add(new HC4.uCondition('HC4__ProviderLocationTerritory__c', ' HC4__ProviderLocation__r.HC4__Provider__c', '=', providerId).toSql());
        conditions.add(new HC4.uCondition('HC4__ProviderLocationTerritory__c', 'HC4__Territory__c', '=', territoyId).toSql());
        
        if(additionalConditions != null) {
            for(HC4.uCondition c : additionalConditions) {
                conditions.add(c.toSql());
            }
        }
        
        conditions.addAll(uRestController.propertyMapToSoql(RestPrmProviderTerrLocController.propertyMap, 'HC4__ProviderLocationTerritory__c'));
        
        Integer pageSize = uRestController.pageSize;
        Integer offSet = uRestController.offset;
        
        List<HC4__ProviderLocationTerritory__c> result = 
                    (List<HC4__ProviderLocationTerritory__c>)Database.query(RestPrmProviderTerrLocController.generateLocationSql(conditions));
        
        List<RestPrmLocationController.Location> response = new List<RestPrmLocationController.Location>();
        for(HC4__ProviderLocationTerritory__c s : result) {
            response.add(new RestPrmLocationController.Location(s));
        }
        
        uRestController.setPagingHeaders(pageSize, offSet, response.size());
        return response;
    }
    
    private static String generateLocationSql(List<String> filters) {
        if(filters == null) {
            filters = new List<String>();
        }
        
        String sql = 'Select HC4__ProviderLocation__r.HC4__IsPrimary__c, HC4__ProviderLocation__r.HC4__Location__r.Id, ' +
                     'HC4__ProviderLocation__r.HC4__Location__r.HC4__Phone__c, HC4__ProviderLocation__r.HC4__Location__r.HC4__Fax__c, ' +
                     'HC4__ProviderLocation__r.HC4__Location__r.HC4__Email__c, HC4__ProviderLocation__r.HC4__Location__r.HC4__OtherStreet__c, ' +
                     'HC4__ProviderLocation__r.HC4__Location__r.HC4__OtherCity__c, HC4__ProviderLocation__r.HC4__Location__r.HC4__OtherState__c, ' +
                     'HC4__ProviderLocation__r.HC4__Location__r.HC4__OtherPostalCode__c, HC4__ProviderLocation__r.HC4__Location__r.HC4__OtherCountry__c, ' +
                     'HC4__ProviderLocation__r.HC4__Location__r.HC4__MailingStreet__c, HC4__ProviderLocation__r.HC4__Location__r.HC4__MailingCity__c, ' +
                     'HC4__ProviderLocation__r.HC4__Location__r.HC4__MailingState__c, HC4__ProviderLocation__r.HC4__Location__r.HC4__MailingPostalCode__c, ' +
                     'HC4__ProviderLocation__r.HC4__Location__r.HC4__MailingCountry__c, HC4__ProviderLocation__r.HC4__Location__r.HC4__Practice__c, ' +
                     'HC4__ProviderLocation__r.HC4__Location__r.HC4__PracticeName__c, HC4__ProviderLocation__r.HC4__Location__r.CreatedDate,'+
                     'HC4__ProviderLocation__r.HC4__Location__r.CreatedBy.Id, HC4__ProviderLocation__r.HC4__Location__r.CreatedBy.Name, HC4__ProviderLocation__r.HC4__Location__r.LastModifiedDate,' +
                     'HC4__ProviderLocation__r.HC4__Location__r.LastModifiedBy.Id, HC4__ProviderLocation__r.HC4__Location__r.LastModifiedBy.Name from HC4__ProviderLocationTerritory__c';
                     
       if(filters.size() > 0 ) {
         sql += (' WHERE ' + HC4.uList.join(filters, ' AND '));
       }
       sql += uRestController.decodeSortForSoql('name', RestPrmProviderTerrLocController.propertyMap);
       sql += ' LIMIT :pageSize OFFSET :offset';
       
       System.debug(LoggingLevel.ERROR, sql);
       return sql;
    }
}