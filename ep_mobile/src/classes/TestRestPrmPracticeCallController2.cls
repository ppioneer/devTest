@isTest
private class TestRestPrmPracticeCallController2 {
	
	static testMethod void doGet_RetrievesObjectById() {
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        Task t = new Task (
            WhatId = practice.Id,            
            Subject = 'Call',
            Status = 'Not Started' 
        );
        insert t;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Practices/' + practice.Id + '/Calls';
        request.resourcePath = '/mobile/prm/v2/Practices/*/Calls';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<uRestController.GenericGetListResponse> tasks = RestPrmPracticeCallController2.doGet();
        
        System.assertEquals(1, tasks.size());
        System.assertEquals(t.ID, tasks[0].id);
    }
    
    static testMethod void doPost_ReturnsBadRequestOnNullParameter() {        
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Practices/' + practice.Id + '/Calls';
        request.resourcePath = '/mobile/prm/v2/Practices/*/Calls';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmPracticeCallController2.doPost(null);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    static testMethod void doPost_ReturnsCreated() {                
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Practices/' + practice.Id + '/Calls';
        request.resourcePath = '/mobile/prm/v2/Practices/*/Calls';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        uRestController.GenericGetResponse t = new uRestController.GenericGetResponse();
        t.fieldsInfo.add(new uRestController.FieldsDescribe('Status', Task.Status.getDescribe().getPicklistValues()[0].getValue()));
		t.fieldsInfo.add(new uRestController.FieldsDescribe('Priority', Task.Priority.getDescribe().getPicklistValues()[0].getValue())); 
        
        RestPrmPracticeCallController2.doPost(t);
        
        System.assertEquals(201, RestContext.response.statusCode);        
    }
    
    static testMethod void doPut_ReturnsBadRequestOnNullParameter() {        
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Practices/' + practice.Id + '/Calls';
        request.resourcePath = '/mobile/prm/v2/Practices/*/Calls';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmPracticeCallController2.doPut(null);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    static testMethod void doPut_ReturnsPreconditionFailedOnNoId() {
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Practices/' + practice.Id + '/Calls';
        request.resourcePath = '/mobile/prm/v2/Practices/*/Calls';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        uRestController.GenericGetResponse t = new uRestController.GenericGetResponse();        
        RestPrmPracticeCallController2.doPut(t);
        
        System.assertEquals(412, RestContext.response.statusCode);
    }
    
    static testMethod void doPut_ReturnsNoContentOnUpdate() {
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        Task t = new Task(
           WhatId = practice.Id,
           Subject = 'Call',
           Status = 'Not Started' 
        );
        insert t;
                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Practices/' + practice.Id + '/Calls';
        request.resourcePath = '/mobile/prm/v2/Practices/*/Calls';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        System.RestContext.response.statusCode = 200;
        
        uRestController.GenericGetResponse rtask = new uRestController.GenericGetResponse();
        rtask.id = t.Id;        
        rtask.fieldsInfo.add(new uRestController.FieldsDescribe('Description', '__A_TEST_COMMENT___'));
        rtask.fieldsInfo.add(new uRestController.FieldsDescribe('Status', Task.Status.getDescribe().getPicklistValues()[0].getValue()));
		rtask.fieldsInfo.add(new uRestController.FieldsDescribe('Priority', Task.Priority.getDescribe().getPicklistValues()[0].getValue())); 
        
        RestPrmPracticeCallController2.doPut(rtask);
        
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
           Subject = 'Call',
           Status = 'Not Started' 
        );
        insert t;
                        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Practices/' + practice.Id + '/Calls';
        request.resourcePath = '/mobile/prm/v2/Practices/*/Calls';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        uRestController.GenericGetResponse rtask = new uRestController.GenericGetResponse();
        rtask.id = t.Id + 'a';
        rtask.fieldsInfo.add(new uRestController.FieldsDescribe('Description', '__A_TEST_COMMENT___'));
        rtask.fieldsInfo.add(new uRestController.FieldsDescribe('Status', Task.Status.getDescribe().getPicklistValues()[0].getValue()));
		rtask.fieldsInfo.add(new uRestController.FieldsDescribe('Priority', Task.Priority.getDescribe().getPicklistValues()[0].getValue()));
        
        RestPrmPracticeCallController2.doPut(rtask);
        
        System.assertEquals(404, RestContext.response.statusCode);
    }
    
    static testMethod void doDelete_ReturnsNotFoundOnBadId() {
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Practices/' + practice.Id + '/Calls/__SOME_TEST__';
        request.resourcePath = '/mobile/prm/v2/Practices/*/Calls';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmPracticeCallController2.doDelete();
        
        System.assertEquals(404, RestContext.response.statusCode);
    }
    
    static testMethod void doDelete_DeletesObjectById() {
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        Task t = new Task(
           WhatId = practice.Id,
           Subject = 'Call',
           Status = 'Not Started' 
        );
        insert t;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Practices/' + practice.Id + '/Calls/' + t.Id;
        request.resourcePath = '/mobile/prm/v2/Practices/*/Calls';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmPracticeCallController2.doDelete();
        
        List<Task> tasks = [Select Id From Task where Id = :t.Id];
        
        System.assertEquals(0, tasks.size());
        System.assertEquals(200, RestContext.response.statusCode);
    }
    
    static testMethod void doPatch_ReturnsOk() {
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        Task t = new Task(
           WhatId = practice.Id,
           Subject = 'Call',
           Status = 'Not Started',
           Type = 'Call'           
        );
        
        insert t;
        
         Task t1 = new Task(
           WhatId = practice.Id,
           Subject = '__CALL__',
           Status = 'Not Started'           
        );
        
        insert t1;
                        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Practices/' + practice.Id + '/Tasks';
        request.resourcePath = '/mobile/prm/v2/Practices/*/Tasks';
        request.addParameter('Practices', practice.Id);
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        uRestController.GenericGetResponse rt = new uRestController.GenericGetResponse();
        rt.id = t.Id;
        List<String> lst = new List<String>();
        lst.add(t.Id);
        lst.add(t1.Id);        
        RestPrmPracticeCallController2.doPatch(lst);
        
        System.assertEquals(null, RestContext.response.statusCode);
        
        RestPrmPracticeCallController2.doPatch(null);
    }
        
}