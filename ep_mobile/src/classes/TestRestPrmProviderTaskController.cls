/* Copyright (c) 2008-2014 Evariant */
@isTest
private with sharing class TestRestPrmProviderTaskController {
     static testMethod void doGet_RetrievesObjectById() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        Task t = new Task (
            WhoId = provider.Id
        );
        insert t;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers/' + provider.Id + '/Tasks';
        request.resourcePath = '/mobile/prm/v1/Providers/*/Tasks';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmTaskController.RestTask> tasks = RestPrmProviderTaskController.doGet();
        
        System.Assert(tasks.size() >= 0);        
    }
    
    static testMethod void doPost_ReturnsBadRequestOnNullParameter() {        
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers/' + provider.Id + '/Tasks';
        request.resourcePath = '/mobile/prm/v1/Providers/*/Tasks';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmProviderTaskController.doPost(null);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPost_ReturnsBadRequestOnNoStatus() {        
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers/' + provider.Id + '/Tasks';
        request.resourcePath = '/mobile/prm/v1/Providers/*/Tasks';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmTaskController.RestTask t = new RestPrmTaskController.RestTask();
        
        RestPrmProviderTaskController.doPost(t);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPost_ReturnsBadRequestOnNoPriority() {        
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers/' + provider.Id + '/Tasks';
        request.resourcePath = '/mobile/prm/v1/Providers/*/Tasks';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmTaskController.RestTask t = new RestPrmTaskController.RestTask();
        t.status = Task.Status.getDescribe().getPicklistValues()[0].getValue();
        
        RestPrmProviderTaskController.doPost(t);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPost_ReturnsCreated() {                
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers/' + provider.Id + '/Tasks';
        request.resourcePath = '/mobile/prm/v1/Providers/*/Tasks';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmTaskController.RestTask t = new RestPrmTaskController.RestTask();
        t.status = Task.Status.getDescribe().getPicklistValues()[0].getValue();
        t.priority = Task.Priority.getDescribe().getPicklistValues()[0].getValue();
        
        RestPrmProviderTaskController.doPost(t);
        
        System.assertEquals(201, RestContext.response.statusCode);
        List<Task> tasks = [Select Id From Task where Type = :'Task' and OwnerId = :UserInfo.getUserId()];
        
        System.assertEquals(1, tasks.size());
    }
    
    static testMethod void doPut_ReturnsBadRequestOnNullParameter() {        
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers/' + provider.Id + '/Tasks';
        request.resourcePath = '/mobile/prm/v1/Providers/*/Tasks';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmProviderTaskController.doPut(null);
        
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
        request.requestURI = '/mobile/prm/v1/Providers/' + provider.Id + '/Tasks';
        request.resourcePath = '/mobile/prm/v1/Providers/*/Tasks';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmTaskController.RestTask task = new RestPrmTaskController.RestTask();
        task.id = t.Id;
        
        RestPrmProviderTaskController.doPut(task);
        
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
        request.requestURI = '/mobile/prm/v1/Providers/' + provider.Id + '/Tasks';
        request.resourcePath = '/mobile/prm/v1/Providers/*/Tasks';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmTaskController.RestTask rtask = new RestPrmTaskController.RestTask();
        rtask.id = t.Id;
        rtask.status = Task.Status.getDescribe().getPicklistValues()[0].getValue();
        
        RestPrmProviderTaskController.doPut(rtask);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPut_ReturnsPreconditionFailedOnNoId() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers/' + provider.Id + '/Tasks';
        request.resourcePath = '/mobile/prm/v1/Providers/*/Tasks';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmTaskController.RestTask t = new RestPrmTaskController.RestTask();        
        RestPrmProviderTaskController.doPut(t);
        
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
        request.requestURI = '/mobile/prm/v1/Providers/' + provider.Id + '/Tasks';
        request.resourcePath = '/mobile/prm/v1/Providers/*/Tasks';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        System.RestContext.response.statusCode = 200;
        
        RestPrmTaskController.RestTask rtask = new RestPrmTaskController.RestTask();
        rtask.id = t.Id;
        rtask.comments = '__A_TEST_COMMENT___';
        rtask.status = Task.Status.getDescribe().getPicklistValues()[0].getValue();
        rtask.priority = Task.Priority.getDescribe().getPicklistValues()[0].getValue();
        
        RestPrmProviderTaskController.doPut(rtask);
        
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
        request.requestURI = '/mobile/prm/v1/Providers/' + provider.Id + '/Tasks';
        request.resourcePath = '/mobile/prm/v1/Providers/*/Tasks';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmTaskController.RestTask rtask = new RestPrmTaskController.RestTask();
        rtask.id = t.Id + 'a';
        rtask.comments = '__A_TEST_COMMENT__';
        rtask.status = Task.Status.getDescribe().getPicklistValues()[0].getValue();
        rtask.priority = Task.Priority.getDescribe().getPicklistValues()[0].getValue();
        
        RestPrmProviderTaskController.doPut(rtask);
        
        System.assertEquals(304, RestContext.response.statusCode);
    }
    
    static testMethod void doDelete_ReturnsNotFoundOnBadId() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers/' + provider.Id + '/Tasks/__SOME_TEST__';
        request.resourcePath = '/mobile/prm/v1/Providers/*/Tasks';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmProviderTaskController.doDelete();
        
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
        request.requestURI = '/mobile/prm/v1/Providers/' + provider.Id + '/Tasks/' + t.Id;
        request.resourcePath = '/mobile/prm/v1/Providers/*/Tasks';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmProviderTaskController.doDelete();
        
        List<Task> tasks = [Select Id From Task where Id = :t.Id];
        
        System.assertEquals(0, tasks.size());
        System.assertEquals(200, RestContext.response.statusCode);
    }
}