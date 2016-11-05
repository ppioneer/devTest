/* Copyright (c) 2008-2014 Evariant */
@isTest
private with sharing class TestRestPrmAreaOfExpertiseController {
    
    static testMethod void doGet_RetrievesObjectById() {
    	HC4__AreaOfExpertise__c aoe = new HC4__AreaOfExpertise__c(
    	   Name = '__TEST__',
    	   HC4__Code__c = '__TEST_CODE__'
    	);
    	
    	insert aoe;
    	
    	RestRequest request = new RestRequest();
    	request.requestURI = '/mobile/prm/v1/AreasOfExpertise/' + aoe.Id;
    	request.resourcePath = '/mobile/prm/v1/AreasOfExpertise/*';
    	request.addParameter('pageSize', '1');
    	System.RestContext.request = request;
    	System.RestContext.response = new RestResponse();
    	
    	List<RestPrmAreaOfExpertiseController.AreaOfExpertise> laoe = RestPrmAreaOfExpertiseController.doGet();
    	
    	System.assertEquals(1, laoe.size());
    	System.assertEquals(aoe.ID, laoe[0].id);
    }
    
    static testMethod void doGet_RetrievesAllObjects() {
    	HC4__AreaOfExpertise__c aoe = new HC4__AreaOfExpertise__c(
           Name = '__TEST__',
           HC4__Code__c = '__TEST_CODE__'
        );
        
        insert aoe;
        
        Integer i = [SELECT COUNT() from HC4__AreaOfExpertise__c];
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/AreasOfExpertise';
        request.resourcePath = '/mobile/prm/v1/AreasOfExpertise/*';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmAreaOfExpertiseController.AreaOfExpertise> laoe = RestPrmAreaOfExpertiseController.doGet();
        
        System.assert(laoe.size() <= i && laoe.size() <= uRestController.pageSize);
    }
    
    static testMethod void doGet_ReturnsNothingOnInvalidId() {        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/AreasOfExpertise/a02j00000020jpBAAQ';
        request.resourcePath = '/mobile/prm/v1/AreasOfExpertise/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmAreaOfExpertiseController.AreaOfExpertise> laoe = RestPrmAreaOfExpertiseController.doGet();
        
        System.assertEquals(0, laoe.size());
        System.assertEquals(404, RestContext.response.statusCode);
    }
}