/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v1/Issues/*')
global with sharing class RestPrmIssueController {
    
    @HttpGet
    global static List<RestPrmIssueController.Issue> doGet() {
    	String objectId = uRestController.objectId;
    	
        if(!String.isBlank(objectId)) {
            List<RestPrmIssueController.Issue> response = new List<RestPrmIssueController.Issue>();
        
	        try {
	            response.add(new RestPrmIssueController.Issue(objectId));
	        }
	        catch(Exception e) {
	            System.debug(LoggingLevel.ERROR, e);
	            uRestController.setStatusCode(uRestController.NotFound);
	        }
	
	        return response;  
        } else {
            return RestPrmIssueController.performGetSearch();
        }
    }
    
    @HttpPost
    global static List<RestPrmIssueController.Issue> doPost(RestPrmIssueController.Issue data, String[] providerIds) {
        if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest);   
           return null;
        }
        
        if(providerIds == null) {
            return new List<RestPrmIssueController.Issue>{ RestPrmIssueController.doPost(data) };
        }
        
        if(data.provider == null) {
            data.provider = new RestPrmProviderController.ProviderLite();
        }
        
        
        try {
            List<HC4__Issue__c> issues = new List<HC4__Issue__c>();
            
            for(String providerId : providerIds) {
                data.provider.id = providerId;
                
                HC4__Issue__c sfIssue = RestPrmIssueController.createIssue(data);
                if(sfIssue == null) {
                    return null;
                }
                
                issues.add(sfIssue);
            }
            
            insert issues;
            
            Set<Id> issueIds = new Set<Id>();
            for(HC4__Issue__c i : issues) {
                issueIds.add(i.Id);
            }
            
            List<HC4.uCondition> conditions = new List<HC4.uCondition>();
            conditions.add(new HC4.uCondition('HC4__Issue__c', 'Id', 'IN', HC4.uSet.joinForIn(issueIds)));
            
            uRestController.setStatusCode(uRestController.Created);
            return RestPrmIssueController.performGetSearch(conditions, null);
        }
        catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e);
            uRestController.setStatusCode(uRestController.Conflict, e.getMessage());
        }
        
        return null;
    }
    
    global static RestPrmIssueController.Issue doPost(RestPrmIssueController.Issue data) {
        if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest);   
           return null;
        }
        
        HC4__Issue__c sfIssue = RestPrmIssueController.createIssue(data);
        if(sfIssue == null) {
            return null;
        }
        
        try {
            insert sfIssue;
            uRestController.setLocationHeader(sfIssue.Id);
            uRestController.setStatusCode(uRestController.Created);
            
            return new RestPrmIssueController.Issue(sfIssue.Id);
            
        } catch(Exception e) {
            System.debug(LoggingLevel.ERROR, e);
            uRestController.setStatusCode(uRestController.Conflict, e.getMessage());
        }
        
        return null;
    }
    
    @HttpPut
    global static RestPrmIssueController.Issue doPut(RestPrmIssueController.Issue data) {
        if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest);   
           return null;
        }
        
        if(String.isBlank(data.id)) {
            uRestController.setStatusCode(uRestController.PreconditionFailed, 'Id value is missing');
            return null;
        }
                
        try {
            HC4__Issue__c sfIssue = RestPrmIssueController.createIssue(data);
            if(sfIssue == null) {
                return null;
            }
            
            try {
                HC4__Issue__c original = [Select OwnerId from HC4__Issue__c where Id = :data.id];
                
                if(data.owner != null && data.owner.id != null && data.owner.id != UserInfo.getUserId()) {
                    uRestController.setStatusCode(uRestController.Forbidden, 'You are not have the permission to edit an issue created by someone else.');
                    return null;
                }
            }
            catch(Exception e) {
                System.debug(LoggingLevel.ERROR, e);
                uRestController.setStatusCode(uRestController.NotFound);
                return null;
            }
        
            update sfIssue;
            uRestController.setStatusCode(uRestController.OK);
            return new RestPrmIssueController.Issue(sfIssue.Id);
            
        } catch(Exception e) {
            System.debug(LoggingLevel.ERROR, e);
            uRestController.setStatusCode(uRestController.NotModified, e.getMessage());
        }
        
        return null;
    }
        
    /**
    * Patch is designed as an auto close shortcut mechinism for the Issue object.  When a Task is sent VIA
    * http patch the client assumes they want to set the object to a closed status using the business logic
    * rather than using http put.
    */
    @HttpPatch
    global static void doPatch(List<String> data) {
        if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest);   
           return;
        }
        
        Set<String> issueIds = new Set<String>(data);                
        try {
            List<HC4__Issue__c> sfIssues = [Select Id, OwnerId, HC4__Status__c, HC4__DateTimeClosed__c From HC4__Issue__c where Id in :issueIds];
            if(sfIssues.size() < 1) {
                return;
            }
            
            try {
               for(HC4__Issue__c i : sfIssues) {
               	    if(i.OwnerId != UserInfo.getUserId()) {
	                    uRestController.setStatusCode(uRestController.Forbidden, 'You are not have the permission to edit an issue created by someone else.');
	                    return;
	                }
               }
            }
            catch(Exception e) {
                System.debug(LoggingLevel.ERROR, e);
                uRestController.setStatusCode(uRestController.NotFound);
                return;
            }
            
            /** *******************
            * The following code block is copied from IssueClosedExtension class from HC4 package so the business
            * logic is the same.  HC4 package should be reconfigured to be global so the logic can stay there and be reused
            * by PRM mobile.
            ** *******************/
            List<String> closedStatusOptions = new List<String>();
            for(String s : HC4.uDescribe.getPicklistValues('HC4__Issue__c', 'HC4__Status__c')) {
                if(s.toLowerCase().startsWith('closed')) {
                    closedStatusOptions.add(s);
                }
            }
            
            if(closedStatusOptions.isEmpty()) {
                closedStatusOptions.add(uString.EMPTY);
            }
            for(HC4__Issue__c sfIssue : sfIssues) {         
	            if(sfIssue.HC4__DateTimeClosed__c == null) {
	                sfIssue.HC4__DateTimeClosed__c = DateTime.now();
	            }
	            if(sfIssue.HC4__Status__c != null && !sfIssue.HC4__Status__c.toLowerCase().startsWith('closed')) {
	                sfIssue.HC4__Status__c = 'Closed - Resolved'; //closedStatusOptions.get(0); //T2256 - Fix;
	            }
            }
            /** -- End copied Code -- **/
            
            update sfIssues;
            
        } catch(Exception e) {
            System.debug(LoggingLevel.ERROR, e);
            uRestController.setStatusCode(uRestController.NotModified, e.getMessage());
        }
    }
    
    @HttpDelete
    global static void doDelete() {
        Set<String> issueIds = new Set<String>();
        
        if(!String.IsBlank(uRestController.getParameterValue('ids'))) {
            issueIds.addAll(uRestController.getParameterValue('ids').split(';'));
        }
        
        issueIds.add(uRestController.objectId);
        
        List<HC4__Issue__c> issues = [Select Id, OwnerId from HC4__Issue__c where Id in :issueIds];
        
        if(issues.size() < 1) {
            uRestController.setStatusCode(uRestController.NotFound);
            return;
        }
        
        for(HC4__Issue__c i : issues) {
            if(i.OwnerId != UserInfo.getUserId()) {
                uRestController.setStatusCode(uRestController.Forbidden, 'You are not have the permission to edit an issue created by someone else.');
                return;
            }
        }
        
        delete issues;
        uRestController.setStatusCode(uRestController.OK);
    }
    
    private static HC4__Issue__c createIssue(RestPrmIssueController.Issue i) {        
        HC4__Issue__c sfIssue = new HC4__Issue__c(
            HC4__IsClosed__c = i.isClosed,
            HC4__DateTimeClosed__c = i.dateTimeClosed,
            HC4__DateTimeOpened__c = i.dateTimeOpened,
            HC4__IsEscalated__c = i.isEscalated,
            HC4__Inquiry__c = ((i.inquiry == null || String.IsBlank(i.inquiry.id)) ? null : i.inquiry.Id),
            HC4__InternalComments__c = i.internalComments,
            HC4__LongDescription__c = i.description,
            HC4__Origin__c = i.origin,
            HC4__Priority__c = i.priority,
            HC4__Provider__c = ((i.provider == null || String.IsBlank(i.provider.id)) ? null : i.provider.Id),
            HC4__Reason__c = i.reason,
            HC4__Status__c = i.status,
            HC4__Subject__c = i.subject,
            HC4__Type__c = i.type
        );
        
        if(!String.isBlank(i.id)) {
            sfIssue.Id = i.id;
        }
        return sfIssue;
    }
        
    public static Map<String, String> fieldMap {
        get {
           return uRestController.remapFields(RestPrmIssueController.propertyMap);
        }
    }
    
    private static Map<String, String> localPropertyMap {
        get {
            return new Map<String, String> {
                'id' => 'id',
                'ownerId' => 'ownerid',
                'isClosed' => 'hc4__isclosed__c',
                'dateTimeClosed' => 'hc4__datetimeclosed__c',
                'dateTimeOpened' => 'hc4__datetimeopened__c',
                'isEscalated' => 'hc4__isescalated__c',
                'inquiryId' => 'hc4__inquiry__c',
                'internalComments' => 'hc4__internalcomments__c',
                'description' => 'hc4__longdescription__c',
                'origin' => 'hc4__origin__c',
                'priority' => 'hc4__priority__c',
                'providerId' => 'hc4__provider__c',
                'reason' => 'hc4__reason__c',
                'status' => 'hc4__status__c',
                'subject' => 'hc4__subject__c',
                'type' => 'hc4__type__c',
                'createdDate' => 'CreatedDate'
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
    
    private static List<RestPrmIssueController.Issue> performGetSearch() {
        return RestPrmIssueController.performGetSearch(null, null); 
    }
    
    public static List<RestPrmIssueController.Issue> performGetSearch(List<HC4.uCondition> additionalConditions, List<String> complexConditions) {
        List<String> conditions = new List<String>();
        
        // Issues with Status High and Not Closed - T2415
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
        
        /*Start: Added by PB : 23 Feb - Phab - T2276 */
        Set<String> selectedStatus = new Set<String>();   
        if(!String.isBlank(uRestController.getParameterValue('status'))) {        	 
        	for(String sTemp : uRestController.getParameterValue('status').split(';')){
        		selectedStatus.add(sTemp);
        	}
            conditions.add(new HC4.uCondition('HC4__Issue__c', 'HC4__Status__c', 'IN', ':selectedStatus').toSql());
        }
        /* End: Added by PB : 23 Feb - Phab - T2276 */
        
        
        /*Start: Added by PB : 12 Feb - Phab - T1920 */
        Set<String> selectedPriority = new Set<String>();        
        if(!String.isBlank(uRestController.getParameterValue('priority'))) {        	 
        	for(String sTemp : uRestController.getParameterValue('priority').split(';')){
        		selectedPriority.add(sTemp);
        	}
            conditions.add(new HC4.uCondition('HC4__Issue__c', 'HC4__Priority__c', 'IN', ':selectedPriority').toSql());
        }
        /* End: Added by PB : 12 Feb - Phab - T1920 */ 
        
        //Phab - T2581 
        Set<String> selectedType = new Set<String>();        
        if(!String.isBlank(uRestController.getParameterValue('type'))) {        	 
        	for(String sTemp : uRestController.getParameterValue('type').split(';')){
        		selectedType.add(sTemp);
        	}
            conditions.add(new HC4.uCondition('HC4__Issue__c', 'HC4__Type__c', 'IN', ':selectedType').toSql());
        }
        
        
        conditions.addAll(uRestController.propertyMapToSoql(RestPrmIssueController.propertyMap, 'HC4__Issue__c', new Set<String> { 'createdDate','priority','status','type'})); //Added priority column to ignore - Phab - T1920 & T2276
        
        List<RestPrmIssueController.Issue> response = new List<RestPrmIssueController.Issue>();
        
        Integer pageSize = uRestController.getPageSize(200);
        Integer offSet = uRestController.offset;
        
        List<HC4__Issue__c> result = 
                    (List<HC4__Issue__c>)Database.query(RestPrmIssueController.generateIssueSql(conditions));
        
        for(HC4__Issue__c a : result) {
            response.add(new RestPrmIssueController.Issue(a));
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
                     'HC4__Provider__r.Id, HC4__Provider__r.Name, HC4__Reason__c, HC4__Status__c, HC4__Subject__c,' +
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
    
    global class Issue {
        public String id { get { return String.isBlank(this.id) ? uString.EMPTY: this.id; } set; }
        public Boolean isClosed { get { return this.isClosed == null ? false : this.isClosed; } set; }
        public DateTime dateTimeClosed { get; set; }
        public DateTime dateTimeOpened { get; set; }
        public Boolean isEscalated { get { return this.isEscalated == null ? false : this.isEscalated; } set; }
        public RestPrmInquiryController.Inquiry inquiry { get; set; }
        public String internalComments { get { return String.isBlank(this.internalComments) ? uString.EMPTY: this.internalComments; } set; }
        public String description { get { return String.isBlank(this.description) ? uString.EMPTY: this.description; } set; }
        public String origin { get { return String.isBlank(this.origin) ? uString.EMPTY: this.origin; } set; }
        public String priority { get { return String.isBlank(this.priority) ? uString.EMPTY: this.priority; } set; }
        public RestPrmProviderController.ProviderLite provider { get; set; }
        public String reason { get { return String.isBlank(this.reason) ? uString.EMPTY: this.reason; } set; }
        public String status { get { return String.isBlank(this.status) ? uString.EMPTY: this.status; } set; }
        public String subject { get { return String.isBlank(this.subject) ? uString.EMPTY: this.subject; } set; }
        public String type { get { return String.isBlank(this.type) ? uString.EMPTY: this.type; } set; }
        public DateTime createdDate { get; private set; }
        public RestPrmUserController.RestUser createdBy { get; private set; }
        public DateTime lastModifiedDate { get; private set; }
        public RestPrmUserController.RestUser lastModifiedBy { get; private set; }
        public RestPrmUserController.RestUser owner { get; set; }
        public Boolean isReadOnly { get; private set; }
        
        public Issue(String id) {
            this([Select Id, HC4__IsClosed__c, HC4__DateTImeClosed__c, HC4__DateTimeOpened__c, HC4__isEscalated__c, HC4__Inquiry__c, HC4__InternalComments__c, HC4__LongDescription__c, HC4__Origin__c,
            HC4__Priority__c, HC4__Provider__r.Id, HC4__Provider__r.Name, HC4__Reason__c, HC4__Status__c, HC4__Subject__c, HC4__Type__c, CreatedDate,
            Owner.Id, Owner.Name, CreatedBy.Id, CreatedBy.Name, LastModifiedDate, LastModifiedBy.Id, LastModifiedBy.Name From HC4__Issue__c Where Id = :id]);
        }
        
        public Issue(HC4__Issue__c i) {
            this.id = i.Id;
            this.isClosed = i.HC4__IsClosed__c;
            this.dateTimeClosed = i.HC4__DateTimeClosed__c;
            this.dateTimeOpened = i.HC4__DateTimeOpened__c;
            this.isEscalated = i.HC4__IsEscalated__c;
            this.inquiry = String.IsBlank(i.HC4__Inquiry__c) ? null : new RestPrmInquiryController.Inquiry(i.HC4__Inquiry__c);
            this.internalComments = i.HC4__InternalComments__c;
            this.description = i.HC4__LongDescription__c;
            this.origin = i.HC4__Origin__c;
            this.priority = i.HC4__Priority__c;
            this.provider = String.IsBlank(i.HC4__Provider__c) ? null : new RestPrmProviderController.ProviderLite(i);
            this.reason = i.HC4__Reason__c;
            this.status = i.HC4__Status__c;
            this.subject = i.HC4__Subject__c;
            this.type= i.HC4__Type__c;
            this.createdDate = i.CreatedDate;
            this.createdBy = new RestPrmUserController.RestUser(i.CreatedBy.Id, i.CreatedBy.Name);
            this.lastModifiedDate = i.LastModifiedDate;
            this.lastModifiedBy = new RestPrmUserController.RestUser(i.LastModifiedBy.Id, i.LastModifiedBy.Name);
            this.owner = String.isBlank(i.Owner.Id) ? null : new RestPrmUserController.RestUser(i);
            
            this.isReadOnly = (i.OwnerId != UserInfo.getUserId());
        }
        
        public Issue() {
        	this.isReadOnly = false;
        }
    } 
}