/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v1/Specialties/*')
global with sharing class RestPrmSpecialtyController {

     @HttpGet
    global static List<RestPrmSpecialtyController.Specialty> doGet() {    	
    	String objectId = uRestController.objectId;
        if(!String.isBlank(objectId)) {
            List<RestPrmSpecialtyController.Specialty> response = new List<RestPrmSpecialtyController.Specialty>();
        
            try {
                response.add(new RestPrmSpecialtyController.Specialty(objectId));
            }
            catch(Exception e) {
                System.debug(LoggingLevel.ERROR, e);
                uRestController.setStatusCode(uRestController.NotFound);
            }
    
            return response;
        } else {
            return RestPrmSpecialtyController.performGetSearch();
        }
    }
    
    public static Map<String, String> fieldMap {
        get {
           return uRestController.remapFields(RestPrmSpecialtyController.propertyMap);
        }
    }
    
    private static Map<String, String> localPropertyMap {
        get {
            return new Map<String, String> {
                'id' => 'id',
                'name' => 'Name',
                'classification' => 'HC4__Classification__c',
                'code' => 'HC4__Code__c',
                'industryName' => 'HC4__IndustryName__c',
                'taxonomyCode' => 'HC4__TaxonomyCode__c'
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
        return RestPrmSpecialtyController.performGetSearch(null);
    }
    
    public static List<RestPrmSpecialtyController.Specialty> performGetSearch(List<HC4.uCondition> additionalConditions) {
        List<String> conditions = new List<String>();
        
        if(additionalConditions != null) {
            for(HC4.uCondition c : additionalConditions) {
                conditions.add(c.toSql());
            }
        }
        
        if(!String.isBlank(uRestController.searchValue)) {
            conditions.add(new HC4.uCondition('HC4__Specialty__c', 'Name', 'c', uRestController.searchValue).toSql());
        }
        
        conditions.addAll(uRestController.propertyMapToSoql(RestPrmSpecialtyController.propertyMap, 'HC4__Specialty__c'));
        
        Integer pageSize = uRestController.pageSize;
        Integer offSet = uRestController.offset;
        
        List<HC4__Specialty__c> result = 
                    (List<HC4__Specialty__c>)Database.query(RestPrmSpecialtyController.generateSpecialtiesSql(conditions));
        
        List<RestPrmSpecialtyController.Specialty> response = new List<RestPrmSpecialtyController.Specialty>();
        for(HC4__Specialty__c s : result) {
            response.add(new RestPrmSpecialtyController.Specialty(s));
        }
        
        uRestController.setPagingHeaders(pageSize, offSet, response.size());
        return response;
    }
    
    private static String generateSpecialtiesSql(List<String> filters) {
        if(filters == null) {
            filters = new List<String>();
        }
        
        String sql = 'Select Id, Name, HC4__Classification__c,' + 
                     'HC4__Code__c, HC4__IndustryName__c, HC4__TaxonomyCode__c,' + 
                     'CreatedDate, CreatedBy.Id, CreatedBy.Name, ' +
                     'LastModifiedDate, LastModifiedBy.Id, LastModifiedBy.Name From HC4__Specialty__c';
                     
       if(filters.size() > 0 ) {
         sql += (' WHERE ' + HC4.uList.join(filters, ' AND '));
       }
       sql += uRestController.decodeSortForSoql('name', RestPrmSpecialtyController.propertyMap);
       sql += ' LIMIT :pageSize OFFSET :offset';
       
       System.debug(LoggingLevel.ERROR, sql);
       return sql;
    }
    
    global class Specialty {
        public String id { get { return String.isBlank(this.id) ? uString.EMPTY: this.id; } set; }
        public String name { get { return String.isBlank(this.name) ? uString.EMPTY: this.name; } set; }
        public String classification { get { return String.isBlank(this.classification) ? uString.EMPTY: this.classification; } set; }
        public String code { get { return String.isBlank(this.code) ? uString.EMPTY: this.code; } set; }
        public String industryName { get { return String.isBlank(this.industryName) ? uString.EMPTY: this.industryName; } set; }
        public String taxonomyCode { get { return String.isBlank(this.taxonomyCode) ? uString.EMPTY: this.taxonomyCode; } set; }
        public Boolean isPrimary { get { return this.isPrimary == null ? false : this.isPrimary; } set; }
        public DateTime createdDate { get; private set; }
        public RestPrmUserController.RestUser createdBy { get; private set; }
        public DateTime lastModifiedDate { get; private set; }
        public RestPrmUserController.RestUser lastModifiedBy { get; private set; }
        
        public Specialty(String specialtyId) {
            this([Select Id, Name, HC4__Classification__c, HC4__Code__c, HC4__IndustryName__c, HC4__TaxonomyCode__c, CreatedDate, CreatedBy.Id,
            CreatedBy.Name, LastModifiedDate, LastModifiedBy.Id, LastModifiedBy.Name From HC4__Specialty__c where Id = :specialtyId]);
        }
        
        public Specialty(HC4__Specialty__c s) {
            this.id = s.Id;
            this.name = s.Name;
            this.classification = s.HC4__Classification__c;
            this.code = s.HC4__Code__c;
            this.industryName = s.HC4__IndustryName__c;
            this.taxonomyCode = s.HC4__TaxonomyCode__c;
            this.createdDate = s.CreatedDate;
            this.createdBy = new RestPrmUserController.RestUser(s.CreatedBy.Id, s.CreatedBy.Name);
            this.lastModifiedDate = s.LastModifiedDate;
            this.lastModifiedBy = new RestPrmUserController.RestUser(s.LastModifiedBy.Id, s.LastModifiedBy.Name);
        }
        
        public Specialty(HC4__ProviderSpecialty__c ps) {
            this.id = ps.HC4__Specialty__r.Id;
            this.name = ps.HC4__Specialty__r.Name;
            this.classification = ps.HC4__Specialty__r.HC4__Classification__c;
            this.code = ps.HC4__Specialty__r.HC4__Code__c;
            this.industryName = ps.HC4__Specialty__r.HC4__IndustryName__c;
            this.taxonomyCode = ps.HC4__Specialty__r.HC4__TaxonomyCode__c;
            this.isPrimary = ps.HC4__IsPrimary__c;
            this.createdDate = ps.HC4__Specialty__r.CreatedDate;
            this.createdBy = new RestPrmUserController.RestUser(ps.HC4__Specialty__r.CreatedBy.Id, ps.HC4__Specialty__r.CreatedBy.Name);
            this.lastModifiedDate = ps.HC4__Specialty__r.LastModifiedDate;
            this.lastModifiedBy = new RestPrmUserController.RestUser(ps.HC4__Specialty__r.LastModifiedBy.Id, ps.HC4__Specialty__r.LastModifiedBy.Name);
        }
        
    }
}