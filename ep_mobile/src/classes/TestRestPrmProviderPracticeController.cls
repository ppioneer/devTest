/* Copyright (c) 2008-2014 Evariant */
@isTest
private with sharing class TestRestPrmProviderPracticeController {
    static testMethod void doGet_RetrievesObjectById() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        Account a = new Account(
            Name = '__Test__'
        );
        insert a;
        
        HC4__ProviderPractice__c pp = new HC4__ProviderPractice__c(
            HC4__Provider__c = provider.Id,
            HC4__Practice__c = a.Id,
            HC4__IsPrimary__c = true
        );
        insert pp;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers/' + provider.Id + '/Practices';
        request.resourcePath = '/mobile/prm/v1/Providers/*/Practices';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmPracticeController.Practice> practices = RestPrmProviderPracticeController.doGet();
        
        System.assertEquals(1, practices.size());
        System.assertEquals(a.ID, practices[0].id);
    }
}