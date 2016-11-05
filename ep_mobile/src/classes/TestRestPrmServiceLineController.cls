/* Copyright (c) 2008-2014 Evariant */
@isTest
private with sharing class TestRestPrmServiceLineController {
    static testMethod void doGet_RetrievesObjectById() {
        HC4__ServiceLine__c sl = new HC4__ServiceLine__c(
            Name = '__TEST__',
            HC4__Code__c = '__TEST_CODE__'
        );
        
        insert sl;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/ServiceLines/' + sl.Id;
        request.resourcePath = '/mobile/prm/v1/ServiceLines/*';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        
        List<RestPrmServiceLineController.ServiceLine> serviceLines = RestPrmServiceLineController.doGet();
        
        System.assertEquals(1, serviceLines.size());
        System.assertEquals(sl.ID, serviceLines[0].id);
        System.assertEquals(sl.Name, serviceLines[0].name);
    }
    
    static testMethod void doGet_RetrievesAllWhenNoId() {
        HC4__ServiceLine__c sl = new HC4__ServiceLine__c(
            Name = '__TEST__',
            HC4__Code__c = '__TEST_CODE__'
        );
        
        HC4__ServiceLine__c sl2 = new HC4__ServiceLine__c(
            Name = '__TEST2__',
            HC4__Code__c = '__TEST_CODE2__'
        );
        
        insert new List<HC4__ServiceLine__c> { sl, sl2 };
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/ServiceLines';
        request.resourcePath = '/mobile/prm/v1/ServiceLines/*';
        request.addParameter('pageSize', '2');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmServiceLineController.ServiceLine> serviceLines = RestPrmServiceLineController.doGet();
        
        System.assert(2 <= serviceLines.size());
    }
}