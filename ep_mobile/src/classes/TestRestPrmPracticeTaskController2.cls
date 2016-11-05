/* Copyright (c) 2008-2014 Evariant */
@isTest
private class TestRestPrmPracticeTaskController2 {
 	
 	static testMethod void doGet_RetrievesObjectById() {
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        Task t = new Task (
            WhatId = practice.Id,            
            Subject = '__CALL__',
            Status = 'Not Started' 
        );
        insert t;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Practices/' + practice.Id + '/Tasks';
        request.resourcePath = '/mobile/prm/v2/Practices/*/Tasks';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<uRestController.GenericGetListResponse> tasks = RestPrmPracticeTaskController2.doGet();
        
        System.assertEquals(1, tasks.size());
        System.assertEquals(t.ID, tasks[0].id);
    }
    
    static testMethod void doPost_ReturnsBadRequestOnNullParameter() {        
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Practices/' + practice.Id + '/Tasks';
        request.resourcePath = '/mobile/prm/v2/Practices/*/Tasks';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmPracticeTaskController2.doPost(null);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    static testMethod void doPost_ReturnsCreated() {                
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Practices/' + practice.Id + '/Tasks';
        request.resourcePath = '/mobile/prm/v2/Practices/*/Tasks';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        uRestController.GenericGetResponse t = new uRestController.GenericGetResponse();
        t.fieldsInfo.add(new uRestController.FieldsDescribe('Status', Task.Status.getDescribe().getPicklistValues()[0].getValue()));
		t.fieldsInfo.add(new uRestController.FieldsDescribe('Priority', Task.Priority.getDescribe().getPicklistValues()[0].getValue())); 
        
        RestPrmPracticeTaskController2.doPost(t);
        
        System.assertEquals(201, RestContext.response.statusCode);        
    }
    
    static testMethod void doPut_ReturnsBadRequestOnNullParameter() {        
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Practices/' + practice.Id + '/Tasks';
        request.resourcePath = '/mobile/prm/v2/Practices/*/Tasks';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmPracticeTaskController2.doPut(null);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    static testMethod void doPut_ReturnsPreconditionFailedOnNoId() {
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Practices/' + practice.Id + '/Tasks';
        request.resourcePath = '/mobile/prm/v2/Practices/*/Tasks';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        uRestController.GenericGetResponse t = new uRestController.GenericGetResponse();        
        RestPrmPracticeTaskController2.doPut(t);
        
        System.assertEquals(412, RestContext.response.statusCode);
    }
    
    static testMethod void doPut_ReturnsNoContentOnUpdate() {
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        Task t = new Task(
           WhatId = practice.Id,
           Subject = '__CALL__',
           Status = 'Not Started' 
        );
        insert t;
                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Practices/' + practice.Id + '/Tasks';
        request.resourcePath = '/mobile/prm/v2/Practices/*/Tasks';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        System.RestContext.response.statusCode = 200;
        
        uRestController.GenericGetResponse rtask = new uRestController.GenericGetResponse();
        rtask.id = t.Id;        
        rtask.fieldsInfo.add(new uRestController.FieldsDescribe('Description', '__A_TEST_COMMENT___'));
        rtask.fieldsInfo.add(new uRestController.FieldsDescribe('Status', Task.Status.getDescribe().getPicklistValues()[0].getValue()));
		rtask.fieldsInfo.add(new uRestController.FieldsDescribe('Priority', Task.Priority.getDescribe().getPicklistValues()[0].getValue())); 
        
        RestPrmPracticeTaskController2.doPut(rtask);
        
        System.assertEquals(200, RestContext.response.statusCode);
        
        t = [Select Id, Description from Task where Id = :rtask.Id];
        
        System.assertEquals(rtask.fieldsInfo[0].value, t.Description);
    }
    
    static testMethod void doPut_ReturnsNotModifiedOnError() {
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        Task t = new Task(
           WhatId = practice.Id,
           Subject = '__CALL__',
           Status = 'Not Started' 
        );
        insert t;
                        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Practices/' + practice.Id + '/Tasks';
        request.resourcePath = '/mobile/prm/v2/Practices/*/Tasks';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        uRestController.GenericGetResponse rtask = new uRestController.GenericGetResponse();
        rtask.id = t.Id + 'a';
        rtask.fieldsInfo.add(new uRestController.FieldsDescribe('Description', '__A_TEST_COMMENT___'));
        rtask.fieldsInfo.add(new uRestController.FieldsDescribe('Status', Task.Status.getDescribe().getPicklistValues()[0].getValue()));
		rtask.fieldsInfo.add(new uRestController.FieldsDescribe('Priority', Task.Priority.getDescribe().getPicklistValues()[0].getValue()));
        
        RestPrmPracticeTaskController2.doPut(rtask);
        
        System.assertEquals(404, RestContext.response.statusCode);
    }
    
    static testMethod void doDelete_ReturnsNotFoundOnBadId() {
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Practices/' + practice.Id + '/Tasks/__SOME_TEST__';
        request.resourcePath = '/mobile/prm/v2/Practices/*/Tasks';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmPracticeTaskController2.doDelete();
        
        System.assertEquals(404, RestContext.response.statusCode);
    }
    
    static testMethod void doDelete_DeletesObjectById() {
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        Task t = new Task(
           WhatId = practice.Id,
           Subject = '__CALL__',
           Status = 'Not Started' 
        );
        insert t;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Practices/' + practice.Id + '/Tasks/' + t.Id;
        request.resourcePath = '/mobile/prm/v2/Practices/*/Tasks';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmPracticeTaskController2.doDelete();
        
        List<Task> tasks = [Select Id From Task where Id = :t.Id];
        
        System.assertEquals(0, tasks.size());
        System.assertEquals(200, RestContext.response.statusCode);
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
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        
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
        request.requestURI = '/mobile/prm/v2/Practices/' +  practice.Id + '/Tasks';
        request.resourcePath = '/mobile/prm/v2/Practices/Tasks';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse(); 
        List<String> temp = new List<String>();
        temp.add(String.valueOf(t.Id));        
        
        RestPrmCallController2.doPatch(temp); 
        
        System.assertEquals(403, RestContext.response.statusCode);
        
        RestPrmCallController2.doPatch(null);
    }
    
    static testMethod void doPatch_ClosesTasks() {        
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        Task t = new Task(
           WhatId = practice.Id,
           Subject = '__CALL__',
           Status = 'Not Started' 
        );
        insert t;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Practices/' + practice.Id + '/Tasks/' + t.Id;
        request.resourcePath = '/mobile/prm/v2/Providers/*/Tasks';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmPracticeTaskController2.doPatch(new List<String> { t.Id });
        TaskStatus closedStatus = [Select MasterLabel, IsClosed from TaskStatus where IsClosed = true limit 1];
        
        t = [Select Id, OwnerId, Status, IsClosed from Task where Id = :t.Id];
        
        System.assertEquals(closedStatus.MasterLabel, t.Status);
        System.assertEquals(true, t.IsClosed);
        
        RestPrmPracticeTaskController2.doPatch(new List<String> {  });
        
        RestPrmPracticeTaskController2.doPatch(null);
        
        uRestController.GenericGetResponse rt = new uRestController.GenericGetResponse();
        rt.id = t.id;
        rt.fieldsInfo.add(new uRestController.FieldsDescribe('Status', Task.Status.getDescribe().getPicklistValues()[0].getValue()));
        rt.fieldsInfo.add(new uRestController.FieldsDescribe('Priority', Task.Priority.getDescribe().getPicklistValues()[0].getValue()));  
        rt.fieldsInfo.add(new uRestController.FieldsDescribe('Subject', 'Email'));
        rt.fieldsInfo.add(new uRestController.FieldsDescribe('Type', 'Task'));
        rt.fieldsInfo.add(new uRestController.FieldsDescribe('Description', '_Comments__'));
        rt.fieldsInfo.add(new uRestController.FieldsDescribe('WhatId', practice.Id));
        
        RestRequest requestWhatId = new RestRequest();
        requestWhatId.requestURI = '/mobile/prm/v2/Practices/' + practice.Id + '/Tasks/';
        requestWhatId.resourcePath = '/mobile/prm/v2/Practices/*/Tasks';
        System.RestContext.request = requestWhatId;
        System.RestContext.response = new RestResponse();
        
        RestPrmPracticeTaskController2.doPatch(new List<String> { t.Id });
        
    }
    
}