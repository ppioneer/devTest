/* Copyright (c) 2008-2014 Evariant */
@isTest
private with sharing class TestRestPrmSLSubSLController {
    static testMethod void doGet_RetrievesObjectById() {
        HC4__ServiceLine__c sl = new HC4__ServiceLine__c(
            Name = '__TEST__',
            HC4__Code__c = '__TEST_CODE__'
        );
        
        insert sl;
        
        HC4__SubServiceLine__c ssl = new HC4__SubServiceLine__c(
            Name = '__TEST__',
            HC4__Code__c = '__TEST_CODE__',
            HC4__ServiceLine__c = sl .Id
        );
        insert ssl;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/ServiceLines/' + sl.Id + '/SubServiceLines';
        request.resourcePath = '/mobile/prm/v1/ServiceLines/*/SubServiceLines';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmSubServiceLineController.SubServiceLine> subServiceLines = RestPrmServiceLineSubServiceLine.doGet();
        
        System.assertEquals(1, subServiceLines.size());
        System.assertEquals(ssl.ID, subServiceLines[0].id);
        System.assertEquals(ssl.Name, subServiceLines[0].name);
    }
}