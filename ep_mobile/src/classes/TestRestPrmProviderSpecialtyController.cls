/* Copyright (c) 2008-2014 Evariant */
@isTest
public with sharing class TestRestPrmProviderSpecialtyController {
    static testMethod void doGet_RetrievesObjectById() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        HC4__Specialty__c s = new HC4__Specialty__c(
            Name = '__TEST_SPECIALTY__',
            HC4__TaxonomyCode__c = '__TEST__'
        );
        insert s;
        
        HC4__ProviderSpecialty__c ps = new HC4__ProviderSpecialty__c(
            HC4__Provider__c = provider.Id,
            HC4__Specialty__c = s.Id,
            HC4__IsPrimary__c = true
        );
        insert ps;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers/' + provider.Id + '/Specialties';
        request.resourcePath = '/mobile/prm/v1/Providers/*/Specialties';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmSpecialtyController.Specialty> specialties = RestPrmProviderSpecialtyController.doGet();
        
        System.assertEquals(1, specialties.size());
        System.assertEquals(s.ID, specialties[0].id);
        System.assertEquals(ps.HC4__IsPrimary__c, specialties[0].isPrimary);
    }
}