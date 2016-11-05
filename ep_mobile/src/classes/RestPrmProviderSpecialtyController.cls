/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v1/Providers/*/Specialties')
global with sharing class RestPrmProviderSpecialtyController {

    @HttpGet
    global static List<RestPrmSpecialtyController.Specialty> doGet() {
    	return RestPrmProviderSpecialtyController.performGetSearch();
    }
    
    public static Map<String, String> fieldMap {
        get {
           return uRestController.remapFields(RestPrmProviderSpecialtyController.propertyMap);
        }
    }
    
    private static Map<String, String> localPropertyMap {
        get {
            return new Map<String, String> {
                'id' => 'HC4__Specialty__r.Id',
                'name' => 'HC4__Specialty__r.Name',
                'classification' => 'HC4__Specialty__r.HC4__Classification__c',
                'code' => 'HC4__Specialty__r.HC4__Code__c',
                'industryName' => 'HC4__Specialty__r.HC4__IndustryName__c',
                'taxonomyCode' => 'HC4__Specialty__r.HC4__TaxonomyCode__c'
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

    private static List<RestPrmSpecialtyController.Specialty> performGetSearch() {
        return RestPrmProviderSpecialtyController.performGetSearch(null);
    }
    
    public static List<RestPrmSpecialtyController.Specialty> performGetSearch(List<HC4.uCondition> additionalConditions) {
        List<String> conditions = new List<String>();
        
        String providerId = uRestController.getParentObjectId('Providers/');
        conditions.add(new HC4.uCondition('HC4__ProviderSpecialty__c', 'HC4__Provider__c', '=', providerId).toSql());
        
        if(additionalConditions != null) {
            for(HC4.uCondition c : additionalConditions) {
                conditions.add(c.toSql());
            }
        }
        
        conditions.addAll(uRestController.propertyMapToSoql(RestPrmProviderSpecialtyController.propertyMap, 'HC4__ProviderSpecialty__c'));
        
        Integer pageSize = uRestController.getPageSize(20);
        Integer offSet = uRestController.offset;
        
        List<HC4__ProviderSpecialty__c> result = 
                    (List<HC4__ProviderSpecialty__c>)Database.query(RestPrmProviderSpecialtyController.generateProviderSpecialtySql(conditions));
        
        List<RestPrmSpecialtyController.Specialty> response = new List<RestPrmSpecialtyController.Specialty>();
        for(HC4__ProviderSpecialty__c s : result) {
            response.add(new RestPrmSpecialtyController.Specialty(s));
        }
        
        uRestController.setPagingHeaders(pageSize, offSet, response.size());
        return response;
    }
    
    private static String generateProviderSpecialtySql(List<String> filters) {
        if(filters == null) {
            filters = new List<String>();
        }
        
        String sql = 'Select HC4__IsPrimary__c, HC4__Specialty__r.Id, HC4__Specialty__r.Name, ' +
                     'HC4__Specialty__r.HC4__Classification__c, HC4__Specialty__r.HC4__Code__c, ' +
                     'HC4__Specialty__r.HC4__IndustryName__c, HC4__Specialty__r.HC4__TaxonomyCode__c, ' +
                     'HC4__Specialty__r.CreatedDate, HC4__Specialty__r.CreatedBy.Id, HC4__Specialty__r.CreatedBy.Name, ' +
                     'HC4__Specialty__r.LastModifiedDate, HC4__Specialty__r.LastModifiedBy.Id, HC4__Specialty__r.LastModifiedBy.Name ' +
                     'FROM HC4__ProviderSpecialty__c';
                     
       if(filters.size() > 0 ) {
         sql += (' WHERE ' + HC4.uList.join(filters, ' AND '));
       }
       sql += uRestController.decodeSortForSoql('name', RestPrmProviderSpecialtyController.propertyMap);
       sql += ' LIMIT :pageSize OFFSET :offset';
       
       System.debug(LoggingLevel.ERROR, sql);
       return sql;
    }
}