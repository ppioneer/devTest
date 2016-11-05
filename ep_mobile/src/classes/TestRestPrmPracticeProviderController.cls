/* Copyright (c) 2008-2014 Evariant */
@isTest
private with sharing class TestRestPrmPracticeProviderController {
	static testMethod void doGet_RetrievesObjectById() {
        Account practice = new Account(
           Name = '__Test__'
        );
        insert practice;
        
        Contact provider = new Contact(
            FirstName = '__JOHN1__',
            LastName = '__DOE__'
        );
        
        Contact provider2 = new Contact(
            FirstName = '__JOHN2__',
            LastName = '__DOE__'
        );
        insert new List<Contact> {provider, provider2};
        
        HC4__ProviderPractice__c pp1 = new HC4__ProviderPractice__c (
            HC4__Provider__c = provider.Id,
            HC4__Practice__c = practice.Id
        );
        
        HC4__ProviderPractice__c pp2 = new HC4__ProviderPractice__c (
            HC4__Provider__c = provider2.Id,
            HC4__Practice__c = practice.Id,
            HC4__IsPrimary__c = true
        );
        insert new List<HC4__ProviderPractice__c> {pp1, pp2};
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Practices/' + practice.Id + '/Providers';
        request.resourcePath = '/mobile/prm/v1/Practices/*/Providers';
        request.addParameter('pageSize', '2');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmProviderController.Provider> providers = RestPrmPracticeProviderController.doGet();
        
        System.assertEquals(2, providers.size());
        System.assertEquals(provider.ID, providers[0].id);
        System.assertEquals(provider2.ID, providers[1].id);
        System.assertNotEquals(null, providers[1].primaryPractice);
    }

}