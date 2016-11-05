/* Copyright (c) 2008-2014 Evariant */
@isTest
private with sharing class TestRestPrmProviderMyRecentController {
    static testMethod void doGet_RetrievesObjectById() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        List<Contact> providers = [Select Id From Contact where Id = :provider.Id For VIEW];
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers/myRecent';
        request.resourcePath = '/mobile/prm/v1/Providers/myRecent';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmProviderController.Provider> myProviders = RestPrmProviderMyRecentController.doGet();
        
        System.assertEquals(1, myProviders.size());
        System.assertEquals(provider.ID, myProviders[0].id);
    }
}