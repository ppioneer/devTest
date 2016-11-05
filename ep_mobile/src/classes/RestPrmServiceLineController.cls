/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v1/ServiceLines/*')
global with sharing class RestPrmServiceLineController {
    @HttpGet
    global static List<RestPrmServiceLineController.ServiceLine> doGet() {        
        String objectId = uRestController.objectId;
        if(!String.isBlank(objectId)) {
            List<RestPrmServiceLineController.ServiceLine> response = new List<RestPrmServiceLineController.ServiceLine>();
        
            try {
                response.add(new RestPrmServiceLineController.ServiceLine(objectId));
            }
            catch(Exception e) {
                System.debug(LoggingLevel.ERROR, e);
                uRestController.setStatusCode(uRestController.NotFound);
            }
    
            return response;
        } else {
            return RestPrmServiceLineController.performGetSearch();
        }
    }
    
    public static Map<String, String> fieldMap {
        get {
           return uRestController.remapFields(RestPrmServiceLineController.propertyMap);
        }
    }
    
    private static Map<String, String> localPropertyMap {
        get {
            return new Map<String, String> {
                'id' => 'id',
                'name' => 'Name',
                'code' => 'HC4__Code__c',
                'subgroup' => 'HC4__Subgroup__c'
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

    private static List<RestPrmServiceLineController.ServiceLine> performGetSearch() {
        return RestPrmServiceLineController.performGetSearch(null);
    }
    
    public static List<RestPrmServiceLineController.ServiceLine> performGetSearch(List<HC4.uCondition> additionalConditions) {
        List<String> conditions = new List<String>();
        
        if(additionalConditions != null) {
            for(HC4.uCondition c : additionalConditions) {
                conditions.add(c.toSql());
            }
        }
        
        conditions.addAll(uRestController.propertyMapToSoql(RestPrmServiceLineController.propertyMap, 'HC4__ServiceLine__c'));
        
        Integer pageSize = uRestController.pageSize;
        Integer offSet = uRestController.offset;
        
        List<HC4__ServiceLine__c> result = 
                    (List<HC4__ServiceLine__c>)Database.query(RestPrmServiceLineController.generateServiceLinesSql(conditions));
        
        List<RestPrmServiceLineController.ServiceLine> response = new List<RestPrmServiceLineController.ServiceLine>();
        for(HC4__ServiceLine__c s : result) {
            response.add(new RestPrmServiceLineController.ServiceLine(s));
        }
        
        uRestController.setPagingHeaders(pageSize, offSet, response.size());
        return response;
    }
    
    private static String generateServiceLinesSql(List<String> filters) {
        if(filters == null) {
            filters = new List<String>();
        }
        
        String sql = 'Select Id, Name, HC4__Code__c, HC4__Subgroup__c, '+
        'CreatedDate, CreatedBy.Id, CreatedBy.Name, ' +
        'LastModifiedDate, LastModifiedBy.Id, LastModifiedBy.Name from HC4__ServiceLine__c';
                     
       if(filters.size() > 0 ) {
         sql += (' WHERE ' + HC4.uList.join(filters, ' AND '));
       }
       sql += uRestController.decodeSortForSoql('name', RestPrmServiceLineController.propertyMap);
       sql += ' LIMIT :pageSize OFFSET :offset';
       
       System.debug(LoggingLevel.ERROR, sql);
       return sql;
    }
    
    global class ServiceLine {
    	public String id { get { return String.isBlank(this.id) ? uString.EMPTY: this.id; } set; }
    	public String name { get { return String.isBlank(this.name) ? uString.EMPTY: this.name; } set; }
    	public String code { get { return String.isBlank(this.code) ? uString.EMPTY: this.code; } set; }
    	public String subgroup { get { return String.isBlank(this.subGroup) ? uString.EMPTY: this.subGroup; } set; }
    	public DateTime createdDate { get; private set; }
    	public RestPrmUserController.RestUser createdBy { get; private set; }
    	public DateTime lastModifiedDate { get; private set; }
        public RestPrmUserController.RestUser lastModifiedBy { get; private set; }
    	
    	public ServiceLine(String id) {
    		this([Select Id, Name, HC4__Code__c, HC4__Subgroup__c, CreatedDate, CreatedBy.Id, CreatedBy.Name,
    		LastModifiedDate, LastModifiedBy.Id, LastModifiedBy.Name from HC4__ServiceLine__c where Id = :id]);
    	}
    	
    	public ServiceLine(HC4__ServiceLine__c sl) {
    		this.id = sl.Id;
    		this.name = sl.Name;
    		this.code = sl.HC4__Code__c;
    		this.subgroup = sl.HC4__Subgroup__c;
    		this.createdDate = sl.CreatedDate;
    		this.createdBy = new RestPrmUserController.RestUser(sl.CreatedBy.Id, sl.CreatedBy.Name);
    		this.lastModifiedDate = sl.LastModifiedDate;
            this.lastModifiedBy = new RestPrmUserController.RestUser(sl.LastModifiedBy.Id, sl.LastModifiedBy.Name);
    	}
    	
    	public ServiceLine(HC4__ProviderScore__c ps) {
    		this.id = ps.HC4__ServiceLine__r.Id;
            this.name = ps.HC4__ServiceLine__r.Name;
            this.code = ps.HC4__ServiceLine__r.HC4__Code__c;
            this.subgroup = ps.HC4__ServiceLine__r.HC4__Subgroup__c;
            this.createdDate = ps.HC4__ServiceLine__r.CreatedDate;
            this.createdBy = new RestPrmUserController.RestUser(ps.HC4__ServiceLine__r.CreatedBy.Id, ps.HC4__ServiceLine__r.CreatedBy.Name);
            this.lastModifiedDate = ps.HC4__ServiceLine__r.LastModifiedDate;
            this.lastModifiedBy = new RestPrmUserController.RestUser(ps.HC4__ServiceLine__r.LastModifiedBy.Id, ps.HC4__ServiceLine__r.LastModifiedBy.Name);
    	}
    }
}