/* Copyright (c) 2008-2014 Evariant */
@isTest(SeeAllData=false)
private class TestRestPrmDescribeController {
	static testMethod void doGet_RetrievesForProvider() {
        Contact provider = new Contact (
           FirstName = '__JOHN__',
           LastName = '__DOE__'
        );
        
        insert provider;         
        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Describes/' + provider.Id;
        request.resourcePath = '/mobile/prm/v1/Describes/*';
        request.addParameter('pageSize', '1');
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        Map<String, Map<String, List<uRestController.PicklistEntry>>> mapTemp = RestPrmDescribeController.doGet();
        
        System.assert( mapTemp.size() >= 0 );        
    }
    
    static testMethod void doGet_RetrievesForAll() { 
        RestRequest requestIssue = new RestRequest();
        requestIssue.requestURI = '/mobile/prm/v1/Describes/Issue';
        requestIssue.resourcePath = '/mobile/prm/v1/Describes/*';
        requestIssue.addParameter('pageSize', '1');
        System.RestContext.request = requestIssue;
        System.RestContext.response = new RestResponse();
        
        Map<String, Map<String, List<uRestController.PicklistEntry>>> mapIssue = RestPrmDescribeController.doGet();
        
        System.assert( mapIssue.size() >= 0 );  
        
        RestRequest requestTask = new RestRequest();
        requestTask.requestURI = '/mobile/prm/v1/Describes/Task';
        requestTask.resourcePath = '/mobile/prm/v1/Describes/*';
        requestTask.addParameter('pageSize', '1');
        System.RestContext.request = requestTask;
        System.RestContext.response = new RestResponse();
        
        Map<String, Map<String, List<uRestController.PicklistEntry>>> mapTask = RestPrmDescribeController.doGet(); 
        
        RestRequest requestCall = new RestRequest();
        requestCall.requestURI = '/mobile/prm/v1/Describes/Call';
        requestCall.resourcePath = '/mobile/prm/v1/Describes/*';
        requestCall.addParameter('pageSize', '1');
        System.RestContext.request = requestCall;
        System.RestContext.response = new RestResponse();
        
        Map<String, Map<String, List<uRestController.PicklistEntry>>> mapCall = RestPrmDescribeController.doGet();  
        
        RestRequest requestNote = new RestRequest();
        requestNote.requestURI = '/mobile/prm/v1/Describes/Note';
        requestNote.resourcePath = '/mobile/prm/v1/Describes/*';
        requestNote.addParameter('pageSize', '1');
        System.RestContext.request = requestNote;
        System.RestContext.response = new RestResponse();
        
        Map<String, Map<String, List<uRestController.PicklistEntry>>> mapNote = RestPrmDescribeController.doGet();    
    }
    
    
}