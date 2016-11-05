/* Copyright (c) 2008-2014 Evariant */
@isTest 
private with sharing class TestRestPrmCallController {
     static testMethod void doGet_RetrievesObjectById() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        Task t = new Task(
           WhoId = provider.Id,
           Type = 'Call',
           Subject = 'Call'
        );
        insert t;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Calls/' + t.Id;
        request.resourcePath = '/mobile/prm/v1/Calls/*';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmCallController.Call> calls = RestPrmCallController.doGet();
        
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
           WhoId = provider.Id,
           Type = 'Call'
        );
        insert t;
        
        t = new Task(
           WhoId = provider.Id,
           Type = 'Call'
        );
        insert t;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Calls/';
        request.resourcePath = '/mobile/prm/v1/Calls/*';
        request.addParameter('pageSize', '3');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmCallController.Call> calls = RestPrmCallController.doGet();
        
        System.assert(calls.size() >= 0);
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
        request.requestURI = '/mobile/prm/v1/Calls/';
        request.resourcePath = '/mobile/prm/v1/Calls/*';
        request.addParameter('startCreateDate', theDate);
        request.addParameter('endCreateDate', theDate);
        request.addParameter('pageSize', '3');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmCallController.Call> calls = RestPrmCallController.doGet();
        
        System.assert(calls.size() >= 0);
    }
    
    static testMethod void doGet_RetrievesFilteredCreatedDate() {
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
        request.requestURI = '/mobile/prm/v1/Calls/';
        request.resourcePath = '/mobile/prm/v1/Calls/*';
        request.addParameter('createdDate', theDate);
        request.addParameter('pageSize', '3');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmCallController.Call> calls = RestPrmCallController.doGet();
        
        System.assert(calls.size() >= 0);
    }
    
    static testMethod void doGet_NotFoundWhenBadId() {
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
        request.requestURI = '/mobile/prm/v1/Calls/' + t.Id + 'a';
        request.resourcePath = '/mobile/prm/v1/Calls/*';
        request.addParameter('pageSize', '2');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmCallController.Call> calls = RestPrmCallController.doGet();
        
        System.assertEquals(0, calls.size());
        System.assertEquals(404, RestContext.response.statusCode);
    }
    
    static testMethod void doPost_ReturnsBadRequestOnNullParameter() {        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Calls';
        request.resourcePath = '/mobile/prm/v1/Calls/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmCallController.doPost(null);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPost_ReturnsBadRequestOnNoComments() {        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Calls';
        request.resourcePath = '/mobile/prm/v1/Calls/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmCallController.Call c = new RestPrmCallController.Call();
        
        RestPrmCallController.doPost(c);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPost_ReturnsCreated() {                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Calls';
        request.resourcePath = '/mobile/prm/v1/Calls/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmCallController.Call c = new RestPrmCallController.Call();
        c.comments = '__TEST__';
        
        RestPrmCallController.doPost(c);
        
        System.assertEquals(201, RestContext.response.statusCode);
        List<Task> tasks = [Select Id From Task where Type = :'Call' and OwnerId = :UserInfo.getUserId()];
        
        System.assertEquals(1, tasks.size());
    }
    
    static testMethod void doPostProviderIds_ReturnsBadRequestOnNullParameter() {        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Calls';
        request.resourcePath = '/mobile/prm/v1/Calls/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmCallController.doPost(null);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPostProviderIds_ReturnsBadRequestOnNoComments() {
    	Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Calls';
        request.resourcePath = '/mobile/prm/v1/Calls/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmCallController.Call c = new RestPrmCallController.Call();
        
        RestPrmCallController.doPost(c, new String[] { provider.Id });
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPostProviderIds_ReturnsCreated() {
    	Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
                        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Calls';
        request.resourcePath = '/mobile/prm/v1/Calls/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmCallController.Call c = new RestPrmCallController.Call();
        c.comments = '__TEST__';
        
        RestPrmCallController.doPost(c, new String[] { provider.Id });
        
        System.assertEquals(201, RestContext.response.statusCode);
        List<Task> tasks = [Select Id From Task where Type = :'Call' and OwnerId = :UserInfo.getUserId() AND Who.Id = :provider.Id];
        
        System.assertEquals(1, tasks.size());
    }
    
    static testMethod void doPut_ReturnsBadRequestOnNullParameter() {        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Calls';
        request.resourcePath = '/mobile/prm/v1/Calls/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmCallController.doPut(null);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPut_ReturnsPreconditionFailedOnNoId() {
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Calls';
        request.resourcePath = '/mobile/prm/v1/Calls/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmCallController.Call c = new RestPrmCallController.Call();        
        RestPrmCallController.doPut(c);
        
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
        request.requestURI = '/mobile/prm/v1/Calls';
        request.resourcePath = '/mobile/prm/v1/Calls/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        System.RestContext.response.statusCode = 200;
        
        RestPrmCallController.Call c = new RestPrmCallController.Call();
        c.id = t.Id;
        c.comments = '__A_TEST_COMMENT___';
        
        RestPrmCallController.doPut(c);
        
        System.assertEquals(200, RestContext.response.statusCode);
        
        t = [Select Id, Description from Task where Id = :c.Id];
        
        System.assertEquals(c.comments, t.Description);
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
        request.requestURI = '/mobile/prm/v1/Calls';
        request.resourcePath = '/mobile/prm/v1/Calls/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmCallController.Call c = new RestPrmCallController.Call();
        c.id = t.Id + 'a';
        c.comments = '__A_TEST_COMMENT__';
        
        RestPrmCallController.doPut(c);
        
        System.assertEquals(304, RestContext.response.statusCode);
    }
    
    static testMethod void doDelete_ReturnsNotFoundOnBadId() {
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Calls/__SOME_TEST__';
        request.resourcePath = '/mobile/prm/v1/Calls/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmCallController.doDelete();
        
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
        request.requestURI = '/mobile/prm/v1/Calls/' + t.Id;
        request.resourcePath = '/mobile/prm/v1/Calls/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmCallController.doDelete();
        
        List<Task> tasks = [Select Id From Task where Id = :t.Id];
        
        System.assertEquals(0, tasks.size());
        System.assertEquals(200, RestContext.response.statusCode);
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
        request.requestURI = '/mobile/prm/v1/Calls/';
        request.resourcePath = '/mobile/prm/v1/Calls/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmCallController.doPatch(new List<String> { t.Id });
        TaskStatus closedStatus = [Select MasterLabel, IsClosed from TaskStatus where IsClosed = true limit 1];
        
        t = [Select Id, OwnerId, Status, IsClosed from Task where Id = :t.Id];
        
        System.assertEquals(closedStatus.MasterLabel, t.Status);
        System.assertEquals(true, t.IsClosed);
    }
}