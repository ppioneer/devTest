/* Copyright (c) 2008-2014 Evariant */
@isTest
private with sharing class TestRestPrmPracticeAlertController {
    static testMethod void doGet_RetrievesPastDueTasksForProvider() {
        Account practice = new Account (
           Name = '__TEST__'
        );
        insert practice;
        
        Task t3 = new Task(
           Subject = '__TEST__',
           WhatId = practice.Id,
           OwnerId = UserInfo.getUserId(),
           Type = 'Task',
           ActivityDate = DateTime.now().addDays(-3).date()
        );
        insert t3;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Practices/' + practice.Id + '/Alerts';
        request.resourcePath = '/mobile/prm/v1/Practices/*/Alerts';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmAlertController.AlertFeed practiceFeed = RestPrmPracticeAlertController.doGet();
        
        System.assert( 0 == practiceFeed.openIssues.size());
        System.assert( 1 <= practiceFeed.overdueTasks.size());
    }
}