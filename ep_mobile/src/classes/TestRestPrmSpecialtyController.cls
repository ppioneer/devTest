/* Copyright (c) 2008-2014 Evariant */
@isTest
private with sharing class TestRestPrmSpecialtyController {
    static testMethod void doGet_RetrievesObjectById() {
    	HC4__Specialty__c sp = new HC4__Specialty__c(
    	   Name = '__TEST__',
    	   HC4__TaxonomyCode__c = '__TEST_CODE__'
    	);
    	insert sp;
    	
    	RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Specialties/' + sp.Id;
        request.resourcePath = '/mobile/prm/v1/Specialties/*';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        
        List<RestPrmSpecialtyController.Specialty> specialties = RestPrmSpecialtyController.doGet();
        
        System.assertEquals(1, specialties.size());
        System.assertEquals(sp.ID, specialties[0].id);
        System.assertEquals(sp.Name, specialties[0].name);
    }
    
    static testMethod void doGet_RetrievesAllObjectsWhenNoId() {
        HC4__Specialty__c sp = new HC4__Specialty__c(
           Name = '__TEST__',
           HC4__TaxonomyCode__c = '__TEST_CODE__'
        );
        insert sp;
        
        sp = new HC4__Specialty__c(
           Name = '__TEST2__',
           HC4__TaxonomyCode__c = '__TEST_CODE2__'
        );
        insert sp;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Specialties/';
        request.resourcePath = '/mobile/prm/v1/Specialties/*';
        request.addParameter('pageSize', '2');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmSpecialtyController.Specialty> specialties = RestPrmSpecialtyController.doGet();
        
        System.assert(specialties.size() >= 2);
    }
    
    static testMethod void doGet_SearchesByNameWithQParam() {
        HC4__Specialty__c sp = new HC4__Specialty__c(
           Name = '__TEST__',
           HC4__TaxonomyCode__c = '__TEST_CODE__'
        );
        insert sp;
        
        sp = new HC4__Specialty__c(
           Name = '__TEST2__',
           HC4__TaxonomyCode__c = '__TEST_CODE2__'
        );
        insert sp;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Specialties/';
        request.resourcePath = '/mobile/prm/v1/Specialties/*';
        request.addParameter('pageSize', '2');
        request.addParameter('q', '__TEST2_');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmSpecialtyController.Specialty> specialties = RestPrmSpecialtyController.doGet();
        
        System.assert(specialties.size() == 1);
    }
}