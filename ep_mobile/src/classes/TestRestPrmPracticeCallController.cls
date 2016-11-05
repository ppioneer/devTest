/* Copyright (c) 2008-2014 Evariant */
@isTest
private with sharing class TestRestPrmPracticeCallController {
     static testMethod void doGet_RetrievesObjectById() {
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        Task t = new Task (
            WhatId = practice.Id,
            Type = 'Call',
            Subject = 'Call'
        );
        insert t;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Practices/' + practice.Id + '/Calls';
        request.resourcePath = '/mobile/prm/v1/Practices/*/Calls';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmCallController.Call> calls = RestPrmPracticeCallController.doGet();
        
        System.assertEquals(1, calls.size());
        System.assertEquals(t.ID, calls[0].id);
    }
    
    static testMethod void doPost_ReturnsBadRequestOnNullParameter() {        
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Practices/' + practice.Id + '/Calls';
        request.resourcePath = '/mobile/prm/v1/Practices/*/Calls';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmPracticeCallController.doPost(null);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPost_ReturnsCreated() {                
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Practices/' + practice.Id + '/Calls';
        request.resourcePath = '/mobile/prm/v1/Practices/*/Calls';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmCallController.Call c = new RestPrmCallController.Call();
        c.comments = '__TESTING__';
        
        RestPrmPracticeCallController.doPost(c);
        
        System.assertEquals(201, RestContext.response.statusCode);
        List<Task> tasks = [Select Id From Task where Type = :'Call' and OwnerId = :UserInfo.getUserId()];
        
        System.assertEquals(1, tasks.size());
    }
    
    static testMethod void doPut_ReturnsBadRequestOnNullParameter() {        
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Practices/' + practice.Id + '/Calls';
        request.resourcePath = '/mobile/prm/v1/Practices/*/Calls';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmPracticeCallController.doPut(null);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPut_ReturnsPreconditionFailedOnNoId() {
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Practices/' + practice.Id + '/Calls';
        request.resourcePath = '/mobile/prm/v1/Practices/*/Calls';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmCallController.Call call = new RestPrmCallController.Call();        
        RestPrmPracticeCallController.doPut(call);
        
        System.assertEquals(412, RestContext.response.statusCode);
    }
    
    static testMethod void doPut_ReturnsNoContentOnUpdate() {
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        Task t = new Task(
           WhatId = practice.Id,
           Type = 'Call'
        );
        insert t;
                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Practices/' + practice.Id + '/Calls';
        request.resourcePath = '/mobile/prm/v1/Practices/*/Calls';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        System.RestContext.response.statusCode = 200;
        
        RestPrmCallController.Call call = new RestPrmCallController.Call();
        call.id = t.Id;
        call.comments = '__A_TEST_COMMENT___';
        
        RestPrmPracticeCallController.doPut(call);
        
        System.assertEquals(200, RestContext.response.statusCode);
        
        t = [Select Id, Description from Task where Id = :call.Id];
        
        System.assertEquals(call.comments, t.Description);
    }
    
    static testMethod void doPut_ReturnsNotModifiedOnError() {
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        Task t = new Task(
           WhatId = practice.Id,
           Type = 'Call'
        );
        insert t;
                        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Practices/' + practice.Id + '/Calls';
        request.resourcePath = '/mobile/prm/v1/Practices/*/Calls';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmCallController.Call call = new RestPrmCallController.Call();
        call.id = t.Id + 'a';
        call.comments = '__A_TEST_COMMENT__';
        
        RestPrmPracticeCallController.doPut(call);
        
        System.assertEquals(304, RestContext.response.statusCode);
    }
    
    static testMethod void doDelete_ReturnsNotFoundOnBadId() {
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Practices/' + practice.Id + '/Calls/__SOME_TEST__';
        request.resourcePath = '/mobile/prm/v1/Practices/*/Calls';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmPracticeCallController.doDelete();
        
        System.assertEquals(404, RestContext.response.statusCode);
    }
    
    static testMethod void doDelete_DeletesObjectById() {
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        Task t = new Task(
           WhatId = practice.Id,
           Type = 'Call'
        );
        insert t;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Practices/' + practice.Id + '/Calls/' + t.Id;
        request.resourcePath = '/mobile/prm/v1/Practices/*/Calls';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmPracticeCallController.doDelete();
        
        List<Task> tasks = [Select Id From Task where Id = :t.Id];
        
        System.assertEquals(0, tasks.size());
        System.assertEquals(200, RestContext.response.statusCode);
    }
}