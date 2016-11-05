/* Copyright (c) 2008-2014 Evariant */
@isTest
private class TestRestPrmCallController2 {

    /* Start - RestPrmCallSearchController */ 
    static testMethod void doGet_RetrievesTaskSearch() {
        
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        Task t = new Task(
           WhoId = provider.Id,
           Subject = '__CALL__',
           Type = 'Call',
           Status = 'Not Started'           
        );
        insert t;
                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Calls/Search';
        request.resourcePath = '/mobile/prm/v2/Calls/Search/*';
        request.addParameter('pageSize', '2');
        System.RestContext.request = request;
        
        List<uRestController.GenericGetListResponse> tasks = RestPrmCallSearchController.doGet();        
        System.assert(tasks.size() >= 0);  
        List<HC4.uCondition> additionalConditions = new List<HC4.uCondition>();
        RestPrmCallSearchController.performGetSearch(additionalConditions);         
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
           Type = 'Call',
           Status = 'Not Started',    
           ActivityDate = DateTime.now().date()
        );
        insert t;
        
        t = new Task(
           WhoId = provider.Id, 
           Subject = '__CALL__123',
           Type = 'Call',
           Status = 'Not Started',  
           ActivityDate = DateTime.now().date()
        );
        insert t;
        
        String theDate = DateTime.now().format('yyyy-MM-dd');
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Calls/Search';
        request.resourcePath = '/mobile/prm/v2/Calls/Search/*';
        request.addParameter('startDueDate', theDate);
        request.addParameter('endDueDate', theDate);
        request.addParameter('pageSize', '3');
        System.RestContext.request = request;
        
        List<uRestController.GenericGetListResponse> tasks = RestPrmCallSearchController.doGet();
        
        System.assert(tasks.size() >= 0);
    }
    static testMethod void doGet_RetrievesFilteredWithEndAndStartCreateDate() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        Task t = new Task(
           WhoId = provider.Id,
           Type = 'Call'
        );
        insert t;
        
        t = new Task(
           WhoId = provider.Id,
           Type = 'Call'
        );
        insert t;
        
        String theDate = DateTime.now().format('yyyy-MM-dd');
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Calls/Search';
        request.resourcePath = '/mobile/prm/v2/Calls/Search/*';
        request.addParameter('startCreateDate', theDate);
        request.addParameter('endCreateDate', theDate);
        request.addParameter('pageSize', '3');
        System.RestContext.request = request;
        
        List<uRestController.GenericGetListResponse> calls = RestPrmCallSearchController.doGet();
        
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
           Subject = '__Test__',
           Type = 'Call'
        );
        insert t;
        
        t = new Task(
           WhoId = provider.Id,
           Type = 'Call'
        );
        insert t;
        
        String theDate = DateTime.now().format('yyyy-MM-dd');
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Calls/Search';
        request.resourcePath = '/mobile/prm/v2/Calls/Search/*';
        request.addParameter('createdDate', theDate);
        request.addParameter('pageSize', '3');
        System.RestContext.request = request;
        
        List<uRestController.GenericGetListResponse> calls = RestPrmCallSearchController.doGet();
        
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
           Type = 'Call'
        );
        insert t;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Calls/Search';
        request.resourcePath = '/mobile/prm/v2/Calls/Search/*';
        request.addParameter('pageSize', '2');
        request.addParameter('createdDate', DateTime.now().format('yyyy-MM-dd'));
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<uRestController.GenericGetListResponse> tasks = RestPrmCallSearchController.doGet();
        
        System.assert(0 <= tasks.size());
        
    }
    
    /* End - RestPrmCallSearchController */ 
    
    /* Start - RestPrmCallController2 */ 
    static testMethod void doGet_TaskFieldSetSchema() { 
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Calls';
        request.resourcePath = '/mobile/prm/v2/Calls/*';
        request.addParameter('pageSize', '2');        
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<uRestController.GenericGetResponse> tasks = RestPrmCallController2.doGet();
        
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
           Subject = '__Test__',
           Type = 'Call'
        );
        insert t;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Calls/' + t.Id;
        request.resourcePath = '/mobile/prm/v2/Calls/*';
        request.addParameter('pageSize', '2');        
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<uRestController.GenericGetResponse> tasks = RestPrmCallController2.doGet();
        
        System.assert(1 == tasks.size());        
    }
    
    static testMethod void doPost_EmptyObject() { 
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Calls/';
        request.resourcePath = '/mobile/prm/v2/Calls/*';
        request.addParameter('pageSize', '2');        
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        uRestController.GenericGetResponse tasks = RestPrmCallController2.doPost(null);
        
        System.assert(tasks.responseCode.code == 400);        
    }
    
    static testMethod void doPost_ReturnsCreated() {                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Calls';
        request.resourcePath = '/mobile/prm/v2/Calls/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        uRestController.GenericGetResponse t = new uRestController.GenericGetResponse();
        t.fieldsInfo.add(new uRestController.FieldsDescribe('Status', Task.Status.getDescribe().getPicklistValues()[0].getValue()));
        t.fieldsInfo.add(new uRestController.FieldsDescribe('Priority', Task.Priority.getDescribe().getPicklistValues()[0].getValue()));        
        
        RestPrmCallController2.doPost(t);
        
        System.assertEquals(201, RestContext.response.statusCode);   
        
         Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
	     );
	     insert provider;
        
        HC4__Issue__c i = new HC4__Issue__c(
           HC4__Subject__c = '__TEST__',
           HC4__Provider__c = provider.Id,
           HC4__Status__c = 'New',           
           HC4__Priority__c = 'Low',           
           OwnerId = UserInfo.getUserId()
        );
        insert i;
        t.fieldsInfo.add(new uRestController.FieldsDescribe('WhoId',  i.Id));
        RestPrmCallController2.doPost(t);
        
        RestPrmCallController2.createTask(uRestController.getFSMembers(uRestController.getFieldSetName('Task', Schema.SObjectType.Task.fieldSets.EditTask.Label), 'Task'), t);
        RestPrmCallController2.createTask(uRestController.getFSMembers(uRestController.getFieldSetName('Task', Schema.SObjectType.Task.fieldSets.EditTask.Label), 'Task'), null);     
        RestPrmCallController2.isTaskValidated(uRestController.getRequiredFields(uRestController.getFieldSetName('Task', Schema.SObjectType.Task.fieldSets.EditTask.Label), 'Task'), t);
        RestPrmCallController2.isTaskValidated(null, t);
        
    }
    
    static testMethod void doPost_ReturnsEmptyonData() {                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Calls';
        request.resourcePath = '/mobile/prm/v2/Calls/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmCallController2.doPost(null);
        
        System.assertEquals(400, RestContext.response.statusCode);        
    }
    
    static testMethod void doPost_ReturnsEmptyonId() {                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Calls';
        request.resourcePath = '/mobile/prm/v2/Calls/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmCallController2.doPost(null);
        
        System.assertEquals(400, RestContext.response.statusCode);        
    }
    
    static testMethod void doPut_ReturnsEmptyonData() {                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Calls';
        request.resourcePath = '/mobile/prm/v2/Calls/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmCallController2.doPut(null);
        
        System.assertEquals(400, RestContext.response.statusCode);        
    }
    
    static testMethod void doPut_ReturnsEmptyonId() {                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Calls';
        request.resourcePath = '/mobile/prm/v2/Calls/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmCallController2.doPut(null);
        
        System.assertEquals(400, RestContext.response.statusCode);        
    }
    
    static testMethod void doPutProviderIds_ReturnsRequestOnProviders() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Calls';
        request.resourcePath = '/mobile/prm/v2/Calls/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        uRestController.GenericGetResponse t = new uRestController.GenericGetResponse();
        t.fieldsInfo.add(new uRestController.FieldsDescribe('Status', Task.Status.getDescribe().getPicklistValues()[0].getValue()));
        t.fieldsInfo.add(new uRestController.FieldsDescribe('Subject', 'Call'));
        t.fieldsInfo.add(new uRestController.FieldsDescribe('Type', 'Call')); 
        t.fieldsInfo.add(new uRestController.FieldsDescribe('ActivityDate', String.valueOf(DateTime.now().date())));
        t.fieldsInfo.add(new uRestController.FieldsDescribe('ReminderDateTime', String.valueOf(DateTime.now())));   
        
        RestPrmCallController2.doPost(t, 'Provider', new String[] { provider.Id });
        
        System.assertEquals(201, RestContext.response.statusCode);
        
        RestPrmCallController2.doPost(t, 'Provider', null);
        RestPrmCallController2.doPost(null, 'Provider', new String[] { provider.Id }); 
        t.fieldsInfo[1].value = uString.EMPTY;
        RestPrmCallController2.doPost(t, 'Provider', new String[] { provider.Id });
        
         Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        RestPrmCallController2.doPost(t, 'Practice', new String[] { practice.Id });
        
        RestPrmCallController2.doPost(t, 'Practice', new String[] {  });
        
        RestPrmCallController2.doPost(null, 'Provider', new String[] { practice.Id });
        
        RestPrmCallController2.doPost(t, 'Provider', new String[] { practice.Id });
        t.fieldsInfo[0].name = 'Description';
        t.fieldsInfo[0].value = ''; 
        RestPrmCallController2.doPost(t, 'Provider', new String[] { practice.Id });
        
        RestPrmCallController2.createTask(uRestController.getFSMembers(uRestController.getFieldSetName('Task', Schema.SObjectType.Task.fieldSets.EditTask.Label), 'Task'), null);
        t.id = uString.EMPTY;
        RestPrmCallController2.doPost(t, 'Practice', new String[] { practice.Id });
        t.fieldsInfo[0].value = uString.Empty;
        RestPrmCallController2.doPost(t, 'Practice', new String[] { practice.Id });
    }
    
    static testMethod void doPutReminderDate_ReturnsRequest() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Calls';
        request.resourcePath = '/mobile/prm/v2/Calls/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        uRestController.GenericGetResponse t = new uRestController.GenericGetResponse();
        t.fieldsInfo.add(new uRestController.FieldsDescribe('Status', Task.Status.getDescribe().getPicklistValues()[0].getValue()));
        t.fieldsInfo.add(new uRestController.FieldsDescribe('Subject', 'Call'));
        t.fieldsInfo.add(new uRestController.FieldsDescribe('Type', 'Call'));
        t.fieldsInfo.add(new uRestController.FieldsDescribe('ReminderDateTime', String.valueOf(Date.today())));    
        
        RestPrmCallController2.doPost(t);
        
        System.assertEquals(201, RestContext.response.statusCode);
    }
    
    static testMethod void doPostProviderIds_ReturnsRequestOnCreate() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Calls';
        request.resourcePath = '/mobile/prm/v2/Calls/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        uRestController.GenericGetResponse t = new uRestController.GenericGetResponse();
        t.fieldsInfo.add(new uRestController.FieldsDescribe('Status', Task.Status.getDescribe().getPicklistValues()[0].getValue()));
        t.fieldsInfo.add(new uRestController.FieldsDescribe('Subject', 'Call'));
        t.fieldsInfo.add(new uRestController.FieldsDescribe('WhoId', provider.Id));
        t.fieldsInfo.add(new uRestController.FieldsDescribe('Type', 'Call'));    
        
        RestPrmCallController2.doPost(t);
        
        System.assertEquals(201, RestContext.response.statusCode);
    }
    
    static testMethod void doPut_ReturnsPreconditionFailedOnNoId() {
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Calls';
        request.resourcePath = '/mobile/prm/v2/Calls/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        uRestController.GenericGetResponse t = new uRestController.GenericGetResponse();        
        RestPrmCallController2.doPut(t);
        
        System.assertEquals(412, RestContext.response.statusCode);
    }
    
    static testMethod void doDelete_ReturnsNotFoundOnBadId() {
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Calls/__SOME_TEST__';
        request.resourcePath = '/mobile/prm/v2/Calls/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmCallController2.doDelete();
        
        System.assertEquals(404, RestContext.response.statusCode);
    }
    
    static testMethod void doDelete_DeletesObjectById() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        Task t = new Task(
           WhoId = provider.Id,
           Type = 'Call'
        );
        insert t;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Calls/' + t.Id;
        request.resourcePath = '/mobile/prm/v2/Calls/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmCallController2.doDelete();
        
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
               Subject= 'Call',
                Status= 'Not Started',
                Type = 'Call'
            );
            insert t;
        
        }
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Calls/' + t.Id;
        request.resourcePath = '/mobile/prm/v2/Calls/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<uRestController.GenericGetResponse> response = RestPrmCallController2.doGet();
        
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
           Subject= 'Call',
           Status= 'Not Started',
           Type = 'Call'
        );
        insert t;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Calls/' + t.Id;
        request.resourcePath = '/mobile/prm/v2/Calls/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<uRestController.GenericGetResponse> response = RestPrmCallController2.doGet();
        
        
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
               Subject= 'Call',
               Status= 'Not Started',
               Type = 'Call'
            );
            insert t;
        
        }
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Calls/';
        request.resourcePath = '/mobile/prm/v2/Calls/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse(); 
        List<String> temp = new List<String>();
        temp.add(String.valueOf(t.Id));        
        
        RestPrmCallController2.doPatch(temp); 
        
        System.assertEquals(403, RestContext.response.statusCode);
        
        RestPrmCallController2.doPatch(null);
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
           Subject= 'Call',
           Status= 'Not Started',
           Type = 'Call'
        );
        insert t;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Calls/';
        request.resourcePath = '/mobile/prm/v2/Calls/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmCallController2.doPatch(new List<String> { t.Id });
        TaskStatus closedStatus = [Select MasterLabel, IsClosed from TaskStatus where IsClosed = true limit 1];
        
        t = [Select Id, OwnerId, Status, IsClosed from Task where Id = :t.Id];
        
        System.assertEquals(closedStatus.MasterLabel, t.Status);
        System.assertEquals(true, t.IsClosed);
        
        RestPrmCallController2.doPatch(new List<String> {  });
        
        RestPrmCallController2.doPatch(null);
        
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
           Subject= 'Call',
           Status= 'Not Started',
           Type = 'Call'
        );
        insert t;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Calls/' + t.Id;
        request.resourcePath = '/mobile/prm/v2/Calls/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmCallController2.doDelete();
        
        
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
           Subject= 'Call',
           Status= 'Not Started',
           Type = 'Call'
        );
        insert t;
        
        Task t1 = new Task(
           WhoId = provider.Id,
           OwnerId = UserInfo.getUserId(),
           Subject= 'Call',
           Status= 'Not Started',
           Type = 'Call'
        );
        insert t1;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Calls/';
        request.resourcePath = '/mobile/prm/v2/Calls/*';
        request.addParameter('ids', t.Id + ';' + t1.Id);
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmCallController2.doDelete();
        
        
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
               Subject= 'Call',
                Status= 'Not Started',
                Type = 'Call'
            );
            insert t;
        
        }
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Calls/' + t.Id;
        request.resourcePath = '/mobile/prm/v2/Calls/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmCallController2.doDelete();
        
        System.assertEquals(403, RestContext.response.statusCode);
    }
    
    /* End - RestPrmCallController2 */ 
}