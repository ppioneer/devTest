/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v1/Calls/*')
global with sharing class RestPrmCallController {
    
    @HttpGet
    global static List<RestPrmCallController.Call> doGet() {
        String objectId = uRestController.objectId;
        if(!String.isBlank(objectId)) {
            List<RestPrmCallController.Call> response = new List<RestPrmCallController.Call>();
        
	        try {
	            response.add(new RestPrmCallController.Call(objectId));
	        }
	        catch(Exception e) {
	            System.debug(LoggingLevel.ERROR, e);
	            uRestController.setStatusCode(uRestController.NotFound);
	        }
	
	        return response;
        } else {
            return RestPrmCallController.performGetSearch();
        }
    }
    
    @HttpPost
    global static List<RestPrmCallController.Call> doPost(RestPrmCallController.Call data, String[] providerIds) {
        if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest);   
           return null;
        }
        
        if(providerIds == null) {
            return new List<RestPrmCallController.Call>{ RestPrmCallController.doPost(data) };
        }
        
        if(data.provider == null) {
            data.provider = new RestPrmProviderController.ProviderLite();
        }
        
        
        try {
            List<Task> tasks = new List<Task>();
            
            for(String providerId : providerIds) {
                data.provider.id = providerId;
                
                Task sfTask = RestPrmCallController.createTask(data);
                if(sfTask == null) {
                    return null;
                }
                
                tasks.add(sfTask);
            }
            
            insert tasks;
            
            Set<Id> taskIds = new Set<Id>();
            for(Task t : tasks) {
                taskIds.add(t.Id);
            }
            
            List<HC4.uCondition> conditions = new List<HC4.uCondition>();
            conditions.add(new HC4.uCondition('Task', 'Id', 'IN', HC4.uSet.joinForIn(taskIds)));
            
            uRestController.setStatusCode(uRestController.Created);
            return RestPrmCallController.performGetSearch(conditions);
        }
        catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e);
            uRestController.setStatusCode(uRestController.Conflict, e.getMessage());
        }
        
        return null;
    }
    
    global static RestPrmCallController.Call doPost(RestPrmCallController.Call data) {
        if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest);   
           return null;
        }
        
        try {
        	Task sfTask = RestPrmCallController.createTask(data);
	        if(sfTask == null) {
	            return null;
	        }
	        
            insert sfTask;
            uRestController.setLocationHeader(sfTask.Id);
            uRestController.setStatusCode(uRestController.Created);
            
            return new RestPrmCallController.Call(sfTask.Id);
            
        } catch(Exception e) {
            System.debug(LoggingLevel.ERROR, e);
            uRestController.setStatusCode(uRestController.Conflict, e.getMessage());
        }
        
        return null;
    }
    
    @HttpPut
    global static RestPrmCallController.Call doPut(RestPrmCallController.Call data) {
        if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest);   
           return null;
        }
        
        if(String.isBlank(data.id)) {
            uRestController.setStatusCode(uRestController.PreconditionFailed, 'Id value is missing');
            return null;
        }
                
        try {
            Task sfTask = RestPrmCallController.createTask(data);
            if(sfTask == null) {
                return null;
            }
            
            try {
                Task original = [Select OwnerId from Task where Id = :data.id];
                
                if(data.owner != null && data.owner.id != null && data.owner.id != UserInfo.getUserId()) {
                    uRestController.setStatusCode(uRestController.Forbidden, 'You are not have the permission to edit an call created by someone else.');
                    return null;
                }
            }
            catch(Exception e) {
                System.debug(LoggingLevel.ERROR, e);
                uRestController.setStatusCode(uRestController.NotFound);
                return null;
            }
        
            update sfTask;
            uRestController.setStatusCode(uRestController.OK);
            return new RestPrmCallController.Call(sfTask.Id);
            
        } catch(Exception e) {
            System.debug(LoggingLevel.ERROR, e);
            uRestController.setStatusCode(uRestController.NotModified, e.getMessage());
        }
        
        return null;
    }
        
     /**
    * Patch is designed as an auto close shortcut mechinism for the Task object.  When a Task is sent VIA
    * http patch the client assumes they want to set the object to a closed status using the business logic
    * rather than using http put.
    */
    @HttpPatch
    global static void doPatch(List<String> data) {
    	if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest);   
           return;
        }
        
        Set<String> taskIds = new Set<String>(data);
        
        try {
            List<Task> sfTasks = [Select Id, OwnerId, Status from Task where Id in :taskIds];
            if(sfTasks.size() < 1) {
                return;
            }
            
            try {
                for(Task t : sfTasks) {
	                if(t.OwnerId != UserInfo.getUserId()) {
	                    uRestController.setStatusCode(uRestController.Forbidden, 'You are not have the permission to edit an call created by someone else.');
	                    return;
	                }
                }
            }
            catch(Exception e) {
                System.debug(LoggingLevel.ERROR, e);
                uRestController.setStatusCode(uRestController.NotFound);
                return;
            }
            
            TaskStatus closedStatus = [Select MasterLabel, IsClosed from TaskStatus where IsClosed = true limit 1];
            for(Task sfTask: sfTasks) {
                sfTask.Status = closedStatus.MasterLabel;
            }
            
            update sfTasks;
                        
        } catch(Exception e) {
            System.debug(LoggingLevel.ERROR, e);
            uRestController.setStatusCode(uRestController.NotModified, e.getMessage());
        }
    }
    
    @HttpDelete
    global static void doDelete() {
    	Set<String> taskIds = new Set<String>();
    	
    	if(!String.IsBlank(uRestController.getParameterValue('ids'))) {
    		taskIds.addAll(uRestController.getParameterValue('ids').split(';'));
    	}
    	
        taskIds.add(uRestController.objectId);
        
        List<Task> tasks = [Select Id, OwnerId from Task where Id in :taskIds];
        
        if(tasks.size() < 1) {
            uRestController.setStatusCode(uRestController.NotFound);
            return;
        }
        
        for(Task t : tasks) {
            if(t.OwnerId != UserInfo.getUserId()) {
                uRestController.setStatusCode(uRestController.Forbidden, 'You are not have the permission to edit an call created by someone else.');
                return;
            }
        }
        
        delete tasks;
        uRestController.setStatusCode(uRestController.OK);
    }
    
    private static Task createTask(RestPrmCallController.Call c) {
    	if(String.isBlank(c.comments)) {
            uRestController.setStatusCode(uRestController.BadRequest, 'Comments is required.');
            return null;
        }
                       
        Task sfTask = new Task (
            WhoId = (c.provider == null || String.isBlank(c.provider.id)) ? null : c.provider.id,
            WhatId = (c.practice == null || String.isBlank(c.practice.id)) ? null : c.practice.id,
            ownerId = (c.owner == null || String.IsBlank(c.owner.id)) ? UserInfo.getUserId() : c.owner.Id,
            Subject = 'Call',
            Description = c.comments,
            Status = uRestController.getDefaultPicklistValue(Schema.sObjectType.Task.fields.Status),
            Priority = uRestController.getDefaultPicklistValue(Schema.sObjectType.Task.fields.Priority),
            Type = 'Call'
        );
        
        if(!String.isBlank(c.id)) {
            sfTask.Id = c.id;
        }
        
        return sfTask;
    }
    
        
    public static Map<String, String> fieldMap {
        get {
            return uRestController.remapFields(RestPrmCallController.propertyMap);
        }
    }
    
    private static Map<String, String> localPropertyMap {
        get {
            return new Map<String, String> {
                'id' => 'id',
                'providerId' => 'whoid',
                'practiceId' => 'whatid', 
                'ownerId' => 'ownerid',
                'subject' => 'subject',
                'comments' => 'description'
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
    
    private static List<RestPrmCallController.Call> performGetSearch() {
        return RestPrmCallController.performGetSearch(null);
    }
    
    public static List<RestPrmCallController.Call> performGetSearch(List<HC4.uCondition> additionalConditions) {
        List<String> conditions = new List<String>();
        conditions.add('Subject = \'Call\''); // Uncommented for //T1998 //T2565
        
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
        
        List<RestPrmCallController.Call> response = new List<RestPrmCallController.Call>();
        
        Integer pageSize = uRestController.getPageSize(200);
        Integer offSet = uRestController.offset;
        
        List<Task> result = 
                    (List<Task>)Database.query(RestPrmCallController.generateCallSql(conditions));
        
        for(Task a : result) {
            response.add(new RestPrmCallController.Call(a));
        }
        
        uRestController.setPagingHeaders(pageSize, offSet, response.size());
        return response;
    }
    
    private static String generateCallSql(List<String> filters) {
        if(filters == null) {
            filters = new List<String>();
        }
        
        String sql = 'Select Id, Who.Id, Who.Name, What.Id, What.Name, Owner.Id, Owner.Name, OwnerId, Subject,' +  
                     'Description, CreatedDate, CreatedBy.Id, CreatedBy.Name, LastModifiedDate, LastModifiedBy.Id, LastModifiedBy.Name from Task';
                     
       if(filters.size() > 0 ) {
         sql += (' WHERE ' + HC4.uList.join(filters, ' AND '));
       }
       
       //Phab Fix - T1820 - Sending additonal Parameter as CreatedDate for sorting      
       sql += uRestController.decodeSortForSoql('dueDate', RestPrmCallController.propertyMap, new Map<String, String> { 'createdDate' => 'CreatedDate' });
       sql += ' LIMIT :pageSize OFFSET :offset';
       
       System.debug(LoggingLevel.ERROR, sql);
       return sql;
        
    }
        
    global class Call {
    	public String id { get { return String.isBlank(this.id) ? uString.EMPTY : this.id; } set; }
    	public RestPrmProviderController.ProviderLite provider { get; set; }
    	public RestPrmPracticeController.PracticeLite practice { get; set; }
    	public RestPrmUserController.RestUser owner { get; set; }
    	public String subject { get { return String.isBlank(this.subject) ? uString.EMPTY: this.subject; } set; }
    	public String comments { get { return String.isBlank(this.comments) ? uString.EMPTY: this.comments; } set; } 	
	    public DateTime createdDate { get; private set; }
	    public RestPrmUserController.RestUser createdBy { get; private set; }
	    public DateTime lastModifiedDate { get; private set; }
        public RestPrmUserController.RestUser lastModifiedBy { get; private set; }
	    public Boolean isReadOnly { get; private set; }  	
    	
    	public Call() {
    		this.isReadOnly = false;
    	}
    	
    	public Call(String id) {
    		this([Select 
    		          Id, 
    		          Who.Id,
    		          Who.Name, 
    		          What.Id,
    		          What.Name, 
    		          Owner.Id,
    		          Owner.Name,
    		          OwnerId,  
    		          Subject, 
    		          Description,
    		          CreatedDate,
    		          CreatedBy.Id,
    		          CreatedBy.Name,
    		          LastModifiedDate,
                      LastModifiedBy.Id,
                      LastModifiedBy.Name 
		          From Task where Id = :id]);
    	}
    	
    	public Call(Task t) {
    		this.id = t.Id;
    		this.provider = String.isBlank(t.Who.Id) ? null : new RestPrmProviderController.ProviderLite(t);
    		this.practice = String.isBlank(t.What.Id) ? null : new RestPrmPracticeController.PracticeLite(t);
    		this.owner = new RestPrmUserController.RestUser(t);
    		this.subject = t.Subject;
    		this.comments = t.Description;
    		this.createdDate = t.CreatedDate;
    		this.createdBy = new RestPrmUserController.RestUser(t.CreatedBy.Id, t.CreatedBy.Name);
    		this.lastModifiedDate = t.LastModifiedDate;
            this.lastModifiedBy = new RestPrmUserController.RestUser(t.LastModifiedBy.Id, t.LastModifiedBy.Name);
    		this.isReadOnly = (t.OwnerId != UserInfo.getUserId());
    	}
    }
}