/* Copyright (c) 2008-2014 Evariant */
@isTest
private with sharing class TestRestPrmProviderAOEController {
    static testMethod void doGet_RetrievesObjectById() {
    	
    	Contact provider = new Contact(
    	   FirstName = '__JOHN__',
    	   LastName = ' __DOE__'
    	);
    	
    	insert provider;
    	
        HC4__AreaOfExpertise__c aoe = new HC4__AreaOfExpertise__c(
           Name = '__TEST__',
           HC4__Code__c = '__TEST_CODE__'
        );
        
        insert aoe;
        
        HC4__ProviderAreaOfExpertise__c paoe = new HC4__ProviderAreaOfExpertise__c(
            HC4__IsPrimary__c = true,
            HC4__AreaOfExpertise__c = aoe.Id,
            HC4__Provider__c = provider.Id
        );
        
        insert paoe;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers/' + provider.Id +'/AreasOfExpertise';
        request.resourcePath = '/mobile/prm/v1/Providers/*/AreasOfExpertise';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmAreaOfExpertiseController.AreaOfExpertise> laoe = RestPrmProviderAreaOfExpertiseController.doGet();
        
        System.assertEquals(1, laoe.size());
        System.assertEquals(aoe.ID, laoe[0].id);
        System.assertEquals(paoe.HC4__IsPrimary__c, laoe[0].isPrimary);
    }
}