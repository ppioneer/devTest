/* Copyright (c) 2008-2014 Evariant */
@isTest
private with sharing class TestRestPrmTaskMyTaskController {
    static testMethod void doGet_RetrievesOpenTasksForCurrentUser() {
        Task t = new Task(
           Subject = '__TEST__',
           OwnerId = UserInfo.getUserId(),
           Status = 'Completed',
           Type = 'Task'
        );
        insert t;
        
        t = new Task(
           Subject = '__TEST__',
           OwnerId = UserInfo.getUserId(),
           Type = 'Task'
        );
        insert t;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Tasks/myTasks';
        request.resourcePath = '/mobile/prm/v1/Tasks/myTasks';
        request.addParameter('pageSize', '2');
        System.RestContext.request = request;
        
        List<RestPrmTaskController.RestTask> tasks = RestPrmTaskMyTasksController.doGet();
        
        System.assert(1 <= tasks.size());
        for(RestPrmTaskController.RestTask i : tasks) {
        	System.assert(!i.isClosed);
        }
    }
}