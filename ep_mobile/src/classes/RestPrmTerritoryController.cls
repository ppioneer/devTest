/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v1/Territories/*')
global with sharing class RestPrmTerritoryController {

    @HttpGet
    global static List<RestPrmTerritoryController.Territory> doGet() {
    	String objectId = uRestController.objectId;
        if(!String.isBlank(objectId)) {
            List<RestPrmTerritoryController.Territory> response = new List<RestPrmTerritoryController.Territory>();
        
            try {
                response.add(new RestPrmTerritoryController.Territory(objectId));
            }
            catch(Exception e) {
                System.debug(LoggingLevel.ERROR, e);
                uRestController.setStatusCode(uRestController.NotFound);
            }
    
            return response;
        } else {
            return RestPrmTerritoryController.performGetSearch();
        }
    }
    
    public static Map<String, String> fieldMap {
        get {
           return uRestController.remapFields(RestPrmTerritoryController.propertyMap);
        }
    }
    
    private static Map<String, String> localPropertyMap {
        get {
            return new Map<String, String> {
                'id' => 'id',
                'name' => 'Name'
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

    private static List<RestPrmTerritoryController.Territory> performGetSearch() {
        return RestPrmTerritoryController.performGetSearch(null);
    }
    
    public static List<RestPrmTerritoryController.Territory> performGetSearch(List<HC4.uCondition> additionalConditions) {
        List<String> conditions = new List<String>();
        
        if(additionalConditions != null) {
            for(HC4.uCondition c : additionalConditions) {
                conditions.add(c.toSql());
            }
        }
        
        if(!String.isBlank(uRestController.searchValue)) {
            conditions.add(new HC4.uCondition('HC4__Territory__c', 'Name', 'c', uRestController.searchValue).toSql());
        }
        
        conditions.addAll(uRestController.propertyMapToSoql(RestPrmTerritoryController.propertyMap, 'HC4__Territory__c'));
        
        Integer pageSize = uRestController.pageSize;
        Integer offSet = uRestController.offset;
        
        List<HC4__Territory__c> result = 
                    (List<HC4__Territory__c>)Database.query(RestPrmTerritoryController.generateTerritorySql(conditions));
        
        List<RestPrmTerritoryController.Territory> response = new List<RestPrmTerritoryController.Territory>();
        for(HC4__Territory__c s : result) {
            response.add(new RestPrmTerritoryController.Territory(s));
        }
        
        uRestController.setPagingHeaders(pageSize, offSet, response.size());
        return response;
    }
    
    private static String generateTerritorySql(List<String> filters) {
        if(filters == null) {
            filters = new List<String>();
        }
        
        String sql = 'Select Id, Name, CreatedDate, CreatedBy.Id, CreatedBy.Name, LastModifiedDate, LastModifiedBy.Id, LastModifiedBy.Name, OwnerId from HC4__Territory__c';
                     
       if(filters.size() > 0 ) {
         sql += (' WHERE ' + HC4.uList.join(filters, ' AND '));
       }
       sql += uRestController.decodeSortForSoql('name', RestPrmTerritoryController.propertyMap);
       sql += ' LIMIT :pageSize OFFSET :offset';
       
       System.debug(LoggingLevel.ERROR, sql);
       return sql;
    }
    
    global class Territory {
    	public String id { get { return String.isBlank(this.id) ? uString.EMPTY: this.id; } set; }
    	public String name { get { return String.isBlank(this.name) ? uString.EMPTY: this.name; } set; }
    	public DateTime createdDate { get; private set; }
    	public RestPrmUserController.RestUser createdBy { get; private set; }
    	public DateTime lastModifiedDate { get; private set; }
        public RestPrmUserController.RestUser lastModifiedBy { get; private set; }
    	public Integer providersCount { get { return (this.providersCount == null) ? 0: this.providersCount; } set; }   	 
    	public Boolean isOwned { get { return this.isOwned == null ? false : this.isOwned; } set; }
    	
    	public Territory(String id) {
    		this([Select Id, Name, CreatedDate, CreatedBy.Id, CreatedBy.Name, LastModifiedDate, LastModifiedBy.Id, LastModifiedBy.Name, OwnerId from HC4__Territory__c where ID = :id FOR REFERENCE]);
    	}
    	
    	public Territory(HC4__Territory__c t) {
    		this.id = t.Id;
    		this.name = t.Name;
    		this.createdDate = t.CreatedDate;
    		this.createdBy = new RestPrmUserController.RestUser(t.CreatedBy.Id, t.CreatedBy.Name);
    		this.lastModifiedDate = t.LastModifiedDate;
            this.lastModifiedBy = new RestPrmUserController.RestUser(t.LastModifiedBy.Id, t.LastModifiedBy.Name);
            this.isOwned = (t.OwnerId == UserInfo.getUserId())? true : false;
    	}
    	
    	public Territory(HC4__ProviderLocationTerritory__c t) {
            this.id = t.HC4__Territory__r.Id;
            this.name = t.HC4__Territory__r.Name;
            this.createdDate = t.HC4__Territory__r.CreatedDate;
            this.createdBy = new RestPrmUserController.RestUser(t.HC4__Territory__r.CreatedBy.Id, t.HC4__Territory__r.CreatedBy.Name);
            this.lastModifiedDate = t.HC4__Territory__r.LastModifiedDate;
            this.lastModifiedBy = new RestPrmUserController.RestUser(t.HC4__Territory__r.LastModifiedBy.Id, t.HC4__Territory__r.LastModifiedBy.Name);
            this.isOwned = (t.HC4__Territory__r.OwnerId == UserInfo.getUserId())? true : false;
        }
        
        public Territory(RecentlyViewed t) {
            this.id = t.Id;
            this.name = t.Name;
        }
    }
}