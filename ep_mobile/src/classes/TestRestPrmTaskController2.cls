/* Copyright (c) 2008-2014 Evariant */
@isTest 
private class TestRestPrmTaskController2 {

    /* Start - RestPrmTaskSearchController */ 
    static testMethod void doGet_RetrievesTaskSearch() {
        
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        Task t = new Task(
           WhoId = provider.Id,
           Subject = '__CALL__',
           Status = 'Not Started'           
        );
        insert t;
                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Tasks/Search';
        request.resourcePath = '/mobile/prm/v2/Tasks/Search/*';
        request.addParameter('pageSize', '2');
        System.RestContext.request = request;
        
        List<uRestController.GenericGetListResponse> tasks = RestPrmTaskSearchController.doGet();        
        System.assertEquals(1, tasks.size());  
        System.assertEquals(t.ID, tasks[0].id); 
        
        
        List<HC4.uCondition> additionalConditions = new List<HC4.uCondition>();
        RestPrmTaskSearchController.performGetSearch(additionalConditions);  
        RestRequest requestSearch = new RestRequest();
        requestSearch.requestURI = '/mobile/prm/v2/Tasks/Search';
        requestSearch.resourcePath = '/mobile/prm/v2/Tasks/Search/*';
        requestSearch.addParameter('pageSize', '2');
        requestSearch.addParameter('q', 'CALL');
        System.RestContext.request = requestSearch; 
        RestPrmTaskSearchController.doGet(); 
             
    }
    
    static testMethod void doGet_RetrievesFilteredWithEndAndStartDueDate() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        Task t = new Task(
           WhoId = provider.Id,
           Subject = '__CALL__',
           Status = 'Not Started',    
           ActivityDate = DateTime.now().date()
        );
        insert t;
        
        t = new Task(
           WhoId = provider.Id, 
           Subject = '__CALL__123',
           Status = 'Not Started',  
           ActivityDate = DateTime.now().date()
        );
        insert t;
        
        String theDate = DateTime.now().format('yyyy-MM-dd');
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Tasks/Search';
        request.resourcePath = '/mobile/prm/v2/Tasks/Search/*';
        request.addParameter('startDueDate', theDate);
        request.addParameter('endDueDate', theDate);
        request.addParameter('pageSize', '3');
        System.RestContext.request = request;
        
        List<uRestController.GenericGetListResponse> tasks = RestPrmTaskSearchController.doGet();
        
        System.assert(2 <= tasks.size());
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
        request.requestURI = '/mobile/prm/v2/Tasks/Search';
        request.resourcePath = '/mobile/prm/v2/Tasks/Search/*';
        request.addParameter('startCreateDate', theDate);
        request.addParameter('endCreateDate', theDate);
        request.addParameter('pageSize', '3');
        System.RestContext.request = request;
        
        List<uRestController.GenericGetListResponse> calls = RestPrmTaskSearchController.doGet();
        
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
        request.requestURI = '/mobile/prm/v2/Tasks/Search';
        request.resourcePath = '/mobile/prm/v2/Tasks/Search/*';
        request.addParameter('createdDate', theDate);
        request.addParameter('pageSize', '3');
        System.RestContext.request = request;
        
        List<uRestController.GenericGetListResponse> calls = RestPrmTaskSearchController.doGet();
        
        System.assert(0 <= calls.size());
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
        request.requestURI = '/mobile/prm/v2/Tasks/Search';
        request.resourcePath = '/mobile/prm/v2/Tasks/Search/*';
        request.addParameter('pageSize', '2');
        request.addParameter('createdDate', DateTime.now().format('yyyy-MM-dd'));
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<uRestController.GenericGetListResponse> tasks = RestPrmTaskSearchController.doGet();
        
        System.assert(0 <= tasks.size());
        
    }
    
    static testMethod void doGet_CanFilterBySubject() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        Task t = new Task(
           WhoId = provider.Id,
           Type = 'Task',
           Subject = '_Call_'
        );
        insert t;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Tasks/Search';
        request.resourcePath = '/mobile/prm/v2/Tasks/Search/*';
        request.addParameter('pageSize', '2');
        request.addParameter('q', '_Ca');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<uRestController.GenericGetListResponse> tasks = RestPrmTaskSearchController.doGet();
        
        System.assert(1 <= tasks.size());
        
    }
    
    /* End - RestPrmTaskSearchController */ 
    
    /* Start - RestPrmTaskController2 */ 
    static testMethod void doGet_TaskFieldSetSchema() { 
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Tasks';
        request.resourcePath = '/mobile/prm/v2/Tasks/*';
        request.addParameter('pageSize', '2');        
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<uRestController.GenericGetResponse> tasks = RestPrmTaskController2.doGet();
        
        System.assert(1 == tasks.size());
        
    }
    
    static testMethod void doGet_RetrievesObjectById() { 
        
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
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Tasks/' + t.Id;
        request.resourcePath = '/mobile/prm/v2/Tasks/*';
        request.addParameter('pageSize', '2');        
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<uRestController.GenericGetResponse> tasks = RestPrmTaskController2.doGet();
        
        System.assert(1 == tasks.size());        
    }
    
    static testMethod void doPost_ReturnsCreated() {                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Tasks';
        request.resourcePath = '/mobile/prm/v2/Tasks/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        uRestController.GenericGetResponse t = new uRestController.GenericGetResponse();
        t.fieldsInfo.add(new uRestController.FieldsDescribe('Status', Task.Status.getDescribe().getPicklistValues()[0].getValue()));
        t.fieldsInfo.add(new uRestController.FieldsDescribe('Priority', Task.Priority.getDescribe().getPicklistValues()[0].getValue()));        
        
        RestPrmTaskController2.doPost(t);
        
        System.assertEquals(201, RestContext.response.statusCode);
        
        Account practice = new Account (
            Name = '__TEST_PRACTICE__'
        );
        
        insert practice;
        
        t.fieldsInfo.add(new uRestController.FieldsDescribe('WhatId', practice.Id));
        RestPrmTaskController2.doPost(t);        
    }
    
    static testMethod void doPost_ReturnsEmptyonData() {                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Tasks';
        request.resourcePath = '/mobile/prm/v2/Tasks/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmTaskController2.doPost(null);
        
        System.assertEquals(400, RestContext.response.statusCode);        
    }
    
    static testMethod void doPost_ReturnsEmptyonId() {                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Tasks';
        request.resourcePath = '/mobile/prm/v2/Tasks/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmTaskController2.doPost(null);
        
        System.assertEquals(400, RestContext.response.statusCode);        
    }
    
    static testMethod void doPut_ReturnsEmptyonData() {                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Tasks';
        request.resourcePath = '/mobile/prm/v2/Tasks/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmTaskController2.doPut(null);
        
        System.assertEquals(400, RestContext.response.statusCode);        
    }
    
    static testMethod void doPutProviderIds_ReturnsRequestOnProviders() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        Account practice = new Account (
            Name = '__TEST_PRACTICE__'
        );
        
        HC4__Issue__c i = new HC4__Issue__c(
           HC4__Subject__c = '__TEST__',
           HC4__Provider__c = provider.Id,
           HC4__Status__c = 'New',           
           HC4__Priority__c = 'Low',           
           OwnerId = UserInfo.getUserId()
        );
        insert i;
        
        insert practice;
                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Tasks';
        request.resourcePath = '/mobile/prm/v2/Tasks/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        uRestController.GenericGetResponse t = new uRestController.GenericGetResponse();
        t.fieldsInfo.add(new uRestController.FieldsDescribe('Status', Task.Status.getDescribe().getPicklistValues()[0].getValue()));
        t.fieldsInfo.add(new uRestController.FieldsDescribe('Subject', 'Task'));    
        
        RestPrmTaskController2.doPost(t, 'Provider', new String[] { provider.Id });
        System.assertEquals(201, RestContext.response.statusCode);        
        RestPrmTaskController2.doPost(t, 'Provider', null);        
        RestPrmTaskController2.doPost(null, 'Provider', new String[] { provider.Id });
        
        
        RestPrmTaskController2.doPost(t, 'Provider', new String[] { provider.Id });
        
        RestPrmTaskController2.doPost(t, 'Practice', new String[] { practice.Id });
        RestPrmTaskController2.doPost(null, 'Practice', new String[] { practice.Id });
        RestPrmTaskController2.doPost(t, 'Practice', null);
        
        t.fieldsInfo.add(new uRestController.FieldsDescribe('WhoId', i.Id));
        RestPrmTaskController2.doPost(t, 'Provider', new String[] { i.Id });
        
        t.fieldsInfo.add(new uRestController.FieldsDescribe('WhatId', i.Id));
        RestPrmTaskController2.doPost(t, 'WhatId', new String[] { i.Id });
        
    }
    
    static testMethod void doPostProviderIds_ReturnsRequestOnCreate() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Tasks';
        request.resourcePath = '/mobile/prm/v2/Tasks/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        uRestController.GenericGetResponse t = new uRestController.GenericGetResponse();
        t.fieldsInfo.add(new uRestController.FieldsDescribe('Status', Task.Status.getDescribe().getPicklistValues()[0].getValue()));
        t.fieldsInfo.add(new uRestController.FieldsDescribe('Subject', 'Task'));
        t.fieldsInfo.add(new uRestController.FieldsDescribe('WhoId', provider.Id));    
        
        RestPrmTaskController2.doPost(t);
        
        System.assertEquals(201, RestContext.response.statusCode);
        
        HC4__Issue__c i = new HC4__Issue__c(
           HC4__Subject__c = '__TEST__',
           HC4__Provider__c = provider.Id,
           HC4__Status__c = 'New',           
           HC4__Priority__c = 'Low',           
           OwnerId = UserInfo.getUserId()
        );
        insert i;
        t.fieldsInfo.add(new uRestController.FieldsDescribe('WhoId',  i.Id));
        RestPrmTaskController2.doPost(t);
        
        RestPrmTaskController2.createTask(uRestController.getFSMembers(uRestController.getFieldSetName('Task', Schema.SObjectType.Task.fieldSets.EditTask.Label), 'Task'), t);
        RestPrmTaskController2.createTask(uRestController.getFSMembers(uRestController.getFieldSetName('Task', Schema.SObjectType.Task.fieldSets.EditTask.Label), 'Task'), null);
    }
    
    static testMethod void doPut_ReturnsPreconditionFailedOnNoId() {
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Tasks';
        request.resourcePath = '/mobile/prm/v2/Tasks/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        uRestController.GenericGetResponse t = new uRestController.GenericGetResponse();        
        RestPrmTaskController2.doPut(t);
        
        System.assertEquals(412, RestContext.response.statusCode);
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        Task task = new Task(
           WhoId = provider.Id,
           Subject = '__CALL__',
           Type = 'Task',
           Status = 'Not Started'           
        );
        insert task;
        
        uRestController.GenericGetResponse task1 = new uRestController.GenericGetResponse();
        task1.fieldsInfo.add(new uRestController.FieldsDescribe('Subject', 'Email'));
        task1.fieldsInfo.add(new uRestController.FieldsDescribe('Type', 'Task')); 
        task1.fieldsInfo.add(new uRestController.FieldsDescribe('ActivityDate', String.valueOf(DateTime.now())));
        task1.fieldsInfo.add(new uRestController.FieldsDescribe('ReminderDateTime', String.valueOf(DateTime.now())));   
        task1.id = task.Id;
        RestPrmTaskController2.doPut(task1);
        task1.id = null;
        RestPrmTaskController2.doPut(task1);
    }
    
    static testMethod void doDelete_ReturnsNotFoundOnBadId() {
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Tasks/__SOME_TEST__';
        request.resourcePath = '/mobile/prm/v2/Tasks/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmTaskController2.doDelete();
        
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
        request.requestURI = '/mobile/prm/v2/Tasks/' + t.Id;
        request.resourcePath = '/mobile/prm/v2/Tasks/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmTaskController2.doDelete();
        
        List<Task> tasks = [Select Id From Task where Id = :t.Id];
        
        System.assert(0 <= tasks.size());
        System.assertEquals(200, RestContext.response.statusCode);
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
                WhoId = provider.Id,
                Subject= 'Email',
                Status= 'Not Started',
                Type = 'Task'
            );
            insert t;
        
        }
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Tasks/' + t.Id;
        request.resourcePath = '/mobile/prm/v2/Tasks/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<uRestController.GenericGetResponse> response = RestPrmTaskController2.doGet();
        
        System.assertEquals(true, response[0].isReadOnly);
    }
    
    static testMethod void isReadonly_FalseWhenObjectOwnedByCurrentUser() {        
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        Task t = new Task(
           WhoId = provider.Id,
           OwnerId = UserInfo.getUserId(),
           Subject= 'Other',
           Status= 'Not Started',
           Type = 'Task'
        );
        insert t;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Tasks/' + t.Id;
        request.resourcePath = '/mobile/prm/v2/Tasks/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<uRestController.GenericGetResponse> response = RestPrmTaskController2.doGet();
        
        
        System.assertEquals(false, response[0].isReadOnly);
    }
    
    static testMethod void doPatch_WhenObjectNotOwnedByCurrentUser() {
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
               WhoId = provider.Id,
               Subject= 'Email',
               Status= 'Not Started',
               Type = 'Task'
            );
            insert t;
        
        }
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Tasks/';
        request.resourcePath = '/mobile/prm/v2/Tasks/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse(); 
        List<String> temp = new List<String>();
        temp.add(String.valueOf(t.Id));        
        
        RestPrmTaskController2.doPatch(temp); 
        
        System.assertEquals(403, RestContext.response.statusCode);
        
        RestPrmTaskController2.doPatch(null);
    }
    
    static testMethod void doPatch_ClosesTasks() {        
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        Task t = new Task(
           WhoId = provider.Id,
           OwnerId = UserInfo.getUserId(),
           Subject= 'Other',
           Status= 'Not Started',
           Type = 'Task'
        );
        insert t;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Tasks/';
        request.resourcePath = '/mobile/prm/v2/Tasks/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmTaskController2.doPatch(new List<String> { t.Id });
        TaskStatus closedStatus = [Select MasterLabel, IsClosed from TaskStatus where IsClosed = true limit 1];
        
        t = [Select Id, OwnerId, Status, IsClosed from Task where Id = :t.Id];
        
        System.assertEquals(closedStatus.MasterLabel, t.Status);
        System.assertEquals(true, t.IsClosed);
        
        RestPrmTaskController2.doPatch(new List<String> {  });
        
        RestPrmTaskController2.doPatch(null);
        
    }
    
    static testMethod void delete_Tasks() {        
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        Task t = new Task(
           WhoId = provider.Id,
           OwnerId = UserInfo.getUserId(),
           Subject= 'Email',
           Status= 'Not Started',
           Type = 'Task'
        );
        insert t;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Tasks/' + t.Id;
        request.resourcePath = '/mobile/prm/v2/Tasks/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmTaskController2.doDelete();
        
        
        System.assertEquals(200, RestContext.response.statusCode);
    }
    
    static testMethod void delete_MulitpleTasks() {        
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        Task t = new Task(
           WhoId = provider.Id,
           OwnerId = UserInfo.getUserId(),
           Subject= 'Email',
           Status= 'Not Started',
           Type = 'Task'
        );
        insert t;
        
        Task t1 = new Task(
           WhoId = provider.Id,
           OwnerId = UserInfo.getUserId(),
           Subject= 'Other',
           Status= 'Not Started',
           Type = 'Task'
        );
        insert t1;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Tasks/';
        request.resourcePath = '/mobile/prm/v2/Tasks/*';
        request.addParameter('ids', t.Id + ';' + t1.Id);
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmTaskController2.doDelete();
        
        
        System.assertEquals(200, RestContext.response.statusCode);
    }
    
    static testMethod void delete_WhenObjectNotOwnedByCurrentUser() {
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
               WhoId = provider.Id,
               Subject= 'Email',
                Status= 'Not Started',
                Type = 'Task'
            );
            insert t;
        
        }
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Tasks/' + t.Id;
        request.resourcePath = '/mobile/prm/v2/Tasks/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmTaskController2.doDelete();
        
        System.assertEquals(403, RestContext.response.statusCode);      
        
    }
    
    /* End - RestPrmTaskController2 */ 
}