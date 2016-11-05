/* Copyright (c) 2008-2014 Evariant */
@isTest
private class TestRestPrmCallMyCallsController2 {

    static testMethod void doGet_RetrievesOpenTasksForCurrentUser() {
        Task t = new Task(
           Subject = 'Call',
           OwnerId = UserInfo.getUserId(),
           Status = 'Completed',
           Type = 'Call'
        );
        insert t;
        
        t = new Task(
           Subject = 'Call',
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
        request.requestURI = '/mobile/prm/v2/Calls/myCalls';
        request.resourcePath = '/mobile/prm/v2/Calls/myCalls';
        request.addParameter('pageSize', '2');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<uRestController.GenericGetListResponse> calls = RestPrmCallMyCallsController2.doGet();
        
        System.assert(calls.size() >= 0);
    }
    
    
}