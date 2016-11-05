/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v2/Calls/Search/*')
global with sharing class RestPrmCallSearchController {
	
	@HttpGet
	global static List<uRestController.GenericGetListResponse> doGet() {
		    	
        return RestPrmCallSearchController.performGetSearch(); 		
	}
	
	private static List<uRestController.GenericGetListResponse> performGetSearch() {
        return RestPrmCallSearchController.performGetSearch(null);
    }
    
    public static List<uRestController.GenericGetListResponse> performGetSearch(List<HC4.uCondition> additionalConditions) {
        List<String> conditions = new List<String>();
        conditions.add('Subject = \'Call\''); 
        
        if(additionalConditions != null) {
            for(HC4.uCondition c : additionalConditions) {
                conditions.add(c.toSql());
            }
        }
        
        if(!String.isBlank(uRestController.getParameterValue('startCreateDate'))) {
           conditions.add('DAY_ONLY(CreatedDate) >= ' + String.escapeSingleQuotes(uRestController.getParameterValue('startCreateDate')));
        }
        
        if(!String.isBlank(uRestController.getParameterValue('endCreateDate'))) {
           conditions.add('DAY_ONLY(CreatedDate) <= ' + String.escapeSingleQuotes(uRestController.getParameterValue('endCreateDate')));
        }
        
        if(!String.isBlank(uRestController.getParameterValue('createdDate'))) {
           conditions.add('DAY_ONLY(CreatedDate) = ' + String.escapeSingleQuotes(uRestController.getParameterValue('createdDate')));
        }
        
        conditions.addAll(uRestController.propertyMapToSoql(RestPrmCallController.propertyMap, 'Task'));
        
        List<uRestController.GenericGetListResponse> response = new List<uRestController.GenericGetListResponse>();
        
        Integer pageSize = uRestController.getPageSize(200);
        Integer offSet = uRestController.offset;
        
        List<Task> result = 
                    (List<Task>)Database.query(RestPrmCallSearchController.generateCallSql(conditions));
        
        String[] types = new String[]{ 'Task' };
		Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
        
        for(Task a : result) {
            response.add(new uRestController.GenericGetListResponse(a, results[0].getName(), 'Call'));
        }
        
        uRestController.setPagingHeaders(pageSize, offSet, response.size());
        return response;
    }
    
    private static String generateCallSql(List<String> filters) {
        if(filters == null) {
            filters = new List<String>();
        }
        
        String sql = 'Select Id, Who.Id, Who.Name, What.Id, What.Name, Owner.Id, Owner.Name, OwnerId, Priority, Subject, IsClosed,' +  
                     'Description, ActivityDate, CreatedDate, CreatedBy.Id, CreatedBy.Name, LastModifiedDate, LastModifiedBy.Id, LastModifiedBy.Name from Task';
                     
       if(filters.size() > 0 ) {
         sql += (' WHERE ' + HC4.uList.join(filters, ' AND '));
       }
       
             
       sql += uRestController.decodeSortForSoql('dueDate', RestPrmCallController.propertyMap, new Map<String, String> { 'createdDate' => 'CreatedDate' });
       sql += ' LIMIT :pageSize OFFSET :offset';
       
       System.debug(LoggingLevel.ERROR, sql);
       return sql;
        
    }

}