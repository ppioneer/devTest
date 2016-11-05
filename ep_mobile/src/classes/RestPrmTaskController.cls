/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v1/Tasks/*')
global with sharing class RestPrmTaskController {  
       
    @HttpGet
    global static List<RestPrmTaskController.RestTask> doGet() {
    	String objectId = uRestController.objectId;
        if(!String.isBlank(objectId)) {
            List<RestPrmTaskController.RestTask> response = new List<RestPrmTaskController.RestTask>();
        
	        try {
	            response.add(new RestPrmTaskController.RestTask(objectId));
	        }
	        catch(Exception e) {
	            System.debug(LoggingLevel.ERROR, e);
	            uRestController.setStatusCode(uRestController.NotFound);
	        }
	
	        return response;   
        } else {
        	return RestPrmTaskController.performGetSearch();
        }
    }
    
    @HttpPost
    global static List<RestPrmTaskController.RestTask> doPost(RestPrmTaskController.RestTask data, String[] providerIds) {
    	if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest);   
           return null;
        }
        
        if(providerIds == null) {
        	return new List<RestPrmTaskController.RestTask>{ RestPrmTaskController.doPost(data) };
        }
        
        if(data.provider == null) {
        	data.provider = new RestPrmProviderController.ProviderLite();
        }
        
        
        try {
        	List<Task> tasks = new List<Task>();
        	
	        for(String providerId : providerIds) {
	        	data.provider.id = providerId;
	        	
	        	Task sfTask = RestPrmTaskController.createTask(data);
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
	        return RestPrmTaskController.performGetSearch(conditions);
        }
        catch (Exception e) {
        	System.debug(LoggingLevel.ERROR, e);
            uRestController.setStatusCode(uRestController.Conflict, e.getMessage());
        }
        
        return null;
    }
    
    global static RestPrmTaskController.RestTask doPost(RestPrmTaskController.RestTask data) {        
        if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest);   
           return null;
        }
        
        try {
	      Task sfTask = RestPrmTaskController.createTask(data);
	      if(sfTask == null) {
	          return null;
	      }
          
	        insert sfTask;
	        	        
	        uRestController.setLocationHeader(sfTask.Id);
	        uRestController.setStatusCode(uRestController.Created);
	                   
            return new RestPrmTaskController.RestTask(sfTask.Id);
            
        } catch(Exception e) {
            System.debug(LoggingLevel.ERROR, e);
            uRestController.setStatusCode(uRestController.Conflict, e.getMessage());
        }
        
        return null;
    }
    
    @HttpPut
    global static RestPrmTaskController.RestTask doPut(RestPrmTaskController.RestTask data) {        
        if(data == null) {
           uRestController.setStatusCode(uRestController.BadRequest);   
           return null;
        }
        
        if(String.isBlank(data.id)) {
            uRestController.setStatusCode(uRestController.PreconditionFailed, 'Id value is missing');
            return null;
        }
                
        try {
            Task sfTask = RestPrmTaskController.createTask(data);
            if(sfTask == null) {
                return null;
            }
            
            try {
                Task original = [Select OwnerId from Task where Id = :data.id];
                
                if(data.owner != null && data.owner.id != null && data.owner.id != UserInfo.getUserId()) {
                	uRestController.setStatusCode(uRestController.Forbidden, 'You are not have the permission to edit an task created by someone else.');
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
            return new RestPrmTaskController.RestTask(sfTask.Id);
            
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
	                    uRestController.setStatusCode(uRestController.Forbidden, 'You are not have the permission to edit an task created by someone else.');
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
            for(Task sfTask : sfTasks) {
                sfTask.Status = closedStatus.MasterLabel;
            }
            
            update sfTasks;
        }
        catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e);
            uRestController.setStatusCode(uRestController.Conflict, e.getMessage());
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
        		uRestController.setStatusCode(uRestController.Forbidden, 'You are not have the permission to edit an task created by someone else.');
        		return;
        	}
        }
        
        delete tasks;
        uRestController.setStatusCode(uRestController.OK);
    }
    
    private static Task createTask(RestPrmTaskController.RestTask t) {
      if(String.isBlank(t.status)) {
            uRestController.setStatusCode(uRestController.BadRequest, 'Status is required.');
            return null;
        }
        
        if(String.isBlank(t.priority)) {
            uRestController.setStatusCode(uRestController.BadRequest, 'Priority is required.');
            return null;
        }
                
        Task sfTask = new Task (
            WhoId = (t.provider == null || String.isBlank(t.provider.id)) ? null : t.provider.id,
            WhatId = (t.practice == null || String.isBlank(t.practice.id)) ? null : t.practice.id,
            ownerId = (t.owner == null || String.isBlank(t.owner.id)) ? UserInfo.getUserId() : t.owner.id,
            Subject = t.subject,
            ActivityDate = (t.dueDate == null ? null : t.dueDate.date()),
            Description = t.comments,
            Status = t.status,
            Priority = t.priority,
            Type = 'Task',
            ReminderDateTime = t.reminderDateTime
        );
        
        if(!String.isBlank(t.id)) {
            sfTask.Id = t.id;
        }
        
        return sfTask;
    }
    
    public static Map<String, String> fieldMap {
        get {
        	return uRestController.remapFields(RestPrmTaskController.propertyMap);
        }
    }
    
    private static Map<String, String> localPropertyMap {
        get {
            return new Map<String, String> {
                'id' => 'id',
                'providerId' => 'whoId',
                'practiceId' => 'whatid', 
                'owner' => 'ownerid',
                'subject' => 'subject',
                'dueDate' => 'activitydate',
                'comments' => 'description',
                'status' => 'status',
                'priority' => 'priority',
                'isClosed' => 'isclosed',
                'reminderDateTime' => 'reminderdatetime',
                'createdDate' => 'createddate'
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
    
    private static List<RestPrmTaskController.RestTask> performGetSearch() {
    	return RestPrmTaskController.performGetSearch(null);
    }
    
    public static List<RestPrmTaskController.RestTask> performGetSearch(List<HC4.uCondition> additionalConditions) {
    	List<String> conditions = new List<String>();
    	conditions.add('Type != \'Call\' And Type != \'Expense\' And Subject != \'Call\' and Subject != \'Expense\'');
    	
    	if(additionalConditions != null) {
    		for(HC4.uCondition c : additionalConditions) {
    			conditions.add(c.toSql());
    		}
    	}
    	
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
    	
    	List<RestPrmTaskController.RestTask> response = new List<RestPrmTaskController.RestTask>();
    	
    	Integer pageSize = uRestController.getPageSize(200);
        Integer offSet = uRestController.offset;
        
        List<Task> lResult = (List<Task>)Database.query(RestPrmTaskController.generateTaskSql(conditions));
        
        for(Task a : lResult) {
            response.add(new RestPrmTaskController.RestTask(a));
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
    
    global class RestTask {
    	public String id { get { return String.isBlank(this.id) ? uString.EMPTY : this.id; } set; }
    	public String comments { get { return String.isBlank(this.comments) ? uString.EMPTY: this.comments; } set; }
    	public DateTime dueDate { get; set; }
    	public RestPrmProviderController.ProviderLite provider { get; set; }
    	public RestPrmPracticeController.PracticeLite practice { get; set; }
    	public String priority { get { return String.isBlank(this.priority) ? uString.EMPTY: this.priority; } set; }
    	public String status { get { return String.isBlank(this.status) ? uString.EMPTY: this.status; } set; }
    	public String subject { get { return String.isBlank(this.subject) ? uString.EMPTY: this.subject; } set; }
    	public Boolean isClosed { get { return this.isClosed == null ? false : this.isClosed; } set; }
    	public RestPrmUserController.RestUser owner { get; set; }
    	public DateTime reminderDateTime { get; set; }
    	public Boolean isReadOnly { get; private set; }
    	public DateTime createdDate { get; private set; }
    	public RestPrmUserController.RestUser createdBy { get; private set; }
    	public DateTime lastModifiedDate { get; private set; }
        public RestPrmUserController.RestUser lastModifiedBy { get; private set; }
    	
    	public RestTask(String taskId){
    		this([Select 
                        Id,
                        Description,
                        ActivityDate,
                        WhoId,
                        Who.Id,
                        Who.Name,
                        What.Id,
                        What.Name,
                        Priority,
                        Status,
                        Subject,
                        IsClosed,
                        OwnerId,
                        Owner.Id,
                        Owner.Name,
                        ReminderDateTime,
                        CreatedDate,
                        CreatedBy.Id,
                        CreatedBy.Name,
                        LastModifiedDate,
                        LastModifiedBy.Id,
                        LastModifiedBy.Name
                        from Task where Id = :taskId]);
    	}
    	
    	public RestTask(Task t) {
            this.id = t.Id;
            this.comments = t.Description;
            this.dueDate = t.ActivityDate;
            this.provider = String.isBlank(t.Who.Id) ? null : new RestPrmProviderController.ProviderLite(t);
            this.practice = String.isBlank(t.What.Id) ? null : new RestPrmPracticeController.PracticeLite(t);
            this.priority = t.Priority;
            this.status = t.Status;
            this.subject = t.Subject;
            this.isClosed = t.IsClosed;
            this.owner = String.IsBlank(t.Owner.Id) ? null : new RestPrmUserController.RestUser(t);
            this.reminderDateTime = t.ReminderDateTime;
            this.createdDate = t.CreatedDate;
            this.createdBy = new RestPrmUserController.RestUser(t.CreatedBy.Id, t.CreatedBy.Name);
            this.lastModifiedDate = t.LastModifiedDate;
            this.lastModifiedBy = new RestPrmUserController.RestUser(t.LastModifiedBy.Id, t.LastModifiedBy.Name);
	        
            this.isReadOnly = (t.OwnerId != UserInfo.getUserId());
    	}
    	
    	public RestTask() {
    		this.isReadOnly = false;
    	}
    }
}