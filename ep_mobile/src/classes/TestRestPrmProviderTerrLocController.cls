/* Copyright (c) 2008-2014 Evariant */
@isTest
private with sharing class TestRestPrmProviderTerrLocController {
    static testMethod void doGet_RetrievesObjectById() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        HC4__Location__c location = new HC4__Location__c();
        insert location;
        
        HC4__ProviderLocation__c pl = new HC4__ProviderLocation__c(
            HC4__Location__c = location.Id,
            HC4__Provider__c = provider.Id
        );
        insert pl;
        
        HC4__Territory__c territory = new HC4__Territory__c(
            Name = '__TEST__'
        );
        insert territory;
        
        HC4__ProviderLocationTerritory__c plt = new HC4__ProviderLocationTerritory__c(
            HC4__ProviderLocation__c = pl.Id,
            HC4__Territory__c = territory.Id
        );
        insert plt;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers/' + provider.Id + '/Territories/' + territory.Id + '/Locations';
        request.resourcePath = '/mobile/prm/v1/Providers/*/Territories/*/Locations';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmLocationController.Location> locations = RestPrmProviderTerrLocController.doGet();
        
        System.assertEquals(1, locations.size());
        System.assertEquals(location.ID, locations[0].id);
    }
}