/* Copyright (c) 2008-2014 Evariant */
@isTest
private with sharing class TestRestPrmProviderScoreController {
    static testMethod void doGet_RetrievesObjectById() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        insert provider;
        
        HC4__ServiceLine__c sl = new HC4__ServiceLine__c(
            Name = '__TEST_NAME__',
            HC4__Code__c = 'THECODE'
        );
        insert sl;
        
        HC4__ProviderScore__c score = new HC4__ProviderScore__c(
            HC4__Provider__c = provider.Id,
            HC4__ServiceLine__c = sl.Id
        );
        insert score;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Providers/' + provider.Id + '/Scores';
        request.resourcePath = '/mobile/prm/v1/Providers/*/Scores';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<RestPrmProviderScoreController.ProviderScore> scores = RestPrmProviderScoreController.doGet();
        
        System.assertEquals(1, scores.size());
        System.assertEquals(score.ID, scores[0].id);
    }
}