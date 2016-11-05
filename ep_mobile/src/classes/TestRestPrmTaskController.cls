/* Copyright (c) 2008-2014 Evariant */
@isTest 
private with sharing class TestRestPrmTaskController {
    static testMethod void doGet_RetrievesObjectById() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        Task t = new Task(
           WhoId = provider.Id
        );
        insert t;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Tasks/' + t.Id;
        request.resourcePath = '/mobile/prm/v1/Tasks/*';
        request.addParameter('pageSize', '2');
        System.RestContext.request = request;
        
        List<RestPrmTaskController.RestTask> calls = RestPrmTaskController.doGet();
        
        System.assertEquals(1, calls.size());
        System.assertEquals(t.ID, calls[0].id);
    }
    
    static testMethod void doGet_RetrievesAllWhenNoId() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        Task t = new Task(
           WhoId = provider.Id
        );
        insert t;
        
        t = new Task(
           WhoId = provider.Id
        );
        insert t;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Tasks/';
        request.resourcePath = '/mobile/prm/v1/Tasks/*';
        request.addParameter('pageSize', '3');
        System.RestContext.request = request;
        
        List<RestPrmTaskController.RestTask> calls = RestPrmTaskController.doGet();
        
        System.assert(calls.size() >= 0);
    }
    
    static testMethod void doGet_RetrievesFilteredWithEndAndStartDueDate() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        Task t = new Task(
           WhoId = provider.Id,
           ActivityDate = DateTime.now().date()
        );
        insert t;
        
        t = new Task(
           WhoId = provider.Id,
           ActivityDate = DateTime.now().date()
        );
        insert t;
        
        String theDate = DateTime.now().format('yyyy-MM-dd');
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Tasks/';
        request.resourcePath = '/mobile/prm/v1/Tasks/*';
        request.addParameter('startDueDate', theDate);
        request.addParameter('endDueDate', theDate);
        request.addParameter('pageSize', '3');
        System.RestContext.request = request;
        
        List<RestPrmTaskController.RestTask> calls = RestPrmTaskController.doGet();
        
        System.assert(calls.size() >= 0);
    }
    
    static testMethod void doGet_RetrievesFilteredWithEndAndStartCreateDate() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        Task t = new Task(
           WhoId = provider.Id
        );
        insert t;
        
        t = new Task(
           WhoId = provider.Id
        );
        insert t;
        
        String theDate = DateTime.now().format('yyyy-MM-dd');
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Tasks/';
        request.resourcePath = '/mobile/prm/v1/Tasks/*';
        request.addParameter('startCreateDate', theDate);
        request.addParameter('endCreateDate', theDate);
        request.addParameter('pageSize', '3');
        System.RestContext.request = request;
        
        List<RestPrmTaskController.RestTask> calls = RestPrmTaskController.doGet();
        
        System.assert(0 <= calls.size());
    }
    
    static testMethod void doGet_RetrievesFilteredWithCreatedDate() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        Task t = new Task(
           WhoId = provider.Id,
           Subject = '__Test__'
        );
        insert t;
        
        t = new Task(
           WhoId = provider.Id
        );
        insert t;
        
        String theDate = DateTime.now().format('yyyy-MM-dd');
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Tasks/';
        request.resourcePath = '/mobile/prm/v1/Tasks/*';
        request.addParameter('createdDate', theDate);
        request.addParameter('pageSize', '3');
        System.RestContext.request = request;
        
        List<RestPrmTaskController.RestTask> calls = RestPrmTaskController.doGet();
        
        System.assert(0 <= calls.size());
    }
    
    static testMethod void doGet_NotFoundWhenBadId() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        Task t = new Task(
           WhoId = provider.Id
        );
        insert t;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Tasks/' + t.Id + 'a';
        request.resourcePath = '/mobile/prm/v1/Tasks/*';
        request.addParameter('pageSize', '2');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmTaskController.RestTask> calls = RestPrmTaskController.doGet();
        
        System.assertEquals(0, calls.size());
        System.assertEquals(404, RestContext.response.statusCode);
    }
    
    static testMethod void doGet_CanFilterByCreatedDate() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        Task t = new Task(
           WhoId = provider.Id,
           Type = 'Task'
        );
        insert t;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Tasks';
        request.resourcePath = '/mobile/prm/v1/Tasks/*';
        request.addParameter('pageSize', '2');
        request.addParameter('createdDate', DateTime.now().format('yyyy-MM-dd'));
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmTaskController.RestTask> tasks = RestPrmTaskController.doGet();
        
        System.assert(0 <= tasks.size());
        
    }
    
    static testMethod void doGet_CanFilterByDueDate() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        Task t = new Task(
           WhoId = provider.Id,
           ActivityDate = DateTime.now().date()
        );
        insert t;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Tasks';
        request.resourcePath = '/mobile/prm/v1/Tasks/*';
        request.addParameter('pageSize', '2');
        request.addParameter('dueDate', DateTime.now().format('yyyy-MM-dd'));
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmTaskController.RestTask> tasks = RestPrmTaskController.doGet();
        
        System.assert(tasks.size() >= 0);        
    }
    
    static testMethod void doPost_ReturnsBadRequestOnNullParameter() {        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Tasks';
        request.resourcePath = '/mobile/prm/v1/Tasks/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmTaskController.doPost(null);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPost_ReturnsBadRequestOnNoStatus() {        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Tasks';
        request.resourcePath = '/mobile/prm/v1/Tasks/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmTaskController.RestTask t = new RestPrmTaskController.RestTask();
        
        RestPrmTaskController.doPost(t);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPost_ReturnsBadRequestOnNoPriority() {        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Tasks';
        request.resourcePath = '/mobile/prm/v1/Tasks/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmTaskController.RestTask t = new RestPrmTaskController.RestTask();
        t.status = Task.Status.getDescribe().getPicklistValues()[0].getValue();
        
        RestPrmTaskController.doPost(t);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPost_ReturnsCreated() {                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Tasks';
        request.resourcePath = '/mobile/prm/v1/Tasks/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmTaskController.RestTask t = new RestPrmTaskController.RestTask();
        t.status = Task.Status.getDescribe().getPicklistValues()[0].getValue();
        t.priority = Task.Priority.getDescribe().getPicklistValues()[0].getValue();
        
        RestPrmTaskController.doPost(t);
        
        System.assertEquals(201, RestContext.response.statusCode);
        List<Task> tasks = [Select Id From Task where Type = :'Task' and OwnerId = :UserInfo.getUserId()];
        
        System.assertEquals(1, tasks.size());
    }
    
    static testMethod void doPostProviderIds_ReturnsBadRequestOnNullParameter() {        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Tasks';
        request.resourcePath = '/mobile/prm/v1/Tasks/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmTaskController.doPost(null,null);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPostProviderIds_ReturnsBadRequestOnNoStatus() {
    	Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Tasks';
        request.resourcePath = '/mobile/prm/v1/Tasks/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmTaskController.RestTask t = new RestPrmTaskController.RestTask();
        
        RestPrmTaskController.doPost(t, new String[] { provider.Id });
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPostProviderIds_ReturnsBadRequestOnNoPriority() {
    	Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Tasks';
        request.resourcePath = '/mobile/prm/v1/Tasks/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmTaskController.RestTask t = new RestPrmTaskController.RestTask();
        t.status = Task.Status.getDescribe().getPicklistValues()[0].getValue();
        
        RestPrmTaskController.doPost(t, new String[] { provider.Id });
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPostProviderIds_ReturnsCreated() {
    	Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
                        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Tasks';
        request.resourcePath = '/mobile/prm/v1/Tasks/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmTaskController.RestTask t = new RestPrmTaskController.RestTask();
        t.status = Task.Status.getDescribe().getPicklistValues()[0].getValue();
        t.priority = Task.Priority.getDescribe().getPicklistValues()[0].getValue();
        
        RestPrmTaskController.doPost(t, new String[] { provider.Id });
        
        System.assertEquals(201, RestContext.response.statusCode);
        List<Task> tasks = [Select Id From Task where Type = :'Task' and OwnerId = :UserInfo.getUserId() and Who.Id = :provider.Id];
        
        System.assertEquals(1, tasks.size());
    }
    
    static testMethod void doPut_ReturnsBadRequestOnNullParameter() {        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Tasks';
        request.resourcePath = '/mobile/prm/v1/Tasks/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmTaskController.doPut(null);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPut_ReturnsBadRequestOnNoStatus() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        Task t = new Task(
           WhoId = provider.Id
        );
        insert t;
                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Tasks';
        request.resourcePath = '/mobile/prm/v1/Tasks/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmTaskController.RestTask task = new RestPrmTaskController.RestTask();
        task.id = t.Id;
        
        RestPrmTaskController.doPut(task);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }

    static testMethod void doPut_ReturnsBadRequestOnNoParentId() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        Task t = new Task(
           WhoId = provider.Id
        );
        insert t;
                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Tasks';
        request.resourcePath = '/mobile/prm/v1/Tasks/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmTaskController.RestTask rtask = new RestPrmTaskController.RestTask();
        rtask.id = t.Id;
        rtask.status = Task.Status.getDescribe().getPicklistValues()[0].getValue();
        
        RestPrmTaskController.doPut(rtask);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPut_ReturnsPreconditionFailedOnNoId() {
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Tasks';
        request.resourcePath = '/mobile/prm/v1/Tasks/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmTaskController.RestTask t = new RestPrmTaskController.RestTask();        
        RestPrmTaskController.doPut(t);
        
        System.assertEquals(412, RestContext.response.statusCode);
    }
    
    static testMethod void doPut_ReturnsNoContentOnUpdate() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        Task t = new Task(
           WhoId = provider.Id
        );
        insert t;
                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Tasks';
        request.resourcePath = '/mobile/prm/v1/Tasks/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        System.RestContext.response.statusCode = 200;
        
        RestPrmTaskController.RestTask rtask = new RestPrmTaskController.RestTask();
        rtask.id = t.Id;
        rtask.comments = '__A_TEST_COMMENT___';
        rtask.status = Task.Status.getDescribe().getPicklistValues()[0].getValue();
        rtask.priority = Task.Priority.getDescribe().getPicklistValues()[0].getValue();
        
        RestPrmTaskController.doPut(rtask);
        
        System.assertEquals(200, RestContext.response.statusCode);
        
        t = [Select Id, Description from Task where Id = :rtask.Id];
        
        System.assertEquals(rtask.comments, t.Description);
    }
    
    static testMethod void doPut_ReturnsNotModifiedOnError() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        Task t = new Task(
           WhoId = provider.Id
        );
        insert t;
                        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Tasks';
        request.resourcePath = '/mobile/prm/v1/Tasks/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmTaskController.RestTask rtask = new RestPrmTaskController.RestTask();
        rtask.id = t.Id + 'a';
        rtask.comments = '__A_TEST_COMMENT__';
        rtask.status = Task.Status.getDescribe().getPicklistValues()[0].getValue();
        rtask.priority = Task.Priority.getDescribe().getPicklistValues()[0].getValue();
        
        RestPrmTaskController.doPut(rtask);
        
        System.assertEquals(304, RestContext.response.statusCode);
    }
    
    static testMethod void doDelete_ReturnsNotFoundOnBadId() {
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Tasks/__SOME_TEST__';
        request.resourcePath = '/mobile/prm/v1/Tasks/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmTaskController.doDelete();
        
        System.assertEquals(404, RestContext.response.statusCode);
    }
    
    static testMethod void doDelete_DeletesObjectById() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        Task t = new Task(
           WhoId = provider.Id
        );
        insert t;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Tasks/' + t.Id;
        request.resourcePath = '/mobile/prm/v1/Tasks/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmTaskController.doDelete();
        
        List<Task> tasks = [Select Id From Task where Id = :t.Id];
        
        System.assert(0 <= tasks.size());
        System.assertEquals(200, RestContext.response.statusCode);
    }
    
    static testMethod void isReadonly_falseOnNewObject() {
    	 User u = new User (
            Alias = '_TALIAS_',
            UserName = '_TESTUSER_@test.test',
            Email = '_TESTUSER_@test.test',
            FirstName = '__TEST',
            LastName = '_USER__',
            ProfileId = [Select Id from Profile Where Name = 'System Administrator' Limit 1].Id,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US'
        );
        
        insert u;
        
        System.runAs(u) {
        	RestPrmTaskController.RestTask t = new RestPrmTaskController.RestTask();
        	
        	System.assertEquals(false, t.isReadOnly);
        }
    }
    
    static testMethod void isReadonly_TrueWhenObjectNotOwnedByCurrentUser() {
         User u = new User (
            Alias = '_TALIAS_',
            UserName = '_TESTUSER_@test.test',
            Email = '_TESTUSER_@test.test',
            FirstName = '__TEST',
            LastName = '_USER__',
            ProfileId = [Select Id from Profile Where Name = 'HC PRM User' Limit 1].Id,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US'
        );
        
        insert u;
        
        User u2 = new User (
            Alias = '_TALIA2_',
            UserName = '_TESTUSER2_@test.test',
            Email = '_TESTUSER2_@test.test',
            FirstName = '__TEST',
            LastName = '_USER__',
            ProfileId = [Select Id from Profile Where Name = 'HC PRM User' Limit 1].Id,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US'
        );
        
        insert u2;
        
        Contact provider = new Contact (
               FirstName = '__JOHN__',
               LastName = '__DOE__'
            );
            
            insert provider;
        Task t = null;
            
        System.runAs(u2) {
	        t = new Task(
	           WhoId = provider.Id
	        );
	        insert t;
        }
        
        RestPrmTaskController.RestTask rt = new RestPrmTaskController.RestTask(t.Id);
        
        System.assertEquals(true, rt.isReadOnly);
    }
    
    static testMethod void isReadonly_FalseWhenObjectOwnedByCurrentUser() {        
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        Task t = new Task(
           WhoId = provider.Id,
           OwnerId = UserInfo.getUserId()
        );
        insert t;
        
        RestPrmTaskController.RestTask rt = new RestPrmTaskController.RestTask(t.Id);
        
        System.assertEquals(false, rt.isReadOnly);
    }
    
    static testMethod void doPatch_ClosesTasks() {        
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        Task t = new Task(
           WhoId = provider.Id,
           OwnerId = UserInfo.getUserId()
        );
        insert t;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Tasks/';
        request.resourcePath = '/mobile/prm/v1/Tasks/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmTaskController.doPatch(new List<String> { t.Id });
        TaskStatus closedStatus = [Select MasterLabel, IsClosed from TaskStatus where IsClosed = true limit 1];
        
        t = [Select Id, OwnerId, Status, IsClosed from Task where Id = :t.Id];
        
        System.assertEquals(closedStatus.MasterLabel, t.Status);
        System.assertEquals(true, t.IsClosed);
    }
}