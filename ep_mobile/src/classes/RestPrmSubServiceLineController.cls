/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v1/SubServiceLines/*')
global with sharing class RestPrmSubServiceLineController {
    @HttpGet
    global static List<RestPrmSubServiceLineController.SubServiceLine> doGet() {
        String objectId = uRestController.objectId;
        if(!String.isBlank(objectId)) {
            List<RestPrmSubServiceLineController.SubServiceLine> response = new List<RestPrmSubServiceLineController.SubServiceLine>();
        
            try {
                response.add(new RestPrmSubServiceLineController.SubServiceLine(objectId));
            }
            catch(Exception e) {
                System.debug(LoggingLevel.ERROR, e);
                uRestController.setStatusCode(uRestController.NotFound);
            }
    
            return response;
        } else {
            return RestPrmSubServiceLineController.performGetSearch();
        }
    }
    
    public static Map<String, String> fieldMap {
        get {
           return uRestController.remapFields(RestPrmSubServiceLineController.propertyMap);
        }
    }
    
    private static Map<String, String> localPropertyMap {
        get {
            return new Map<String, String> {
                'id' => 'id',
                'name' => 'Name',
                'code' => 'HC4__Code__c',
                'serviceLine' => 'HC4__ServiceLine__c'
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

    private static List<RestPrmSubServiceLineController.SubServiceLine> performGetSearch() {
        return RestPrmSubServiceLineController.performGetSearch(null);
    }
    
    public static List<RestPrmSubServiceLineController.SubServiceLine> performGetSearch(List<HC4.uCondition> additionalConditions) {
        List<String> conditions = new List<String>();
        
        if(additionalConditions != null) {
            for(HC4.uCondition c : additionalConditions) {
                conditions.add(c.toSql());
            }
        }
        
        conditions.addAll(uRestController.propertyMapToSoql(RestPrmSubServiceLineController.propertyMap, 'HC4__SubServiceLine__c'));
        
        Integer pageSize = uRestController.pageSize;
        Integer offSet = uRestController.offset;
        
        List<HC4__SubServiceLine__c> result = 
                    (List<HC4__SubServiceLine__c>)Database.query(RestPrmSubServiceLineController.generateSubServiceLinesSql(conditions));
        
        List<RestPrmSubServiceLineController.SubServiceLine> response = new List<RestPrmSubServiceLineController.SubServiceLine>();
        for(HC4__SubServiceLine__c s : result) {
            response.add(new RestPrmSubServiceLineController.SubServiceLine(s));
        }
        
        uRestController.setPagingHeaders(pageSize, offSet, response.size());
        return response;
    }
    
    private static String generateSubServiceLinesSql(List<String> filters) {
        if(filters == null) {
            filters = new List<String>();
        }
        
        String sql = 'Select Id, Name, HC4__Code__c, CreatedDate, CreatedBy.Id, CreatedBy.Name, '+
                     'LastModifiedDate, LastModifiedBy.Id, LastModifiedBy.Name from HC4__SubServiceLine__c';
                     
       if(filters.size() > 0 ) {
         sql += (' WHERE ' + HC4.uList.join(filters, ' AND '));
       }
       sql += uRestController.decodeSortForSoql('name', RestPrmServiceLineController.propertyMap);
       sql += ' LIMIT :pageSize OFFSET :offset';
       
       System.debug(LoggingLevel.ERROR, sql);
       return sql;
    }
    
    global class SubServiceLine {
        public String id { get { return String.isBlank(this.id) ? uString.EMPTY: this.id; } set; }
        public String name { get { return String.isBlank(this.name) ? uString.EMPTY: this.name; } set; }
        public String code { get { return String.isBlank(this.code) ? uString.EMPTY: this.code; } set; }
        public DateTime createdDate { get; private set; }
        public RestPrmUserController.RestUser createdBy { get; private set; }
        public DateTime lastModifiedDate { get; private set; }
        public RestPrmUserController.RestUser lastModifiedBy { get; private set; }
        
        public SubServiceLine(String id) {
            this([Select Id, Name, HC4__Code__c, CreatedDate, CreatedBy.Id, CreatedBy.Name,
            LastModifiedDate, LastModifiedBy.Id, LastModifiedBy.Name from HC4__SubServiceLine__c where Id = :id]);
        }
        
        public SubServiceLine(HC4__SubServiceLine__c sl) {
            this.id = sl.Id;
            this.name = sl.Name;
            this.code = sl.HC4__Code__c;
            this.createdDate = sl.CreatedDate;
            this.createdBy = new RestPrmUserController.RestUser(sl.CreatedBy.Id, sl.CreatedBy.Name);
            this.lastModifiedDate = sl.LastModifiedDate;
            this.lastModifiedBy = new RestPrmUserController.RestUser(sl.LastModifiedBy.Id, sl.LastModifiedBy.Name);
        }
    }
}