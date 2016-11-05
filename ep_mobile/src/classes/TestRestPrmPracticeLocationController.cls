/* Copyright (c) 2008-2014 Evariant */
@isTest
private with sharing class TestRestPrmPracticeLocationController {
    static testMethod void doGet_RetrievesObjectById() {
        Account practice = new Account (
           Name = '__TEST_PRACTICE__'
        );
        insert practice;
        
        HC4__Location__c location = new HC4__Location__c(
            HC4__Practice__c = practice.Id
        );
        insert location;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Practices/' + practice.Id + '/Locations';
        request.resourcePath = '/mobile/prm/v1/Practices/*/Locations';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmLocationController.Location> locations = RestPrmPracticeLocationController.doGet();
        
        System.assertEquals(1, locations.size());
        System.assertEquals(location.ID, locations[0].id);
    }
}