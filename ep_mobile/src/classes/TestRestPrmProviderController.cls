/* Copyright (c) 2008-2014 Evariant */
@isTest
private with sharing class TestRestPrmProviderController {
    static testMethod void doGet_RetrievesObjectById() {
         Contact provider = new Contact(
           FirstName = '__JOHN__',
           Lastname = '__DOE__'
        );
        insert provider;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers/' + provider.Id;
        request.resourcePath = '/mobile/prm/v1/Providers/*';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        
        List<RestPrmProviderController.Provider> providers = RestPrmProviderController.doGet();
        
        System.assertEquals(1, providers.size());
        System.assertEquals(provider.ID, providers[0].id);
        System.assertEquals(provider.FirstName, providers[0].firstName);
        System.assertEquals(provider.LastName, providers[0].lastName);
    }
    
    static testMethod void doGet_ReturnsNotFoundWhenBadId() {        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers/' + '__BAD_ID__';
        request.resourcePath = '/mobile/prm/v1/Providers/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmProviderController.Provider> providers = RestPrmProviderController.doGet();
        
        System.assertEquals(0, providers.size());
        System.assertEquals(404, System.RestContext.response.statusCode);
    }
    
    static testMethod void doGet_ReturnsAllWhenNoId() {
    	Contact provider = new Contact(
           FirstName = '__JOHN__',
           Lastname = '__DOE__'
        );
        insert provider;
        
        provider = new Contact(
           FirstName = '__JOHN__',
           Lastname = '__DOE__'
        );
        insert provider;
                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers';
        request.resourcePath = '/mobile/prm/v1/Providers/*';
        request.addParameter('pageSize', '3');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmProviderController.Provider> providers = RestPrmProviderController.doGet();
        
        System.assert(2 <= providers.size());
    }
    
    static testMethod void doGet_RetrievesMatchingProvidersOnNameWithQValue() {
        Contact provider = new Contact(
           FirstName = '__JOHN__',
           Lastname = '__DOE__'
        );
        insert provider;
        
        provider = new Contact(
           FirstName = '__JOHN2__',
           Lastname = '__DOE__'
        );
        insert provider;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers';
        request.params.put('q', '__JOHN2__');
        request.resourcePath = '/mobile/prm/v1/Providers/*';
        request.addParameter('pageSize', '2');
        System.RestContext.request = request;
        
        List<RestPrmProviderController.Provider> providers = RestPrmProviderController.doGet();
        
        System.assertEquals(1, providers.size());
        System.assertEquals(provider.ID, providers[0].id);
    }
    
    static testMethod void doGet_RetrievesMatchingProvidersWithSpecialtiesValue() {
        Contact provider = new Contact(
           FirstName = '__JOHN__',
           Lastname = '__DOE__'
        );
        insert provider;
        
        HC4__Specialty__c s = new HC4__Specialty__c(
            Name = ' __TEST _SPECIALTY__',
            HC4__TaxonomyCode__c = '__TEST_CODE__'
        );
        
        insert s;
        
        HC4__ProviderSpecialty__c sp = new HC4__ProviderSpecialty__c(
            HC4__Provider__c = provider.Id,
            HC4__Specialty__c = s.Id
        );
        insert sp;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers';
        request.params.put('specialtyIds', s.Id);
        request.resourcePath = '/mobile/prm/v1/Providers/*';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmProviderController.Provider> providers = RestPrmProviderController.doGet();
        
        System.assertEquals(1, providers.size());
        System.assertEquals(provider.ID, providers[0].id);
    }
    
    static testMethod void doGet_RetrievesMatchingProvidersWithAOEValue() {
        Contact provider = new Contact(
           FirstName = '__JOHN__',
           Lastname = '__DOE__'
        );
        insert provider;
        
        HC4__AreaOfExpertise__c aoe = new HC4__AreaOfExpertise__c(
            Name = ' __TEST_SPECIALTY__'
        );
        
        insert aoe;
        
        HC4__ProviderAreaOfExpertise__c paoe = new HC4__ProviderAreaOfExpertise__c(
            HC4__Provider__c = provider.Id,
            HC4__AreaOfExpertise__c = aoe.Id
        );
        insert paoe;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers';
        request.params.put('aoeIds', aoe.Id);
        request.resourcePath = '/mobile/prm/v1/Providers/*';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmProviderController.Provider> providers = RestPrmProviderController.doGet();
        
        System.assertEquals(1, providers.size());
        System.assertEquals(provider.ID, providers[0].id);
    }
    
    static testMethod void doGet_RetrievesMatchingProvidersWithPracticeValue() {
        Contact provider = new Contact(
           FirstName = '__JOHN__',
           Lastname = '__DOE__'
        );
        insert provider;
        
        Account practice = new Account(
            Name = ' __TEST_PRACTICE__'
        );
        
        insert practice;
        
        HC4__ProviderPractice__c pp = new HC4__ProviderPractice__c(
            HC4__Provider__c = provider.Id,
            HC4__Practice__c = practice.Id
        );
        insert pp;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers';
        request.params.put('practiceIds', practice.Id);
        request.resourcePath = '/mobile/prm/v1/Providers/*';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmProviderController.Provider> providers = RestPrmProviderController.doGet();
        
        System.assertEquals(1, providers.size());
        System.assertEquals(provider.ID, providers[0].id);
    }
    
    static testMethod void doGet_RetrievesMatchingProvidersWithTerritoryValue() {
        Contact provider = new Contact(
           FirstName = '__JOHN__',
           Lastname = '__DOE__'
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
            Name = '__TEST_TERRITORY__'
        );
        insert territory;
        
        HC4__ProviderLocationTerritory__c plt = new HC4__ProviderLocationTerritory__c(
            HC4__ProviderLocation__c = pl.Id,
            HC4__Territory__c = territory.Id
        );
        insert plt;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers';
        request.params.put('territoryIds', territory.Id);
        request.resourcePath = '/mobile/prm/v1/Providers/*';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmProviderController.Provider> providers = RestPrmProviderController.doGet();
        
        System.assertEquals(1, providers.size());
        System.assertEquals(provider.ID, providers[0].id);
    }
    
    static testMethod void doGet_RetrievesMatchingProvidersWithZipCodeValue() {
        Contact provider = new Contact(
           FirstName = '__JOHN__',
           Lastname = '__DOE__'
        );
        insert provider;
        
        HC4__Location__c location = new HC4__Location__c(
            HC4__MailingPostalCode__c = '99999',
            HC4__OtherPostalCode__c = '99999'
        );
        insert location;
        
        HC4__ProviderLocation__c pl = new HC4__ProviderLocation__c(
            HC4__Location__c = location.Id,
            HC4__Provider__c = provider.Id
        );
        insert pl;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers';
        request.params.put('zipCode', '99999');
        request.resourcePath = '/mobile/prm/v1/Providers/*';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmProviderController.Provider> providers = RestPrmProviderController.doGet();
        
        System.assertEquals(1, providers.size());
        System.assertEquals(provider.ID, providers[0].id);
    }
    
    static testMethod void doGet_RetrievesMatchingProvidersWithLocationsValue() {
        Contact provider = new Contact(
           FirstName = '__JOHN__',
           Lastname = '__DOE__'
        );
        insert provider;
        
        HC4__Location__c location = new HC4__Location__c(
            HC4__MailingPostalCode__c = '99999',
            HC4__OtherPostalCode__c = '99999'
        );
        insert location;
        
        HC4__ProviderLocation__c pl = new HC4__ProviderLocation__c(
            HC4__Location__c = location.Id,
            HC4__Provider__c = provider.Id
        );
        insert pl;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers';
        request.params.put('locationIds', location.Id);
        request.resourcePath = '/mobile/prm/v1/Providers/*';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmProviderController.Provider> providers = RestPrmProviderController.doGet();
        
        System.assertEquals(1, providers.size());
        System.assertEquals(provider.ID, providers[0].id);
    }
}