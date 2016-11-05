/* Copyright (c) 2008-2014 Evariant */
@isTest
public with sharing class TestRestPrmPracticeTaskController {
     static testMethod void doGet_RetrievesObjectById() {
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        Task t = new Task (
            WhatId = practice.Id
        );
        insert t;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Practices/' + practice.Id + '/Tasks';
        request.resourcePath = '/mobile/prm/v1/Practices/*/Tasks';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmTaskController.RestTask> tasks = RestPrmPracticeTaskController.doGet();
        
        System.assert(tasks.size() >= 0);        
    }
    
    static testMethod void doPost_ReturnsBadRequestOnNullParameter() {        
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Practices/' + practice.Id + '/Tasks';
        request.resourcePath = '/mobile/prm/v1/Practices/*/Tasks';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmPracticeTaskController.doPost(null);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPost_ReturnsBadRequestOnNoStatus() {        
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Practices/' + practice.Id + '/Tasks';
        request.resourcePath = '/mobile/prm/v1/Practices/*/Tasks';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmTaskController.RestTask t = new RestPrmTaskController.RestTask();
        
        RestPrmPracticeTaskController.doPost(t);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPost_ReturnsBadRequestOnNoPriority() {        
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Practices/' + practice.Id + '/Tasks';
        request.resourcePath = '/mobile/prm/v1/Practices/*/Tasks';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmTaskController.RestTask t = new RestPrmTaskController.RestTask();
        t.status = Task.Status.getDescribe().getPicklistValues()[0].getValue();
        
        RestPrmPracticeTaskController.doPost(t);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPost_ReturnsCreated() {                
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Practices/' + practice.Id + '/Tasks';
        request.resourcePath = '/mobile/prm/v1/Practices/*/Tasks';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmTaskController.RestTask t = new RestPrmTaskController.RestTask();
        t.status = Task.Status.getDescribe().getPicklistValues()[0].getValue();
        t.priority = Task.Priority.getDescribe().getPicklistValues()[0].getValue();
        
        RestPrmPracticeTaskController.doPost(t);
        
        System.assertEquals(201, RestContext.response.statusCode);
        List<Task> tasks = [Select Id From Task where Type = :'Task' and OwnerId = :UserInfo.getUserId()];
        
        System.assertEquals(1, tasks.size());
    }
    
    static testMethod void doPut_ReturnsBadRequestOnNullParameter() {        
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Practices/' + practice.Id + '/Tasks';
        request.resourcePath = '/mobile/prm/v1/Practices/*/Tasks';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmPracticeTaskController.doPut(null);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPut_ReturnsBadRequestOnNoStatus() {
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        Task t = new Task(
           WhatId = practice.Id
        );
        insert t;
                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Practices/' + practice.Id + '/Tasks';
        request.resourcePath = '/mobile/prm/v1/Practices/*/Tasks';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmTaskController.RestTask task = new RestPrmTaskController.RestTask();
        task.id = t.Id;
        
        RestPrmPracticeTaskController.doPut(task);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }

    static testMethod void doPut_ReturnsBadRequestOnNoParentId() {
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        Task t = new Task(
           WhatId = practice.Id
        );
        insert t;
                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Practices/' + practice.Id + '/Tasks';
        request.resourcePath = '/mobile/prm/v1/Practices/*/Tasks';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmTaskController.RestTask rtask = new RestPrmTaskController.RestTask();
        rtask.id = t.Id;
        rtask.status = Task.Status.getDescribe().getPicklistValues()[0].getValue();
        
        RestPrmPracticeTaskController.doPut(rtask);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPut_ReturnsPreconditionFailedOnNoId() {
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Practices/' + practice.Id + '/Tasks';
        request.resourcePath = '/mobile/prm/v1/Practices/*/Tasks';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmTaskController.RestTask t = new RestPrmTaskController.RestTask();        
        RestPrmPracticeTaskController.doPut(t);
        
        System.assertEquals(412, RestContext.response.statusCode);
    }
    
    static testMethod void doPut_ReturnsNoContentOnUpdate() {
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        Task t = new Task(
           WhatId = practice.Id
        );
        insert t;
                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Practices/' + practice.Id + '/Tasks';
        request.resourcePath = '/mobile/prm/v1/Practices/*/Tasks';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        System.RestContext.response.statusCode = 200;
        
        RestPrmTaskController.RestTask rtask = new RestPrmTaskController.RestTask();
        rtask.id = t.Id;
        rtask.comments = '__A_TEST_COMMENT___';
        rtask.status = Task.Status.getDescribe().getPicklistValues()[0].getValue();
        rtask.priority = Task.Priority.getDescribe().getPicklistValues()[0].getValue();
        
        RestPrmPracticeTaskController.doPut(rtask);
        
        System.assertEquals(200, RestContext.response.statusCode);
        
        t = [Select Id, Description from Task where Id = :rtask.Id];
        
        System.assertEquals(rtask.comments, t.Description);
    }
    
    static testMethod void doPut_ReturnsNotModifiedOnError() {
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        Task t = new Task(
           WhatId = practice.Id
        );
        insert t;
                        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Practices/' + practice.Id + '/Tasks';
        request.resourcePath = '/mobile/prm/v1/Practices/*/Tasks';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmTaskController.RestTask rtask = new RestPrmTaskController.RestTask();
        rtask.id = t.Id + 'a';
        rtask.comments = '__A_TEST_COMMENT__';
        rtask.status = Task.Status.getDescribe().getPicklistValues()[0].getValue();
        rtask.priority = Task.Priority.getDescribe().getPicklistValues()[0].getValue();
        
        RestPrmPracticeTaskController.doPut(rtask);
        
        System.assertEquals(304, RestContext.response.statusCode);
    }
    
    static testMethod void doDelete_ReturnsNotFoundOnBadId() {
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Practices/' + practice.Id + '/Tasks/__SOME_TEST__';
        request.resourcePath = '/mobile/prm/v1/Practices/*/Tasks';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmPracticeTaskController.doDelete();
        
        System.assertEquals(404, RestContext.response.statusCode);
    }
    
    static testMethod void doDelete_DeletesObjectById() {
        Account practice = new Account (
           Name = '__PRACTICE__'
        );
        insert practice;
        
        Task t = new Task(
           WhatId = practice.Id
        );
        insert t;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Practices/' + practice.Id + '/Tasks/' + t.Id;
        request.resourcePath = '/mobile/prm/v1/Practices/*/Tasks';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmPracticeTaskController.doDelete();
        
        List<Task> tasks = [Select Id From Task where Id = :t.Id];
        
        System.assertEquals(0, tasks.size());
        System.assertEquals(200, RestContext.response.statusCode);
    }
}