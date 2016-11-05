/* Copyright (c) 2008-2014 Evariant */
@isTest
private with sharing class TestRestPrmProviderLocationController {
    static testMethod void doGet_RetrievesObjectById() {
    	Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        HC4__Location__c location = new HC4__Location__c();
        insert location;
        
        HC4__ProviderLocation__c pLocation = new HC4__ProviderLocation__c(
            HC4__Provider__c = provider.Id,
            HC4__Location__c = location.Id,
            HC4__IsPrimary__c = true
        );
        insert pLocation;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers/' + provider.Id + '/Locations';
        request.resourcePath = '/mobile/prm/v1/Providers/*/Locations';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmLocationController.Location> locations = RestPrmProviderLocationController.doGet();
        
        System.assertEquals(1, locations.size());
        System.assertEquals(location.ID, locations[0].id);
        System.assertEquals(plocation.HC4__isPrimary__c, locations[0].isPrimary);
    }
}