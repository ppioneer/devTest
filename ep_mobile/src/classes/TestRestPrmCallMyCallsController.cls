/* Copyright (c) 2008-2014 Evariant */
@isTest
private with sharing class TestRestPrmCallMyCallsController {
    static testMethod void doGet_RetrievesOpenTasksForCurrentUser() {
        Task t = new Task(
           Subject = '__TEST__',
           OwnerId = UserInfo.getUserId(),
           Status = 'Completed',
           Type = 'Call'
        );
        insert t;
        
        t = new Task(
           Subject = '__TEST__',
           OwnerId = UserInfo.getUserId(),
           Type = 'Call'
        );
        insert t;
        
        t = new Task(
           Subject = 'Call',
           OwnerId = UserInfo.getUserId(),
           Type = 'Call'
        );
        insert t;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Calls/myCalls';
        request.resourcePath = '/mobile/prm/v1/Calls/myCalls';
        request.addParameter('pageSize', '2');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmCallController.Call> calls = RestPrmCallMyCallsController.doGet();
        
        System.assert(1 <= calls.size());
    }
}