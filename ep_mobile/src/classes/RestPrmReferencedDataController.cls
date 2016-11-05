/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v2/Reference/Search/*')
global with sharing class RestPrmReferencedDataController {
    
    @HttpGet
    global static List<RestPrmReferencedDataController.RestPrmReferencedData> doGet() {     
        return RestPrmReferencedDataController.performGetSearch();      
    }
    
    private static List<RestPrmReferencedDataController.RestPrmReferencedData> performGetSearch() {
        return RestPrmReferencedDataController.performGetSearch(null);
    }
    
    public static List<RestPrmReferencedDataController.RestPrmReferencedData> performGetSearch(List<HC4.uCondition> additionalConditions) {
        
        List<String> conditions = new List<String>();
        String objectName = uString.EMPTY;
        List<RestPrmReferencedDataController.RestPrmReferencedData> response = new List<RestPrmReferencedDataController.RestPrmReferencedData>(); 
        
        if(String.isBlank(uRestController.getParameterValue('objectName'))) {
           uRestController.setStatusCode(uRestController.BadRequest, 'Invalid Sobject.');
           return null;                  
        }        
        
        if(!String.isBlank(uRestController.getParameterValue('objectName'))) {
           objectName = uRestController.getParameterValue('objectName');                   
        }        
        
        if(!String.isBlank(uRestController.searchValue)) {
            conditions.add(new HC4.uCondition(objectName, 'Name', 'c', uRestController.searchValue).toSql());
        }
        
        Integer pageSize = uRestController.getPageSize(25);
        Integer offSet = uRestController.offset;
        
        
        List<Sobject> lResult = Database.query(RestPrmReferencedDataController.generateSoql(conditions, objectName));
        
        for(Sobject result : lResult){
            response.add(new RestPrmReferencedData(result));
        }
        
        uRestController.setPagingHeaders(pageSize, offSet, response.size());                
        return response;
    }
    
    private static String generateSoql(List<String> filters, String objName) {
        
        if(filters == null) {
            filters = new List<String>();
        }
        
       String sql = 'SELECT Id, Name FROM ' + objName;
                     
       if(filters.size() > 0 ) {
         sql += (' WHERE ' + HC4.uList.join(filters, ' AND '));
       }       
       
       if(objName == 'User'){
       	
       		if(filters.isEmpty()){
       			sql += ' WHERE IsActive = true';
       		}
       		else{
       			sql += ' AND IsActive = true';
       		} 
       }
       
       sql += ' ORDER by Name LIMIT :pageSize OFFSET :offset';
       
       System.debug(LoggingLevel.ERROR, sql);
       return sql;
        
    }
    
    global class RestPrmReferencedData {
        public String id { get; set; }
        public String name { get; set; } 
        
        public RestPrmReferencedData(Sobject o){
            this.id = String.valueOf(o.get('Id'));
            this.Name = String.valueOf(o.get('Name'));
        }       
    }

}