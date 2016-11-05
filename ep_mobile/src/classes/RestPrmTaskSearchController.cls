/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v2/Tasks/Search/*')
global with sharing class RestPrmTaskSearchController {
	
	@HttpGet
	global static List<uRestController.GenericGetListResponse> doGet() {
    	
        return RestPrmTaskSearchController.performGetSearch(); 		
	}
	
	private static List<uRestController.GenericGetListResponse> performGetSearch() {
    	return RestPrmTaskSearchController.performGetSearch(null);
    }
    
    public static List<uRestController.GenericGetListResponse> performGetSearch(List<HC4.uCondition> additionalConditions) {
    	List<String> conditions = new List<String>();
    	conditions.add('Type != \'Call\' And Type != \'Expense\' And Subject != \'Call\' and Subject != \'Expense\'');
    	
    	if(additionalConditions != null) {
    		for(HC4.uCondition c : additionalConditions) {
    			conditions.add(c.toSql());
    		}
    	}
    	
    	//Process all the query parameters dynamically
    	
    	
    	if(!String.isBlank(uRestController.getParameterValue('startDueDate'))) {
           conditions.add('ActivityDate >= ' + String.escapeSingleQuotes(uRestController.getParameterValue('startDueDate')));
        }
        
        if(!String.isBlank(uRestController.getParameterValue('endDueDate'))) {
           conditions.add('ActivityDate <= ' + String.escapeSingleQuotes(uRestController.getParameterValue('endDueDate')));
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
    	
    	if(!String.isBlank(uRestController.searchValue)) {
            conditions.add(new HC4.uCondition('Task', 'Subject', 'c', uRestController.searchValue).toSql());
        }
    	
    	conditions.addAll(uRestController.propertyMapToSoql(RestPrmTaskController.propertyMap, 'Task', new Set<String> { 'createdDate' }));
    	
    	List<uRestController.GenericGetListResponse> response = new List<uRestController.GenericGetListResponse>();
    	    	
    	Integer pageSize = uRestController.getPageSize(200);
        Integer offSet = uRestController.offset;
        
        List<Task> lResult = (List<Task>)Database.query(RestPrmTaskSearchController.generateTaskSql(conditions));
        
        String[] types = new String[]{ 'Task' };
		Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
        
        for(Task a : lResult) {
            response.add(new uRestController.GenericGetListResponse(a, results[0].getName(), results[0].getLabel()));
        }
    	
    	uRestController.setPagingHeaders(pageSize, offSet, response.size());
    	return response;
    }
    
    private static String generateTaskSql(List<String> filters) {
        if(filters == null) {
            filters = new List<String>();
        }
        
        String sql = 'Select Id, Description, ActivityDate, Who.Id, Who.Name, What.Id, What.Name, Priority, ' +
                     'Status, Subject, IsClosed, Owner.Id, Owner.Name, ReminderDateTime, CreatedDate, ' +
                     'CreatedBy.Id, CreatedBy.Name, LastModifiedDate, LastModifiedBy.Id, LastModifiedBy.Name from Task';
                     
       if(filters.size() > 0 ) {
         sql += (' WHERE ' + HC4.uList.join(filters, ' AND '));
       }
       
       sql += uRestController.decodeSortForSoql('dueDate', RestPrmTaskController.propertyMap);
       sql += ' LIMIT :pageSize OFFSET :offset';
       
       System.debug(LoggingLevel.ERROR, sql);
       return sql;
        
    }

}