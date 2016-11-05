/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v2/Issues/Search/*')
global with sharing class RestPrmIssueSearchController {

    @HttpGet
	global static List<uRestController.GenericGetListResponse> doGet() {
    	
        return RestPrmIssueSearchController.performGetSearch(); 		
	}

    private static List<uRestController.GenericGetListResponse> performGetSearch() {
        return RestPrmIssueSearchController.performGetSearch(null, null); 
    }
    
    public static List<uRestController.GenericGetListResponse> performGetSearch(List<HC4.uCondition> additionalConditions, List<String> complexConditions) {
        List<String> conditions = new List<String>();
        
        
        if(complexConditions != null){
        	conditions.addAll(complexConditions);
        }
        	
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
            conditions.add(new HC4.uCondition('HC4__Issue__c', 'HC4__Subject__c', 'c', uRestController.searchValue).toSql());
        }
        
        
        Set<String> selectedStatus = new Set<String>();   
        if(!String.isBlank(uRestController.getParameterValue('status'))) {        	 
        	for(String sTemp : uRestController.getParameterValue('status').split(';')){
        		selectedStatus.add(sTemp);
        	}
            conditions.add(new HC4.uCondition('HC4__Issue__c', 'HC4__Status__c', 'IN', ':selectedStatus').toSql());
        }
        
        
        
        
        Set<String> selectedPriority = new Set<String>();        
        if(!String.isBlank(uRestController.getParameterValue('priority'))) {        	 
        	for(String sTemp : uRestController.getParameterValue('priority').split(';')){
        		selectedPriority.add(sTemp);
        	}
            conditions.add(new HC4.uCondition('HC4__Issue__c', 'HC4__Priority__c', 'IN', ':selectedPriority').toSql());
        }
         
        
         
        Set<String> selectedType = new Set<String>();        
        if(!String.isBlank(uRestController.getParameterValue('type'))) {        	 
        	for(String sTemp : uRestController.getParameterValue('type').split(';')){
        		selectedType.add(sTemp);
        	}
            conditions.add(new HC4.uCondition('HC4__Issue__c', 'HC4__Type__c', 'IN', ':selectedType').toSql());
        }
        
        
        conditions.addAll(uRestController.propertyMapToSoql(RestPrmIssueController.propertyMap, 'HC4__Issue__c', new Set<String> { 'createdDate','priority','status','type'})); //Added priority column to ignore - Phab - T1920 & T2276
        
        List<uRestController.GenericGetListResponse> response = new List<uRestController.GenericGetListResponse>();
        
        Integer pageSize = uRestController.getPageSize(200);
        Integer offSet = uRestController.offset;
        
        List<HC4__Issue__c> result = 
                    (List<HC4__Issue__c>)Database.query(RestPrmIssueSearchController.generateIssueSql(conditions));
        
        String[] types = new String[]{ RestPrmIssueController2.objectName };
		Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
        
        for(HC4__Issue__c a : result) {
            response.add(new uRestController.GenericGetListResponse(a, results[0].getName(), results[0].getLabel()));
        }
        
        uRestController.setPagingHeaders(pageSize, offSet, response.size());
        return response;
    }
    
    private static String generateIssueSql(List<String> filters) {
        if(filters == null) {
            filters = new List<String>();
        }
        
        String sql = 'Select Id, HC4__IsClosed__c, HC4__DateTImeClosed__c, HC4__DateTimeOpened__c, HC4__isEscalated__c,' +
                     'HC4__Inquiry__c, HC4__InternalComments__c, HC4__LongDescription__c, HC4__Origin__c, HC4__Priority__c,' +
                     'HC4__Provider__r.Id, HC4__Provider__r.Name, HC4__Patient__r.Id, HC4__Patient__r.Name, HC4__Reason__c, HC4__Status__c, HC4__Subject__c,' +
                     'HC4__Type__c, CreatedDate, Owner.Id, Owner.Name, CreatedBy.Id, CreatedBy.Name,' +
                     'LastModifiedDate, LastModifiedBy.Id, LastModifiedBy.Name From HC4__Issue__c';
                     
       if(filters.size() > 0 ) {
         sql += (' WHERE ' + HC4.uList.join(filters, ' AND '));
       }
       
       sql += uRestController.decodeSortForSoql('dateTimeOpened', RestPrmIssueController.propertyMap);
       sql += ' LIMIT :pageSize OFFSET :offset';
       
       System.debug(LoggingLevel.ERROR, sql);
       return sql;
        
    }


}