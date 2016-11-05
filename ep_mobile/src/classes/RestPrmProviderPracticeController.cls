/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v1/Providers/*/Practices')
global with sharing class RestPrmProviderPracticeController {

    @HttpGet
    global static List<RestPrmPracticeController.Practice> doGet() {
        return RestPrmProviderPracticeController.performGetSearch();
    }
    
    public static Map<String, String> fieldMap {
        get {
           return uRestController.remapFields(RestPrmProviderPracticeController.propertyMap);
        }
    }
    
    private static Map<String, String> localPropertyMap {
        get {
            return new Map<String, String> {
                'id' => 'HC4__Practice__r.Id',
                'name' => 'HC4__Practice__r.Name',
                'phone' => 'HC4__Practice__r.Phone',
                'fax' => 'HC4__Practice__r.Fax',
                'affiliation' => 'HC4__Practice__r.HC4__Affiliation__c',
                'isInNetwork' => 'HC4__Practice__r.HC4__IsInNetwork__c',
                'website' => 'HC4__Practice__r.Website', 
                'type' => 'HC4__Practice__r.Type'
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

    private static List<RestPrmPracticeController.Practice> performGetSearch() {
        return RestPrmProviderPracticeController.performGetSearch(null);
    }
    
    public static List<RestPrmPracticeController.Practice> performGetSearch(List<HC4.uCondition> additionalConditions) {
        List<String> conditions = new List<String>();
        
        String providerId = uRestController.getParentObjectId('Providers/');
        conditions.add(new HC4.uCondition('HC4__ProviderPractice__c', 'HC4__Provider__c', '=', providerId).toSql());
        
        if(additionalConditions != null) {
            for(HC4.uCondition c : additionalConditions) {
                conditions.add(c.toSql());
            }
        }
        
        conditions.addAll(uRestController.propertyMapToSoql(RestPrmProviderPracticeController.propertyMap, 'HC4__ProviderPractice__c'));
        
        Integer pageSize = uRestController.getPageSize(100);
        Integer offSet = uRestController.offset;
        
        List<HC4__ProviderPractice__c> result = 
                    (List<HC4__ProviderPractice__c>)Database.query(RestPrmProviderPracticeController.generatePracticeSql(conditions));
        
        List<RestPrmPracticeController.Practice> response = new List<RestPrmPracticeController.Practice>();
        for(HC4__ProviderPractice__c a : result) {
            response.add(new RestPrmPracticeController.Practice(a));
        }
        
        uRestController.setPagingHeaders(pageSize, offSet, response.size());
        return response;
    }
    
    private static String generatePracticeSql(List<String> filters) {
        if(filters == null) {
            filters = new List<String>();
        }
        
        String sql = 'Select HC4__IsPrimary__c, HC4__Practice__r.Id, HC4__Practice__r.Name, ' +
                     'HC4__Practice__r.Phone,  HC4__Practice__r.Fax, HC4__Practice__r.BillingStreet, ' +
                     'HC4__Practice__r.BillingCity, HC4__Practice__r.BillingState,  HC4__Practice__r.BillingPostalCode, ' +
                     'HC4__Practice__r.BillingCountry, HC4__Practice__r.BillingLongitude, HC4__Practice__r.BillingLatitude, ' +
                     'HC4__Practice__r.ShippingStreet,  HC4__Practice__r.ShippingCity, HC4__Practice__r.ShippingState, ' +
                     'HC4__Practice__r.ShippingPostalCode,  HC4__Practice__r.ShippingCountry, HC4__Practice__r.ShippingLongitude, ' +
                     'HC4__Practice__r.ShippingLatitude, HC4__Practice__r.HC4__DoNotUpdateFromPrimaryLocation__c, ' +
                     'HC4__Practice__r.HC4__PrimaryLocation__c, HC4__Practice__r.HC4__Affiliation__c, ' +
                     'HC4__Practice__r.HC4__IsInNetwork__c, HC4__Practice__r.Website, HC4__Practice__r.Type, ' +
                     'HC4__Practice__r.Parent.Id, HC4__Practice__r.Parent.Name, HC4__Practice__r.CreatedDate,' +
                     'HC4__Practice__r.CreatedBy.Id, HC4__Practice__r.CreatedBy.Name, HC4__Practice__r.LastModifiedDate,'+
                     'HC4__Practice__r.LastModifiedBy.Id, HC4__Practice__r.LastModifiedBy.Name from HC4__ProviderPractice__c';
                     
       if(filters.size() > 0 ) {
         sql += (' WHERE ' + HC4.uList.join(filters, ' AND '));
       }
       sql += uRestController.decodeSortForSoql('name', RestPrmProviderPracticeController.propertyMap);
       sql += ' LIMIT :pageSize OFFSET :offset';
       
       System.debug(LoggingLevel.ERROR, sql);
       return sql;
        
    }
}