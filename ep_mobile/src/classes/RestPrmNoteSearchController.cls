/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v2/Notes/Search/*')
global with sharing class RestPrmNoteSearchController {
	
	@HttpGet
	global static List<uRestController.GenericGetListResponse> doGet() {
    	
        return RestPrmNoteSearchController.performGetSearch(); 		
	}
	
	private static List<uRestController.GenericGetListResponse> performGetSearch() {
        return RestPrmNoteSearchController.performGetSearch(null);
    }
    
    public static List<uRestController.GenericGetListResponse> performGetSearch(List<HC4.uCondition> additionalConditions) {
        List<String> conditions = new List<String>();
        List<uRestController.GenericGetListResponse> response = new List<uRestController.GenericGetListResponse>();
        try{
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
	        
	        if(!String.isBlank(uRestController.searchValue)) {
	            conditions.add(new HC4.uCondition('Note', 'Title', 'c', uRestController.searchValue).toSql());
	        }
	        
	        conditions.addAll(uRestController.propertyMapToSoql(RestPrmNoteController.propertyMap, 'Note', new Set<String> { 'createdDate' }));
	        
	        
	        Integer pageSize = uRestController.getPageSize(200);
	        Integer offset = uRestController.offset;
	        
	        List<Note> result = 
	                    (List<Note>)Database.query(RestPrmNoteSearchController.generateNoteSql(conditions));
	        
	        String[] types = new String[]{ 'Note'};
			Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
			
	        for(Note a : result) {
	            response.add(new uRestController.GenericGetListResponse(a, results[0].getName(), results[0].getLabel()));
	        }
	        
	        uRestController.setPagingHeaders(pageSize, offset, response.size());
        }
        catch(Exception ex){
        	System.debug(LoggingLevel.ERROR, ex);
            uRestController.setStatusCode(uRestController.BadRequest, ex.getMessage());
        }
        return response;
    }
    
    private static String generateNoteSql(List<String> filters) {
        if(filters == null) {
            filters = new List<String>();
        }
        
        String sql = 'SELECT Id, Owner.Id, Owner.Name, Parent.Type, Parent.Name, ParentId, Title, Body, IsPrivate, CreatedDate, CreatedBy.Id, CreatedBy.Name,' +
                     'LastModifiedDate, LastModifiedBy.Id, LastModifiedBy.Name FROM Note';
                     
       if(filters.size() > 0 ) {
         sql += (' WHERE ' + HC4.uList.join(filters, ' AND '));
       }
       
       sql += uRestController.decodeSortForSoql('createdDate', RestPrmNoteController.propertyMap);
       sql += ' LIMIT :pageSize OFFSET :offset';
       
       System.debug(LoggingLevel.ERROR, sql);
       return sql;
        
    }
}