/* Copyright (c) 2008-2014 Evariant */
@isTest
private with sharing class TestRestPrmLocationController {
    static testMethod void doGet_RetrievesObjectById() {
        HC4__Location__c l = new HC4__Location__c();
        insert l;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Locations/' + l.Id;
        request.resourcePath = '/mobile/prm/v1/Locations/*';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmLocationController.Location> locations = RestPrmLocationController.doGet();
        
        System.assertEquals(1, locations.size());
        System.assertEquals(l.ID, locations[0].id);
    }
    
    static testMethod void doGet_ReturnsNothingOnInvalidId() {        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Locations/__TEST__';
        request.resourcePath = '/mobile/prm/v1/Locations/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmLocationController.Location> locations = RestPrmLocationController.doGet();
        
        System.assertEquals(0, locations.size());
        System.assertEquals(404, RestContext.response.statusCode);
    }
}