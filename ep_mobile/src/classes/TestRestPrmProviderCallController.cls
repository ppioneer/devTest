/* Copyright (c) 2008-2014 Evariant */
@isTest
private with sharing class TestRestPrmProviderCallController {
     static testMethod void doGet_RetrievesObjectById() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        Task t = new Task (
            WhoId = provider.Id,
            Type = 'Call',
            Subject = 'Call'
        );
        insert t;
        
        Task t1 = new Task (
            WhoId = provider.Id,
            Type = 'Call',
            Subject = 'Call'
        );
        insert t1;
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers/' + provider.Id + '/Calls';
        request.resourcePath = '/mobile/prm/v1/Providers/*/Calls';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmCallController.Call> calls = RestPrmProviderCallController.doGet();        
        System.assertEquals(1, calls.size()); 
        System.assertEquals(t.ID, calls[0].id);
    }
    
    static testMethod void doPost_ReturnsBadRequestOnNullParameter() {        
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers/' + provider.Id + '/Calls';
        request.resourcePath = '/mobile/prm/v1/Providers/*/Calls';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmProviderCallController.doPost(null);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPost_ReturnsCreated() {                
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers/' + provider.Id + '/Calls';
        request.resourcePath = '/mobile/prm/v1/Providers/*/Calls';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmCallController.Call c = new RestPrmCallController.Call();
        c.comments = '__TEST__';
        
        RestPrmProviderCallController.doPost(c);
        
        System.assertEquals(201, RestContext.response.statusCode);
        List<Task> tasks = [Select Id From Task where Type = :'Call' and OwnerId = :UserInfo.getUserId()];
        
        System.assertEquals(1, tasks.size());
    }
    
    static testMethod void doPut_ReturnsBadRequestOnNullParameter() {        
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers/' + provider.Id + '/Calls';
        request.resourcePath = '/mobile/prm/v1/Providers/*/Calls';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmProviderCallController.doPut(null);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPut_ReturnsPreconditionFailedOnNoId() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers/' + provider.Id + '/Calls';
        request.resourcePath = '/mobile/prm/v1/Providers/*/Calls';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmCallController.Call c = new RestPrmCallController.Call();        
        RestPrmProviderCallController.doPut(c);
        
        System.assertEquals(412, RestContext.response.statusCode);
    }
    
    static testMethod void doPut_ReturnsNoContentOnUpdate() {
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
        request.requestURI = '/mobile/prm/v1/Providers/' + provider.Id + '/Calls';
        request.resourcePath = '/mobile/prm/v1/Providers/*/Calls';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmCallController.Call call = new RestPrmCallController.Call();
        call.id = t.Id;
        call.comments = '__A_TEST_COMMENT___';
        
        RestPrmProviderCallController.doPut(call);
        
        System.assertEquals(200, RestContext.response.statusCode);
        
        t = [Select Id, Description from Task where Id = :call.Id];
        
        System.assertEquals(call.comments, t.Description);
        System.assertEquals(200, RestContext.response.statusCode);
    }
    
    static testMethod void doPut_ReturnsNotModifiedOnError() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        Task t = new Task(
           WhoId = provider.Id,
           Type ='Call'
        );
        insert t;
                        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers/' + provider.Id + '/Calls';
        request.resourcePath = '/mobile/prm/v1/Providers/*/Calls';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmCallController.Call call = new RestPrmCallController.Call();
        call.id = t.Id + 'a';
        call.comments = '__A_TEST_COMMENT__';
        
        RestPrmProviderCallController.doPut(call);
        
        System.assertEquals(304, RestContext.response.statusCode);
    }
    
    static testMethod void doDelete_ReturnsNotFoundOnBadId() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers/' + provider.Id + '/Calls/__SOME_TEST__';
        request.resourcePath = '/mobile/prm/v1/Providers/*/Calls';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmProviderCallController.doDelete();
        
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
        request.requestURI = '/mobile/prm/v1/Providers/' + provider.Id + '/Calls/' + t.Id;
        request.resourcePath = '/mobile/prm/v1/Providers/*/Calls';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmProviderCallController.doDelete();
        
        List<Task> tasks = [Select Id From Task where Id = :t.Id];
        
        System.assertEquals(0, tasks.size());
        System.assertEquals(200, RestContext.response.statusCode);
    }
}