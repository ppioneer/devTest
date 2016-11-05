/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v1/AreasOfExpertise/*')
global with sharing class RestPrmAreaOfExpertiseController {    
    @HttpGet
    global static List<RestPrmAreaOfExpertiseController.AreaOfExpertise> doGet() {        
        String objectId = uRestController.objectId;
        if(!String.isBlank(objectId)) {
            List<RestPrmAreaOfExpertiseController.AreaOfExpertise> response = new List<RestPrmAreaOfExpertiseController.AreaOfExpertise>();
        
            try {
                response.add(new RestPrmAreaOfExpertiseController.AreaOfExpertise(objectId));
            }
            catch(Exception e) {
                System.debug(LoggingLevel.ERROR, e);
                uRestController.setStatusCode(uRestController.NotFound);
            }
    
            return response;
        } else {
            return RestPrmAreaOfExpertiseController.performGetSearch();
        }
    }
    
    public static Map<String, String> fieldMap {
        get {
           return uRestController.remapFields(RestPrmAreaOfExpertiseController.propertyMap);
        }
    }
    
    private static Map<String, String> localPropertyMap {
        get {
            return new Map<String, String> {
                'id' => 'id',
                'name' => 'Name',
                'code' => 'HC4__Code__c'
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
        return RestPrmAreaOfExpertiseController.performGetSearch(null);
    }
    
    public static List<RestPrmAreaOfExpertiseController.AreaOfExpertise> performGetSearch(List<HC4.uCondition> additionalConditions) {
        List<String> conditions = new List<String>();
        
        if(additionalConditions != null) {
            for(HC4.uCondition c : additionalConditions) {
                conditions.add(c.toSql());
            }
        }
        
        //T2880
        if(!String.isBlank(uRestController.searchValue)) {
            conditions.add(new HC4.uCondition('HC4__AreaOfExpertise__c', 'Name', 'c', uRestController.searchValue).toSql());
        }
        
        conditions.addAll(uRestController.propertyMapToSoql(RestPrmAreaOfExpertiseController.propertyMap, 'HC4__AreaOfExpertise__c'));
        
        Integer pageSize = uRestController.getPageSize(1000);
        Integer offSet = uRestController.offset;
        
        List<HC4__AreaOfExpertise__c> result = 
                    (List<HC4__AreaOfExpertise__c>)Database.query(RestPrmAreaOfExpertiseController.generateAreaOfExpertiseSql(conditions));
        
        List<RestPrmAreaOfExpertiseController.AreaOfExpertise> response = new List<RestPrmAreaOfExpertiseController.AreaOfExpertise>();
        for(HC4__AreaOfExpertise__c s : result) {
            response.add(new RestPrmAreaOfExpertiseController.AreaOfExpertise(s));
        }
        
        uRestController.setPagingHeaders(pageSize, offSet, response.size());
        return response;
    }
    
    private static String generateAreaOfExpertiseSql(List<String> filters) {
        if(filters == null) {
            filters = new List<String>();
        }
        
        String sql = 'Select Id, Name, HC4__Code__c, CreatedDate, CreatedBy.Id, CreatedBy.Name,' +
                     'LastModifiedDate, LastModifiedBy.Id, LastModifiedBy.Name From HC4__AreaOfExpertise__c';
                     
       if(filters.size() > 0 ) {
         sql += (' WHERE ' + HC4.uList.join(filters, ' AND '));
       }
       sql += uRestController.decodeSortForSoql('name', RestPrmAreaOfExpertiseController.propertyMap);
       sql += ' LIMIT :pageSize OFFSET :offset';
       
       System.debug(LoggingLevel.ERROR, sql);
       return sql;
    }
    
    global class AreaOfExpertise {
    	public String id { get { return String.isBlank(this.id) ? uString.EMPTY: this.id; } set; }
    	public String name { get { return String.isBlank(this.name) ? uString.EMPTY: this.name; } set; }
    	public String code { get { return String.isBlank(this.code) ? uString.EMPTY: this.code; } set; }
    	public Boolean isPrimary { get { return this.isPrimary == null ? false : this.isPrimary; } set; }
    	public DateTime createdDate { get; private set; }
    	public RestPrmUserController.RestUser createdBy { get; private set; }
    	public DateTime lastModifiedDate { get; private set; }
        public RestPrmUserController.RestUser lastModifiedBy { get; private set; }
    	
    	public AreaOfExpertise(String id) {
    		this([Select Id, Name, HC4__Code__c, CreatedDate, CreatedBy.Id, CreatedBy.Name, 
    		LastModifiedDate, LastModifiedBy.Id, LastModifiedBy.Name from HC4__AreaOfExpertise__c Where Id = :id]);
    	}
    	
    	public AreaOfExpertise(HC4__AreaOfExpertise__c e) {
    		this.id = e.Id;
    		this.name = e.Name;
    		this.code = e.HC4__Code__c;
    		this.createdDate = e.CreatedDate;
    		this.createdBy = new RestPrmUserController.RestUser(e.CreatedBy.Id, e.CreatedBy.Name);
    		this.lastModifiedDate = e.LastModifiedDate;
            this.lastModifiedBy = new RestPrmUserController.RestUser(e.LastModifiedBy.Id, e.LastModifiedBy.Name);
    	}
    	
    	public AreaOfExpertise(HC4__ProviderAreaOfExpertise__c e) {
            this.id = e.HC4__AreaOfExpertise__r.Id;
            this.name = e.HC4__AreaOfExpertise__r.Name;
            this.code = e.HC4__AreaOfExpertise__r.HC4__Code__c;
            this.isPrimary = e.HC4__IsPrimary__c;
            this.createdDate = e.HC4__AreaOfExpertise__r.CreatedDate;
            this.createdBy = new RestPrmUserController.RestUser(e.HC4__AreaOfExpertise__r.CreatedBy.Id, e.HC4__AreaOfExpertise__r.CreatedBy.Name);
            this.lastModifiedDate = e.HC4__AreaOfExpertise__r.LastModifiedDate;
            this.lastModifiedBy = new RestPrmUserController.RestUser(e.HC4__AreaOfExpertise__r.LastModifiedBy.Id, e.HC4__AreaOfExpertise__r.LastModifiedBy.Name);
        }
    }
}