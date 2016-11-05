/* Copyright (c) 2008-2014 Evariant */
@isTest
private with sharing class TestRestPrmPracticeMyRecentController {
    /*static testMethod void doGet_RetrievesObjectById() {
        Account practice = new Account (
           Name = '__TEST__'
        );
        insert practice;
        
        List<Account> practices = [Select Id From Account where Id = :practice.Id For VIEW];
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Practices/myRecent';
        request.resourcePath = '/mobile/prm/v1/Practices/myRecent';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmPracticeController.Practice> myPractices = RestPrmPracticeMyRecentController.doGet();
        
        System.assertEquals(1, myPractices.size());
        System.assertEquals(practice.ID, myPractices[0].id);
    }*/
}