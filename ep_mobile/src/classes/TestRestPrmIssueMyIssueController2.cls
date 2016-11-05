/* Copyright (c) 2008-2014 Evariant */
@isTest(SeeAllData=false)
private class TestRestPrmIssueMyIssueController2 {

   static testMethod void doGet_RetrievesMyIssues() {
        Contact provider = new Contact(
           FirstName = '__JOHN__',
           LastName = ' __DOE__'
        );
        
        insert provider;
        
        Lead patient = new Lead(
           FirstName = '__JOHN__',
           LastName = ' __DOE__'
        );
        
        insert patient;
        
        HC4__Inquiry__c inquiry = new HC4__Inquiry__c();
        
        insert inquiry;
        
        HC4__Issue__c issue = new HC4__Issue__c(
           HC4__Subject__c = '__TEST__',
           HC4__Patient__c = patient.Id,
           HC4__Provider__c = provider.Id,
           HC4__Inquiry__c = inquiry.Id,
           OwnerId = UserInfo.getUserId()
        );
        
        insert issue;
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v2/Issues/myIssues';
        request.resourcePath = '/mobile/prm/v2/Issues/myIssues';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        List<uRestController.GenericGetListResponse> issues = RestPrmIssueMyIssuesController2.doGet();
        
        System.assertEquals(1, issues.size());
        System.assertEquals(issue.ID, issues[0].id);
    }
}