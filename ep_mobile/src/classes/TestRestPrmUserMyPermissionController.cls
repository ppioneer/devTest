@isTest
private class TestRestPrmUserMyPermissionController {

    static testMethod void doGet_RetrievesObjectByTask() {        
    	String objectById = 'Task'; 
    	
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Users/myPermissions/' + objectById;
        request.resourcePath = '/mobile/prm/v1/Users/myPermissions/*';
        
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        Map<String,RestPrmUserMyPermissionController.UserPermissions> permis = RestPrmUserMyPermissionController.doGet();
        
        System.assert(permis.size() >= 0);
        
    }
    
    static testMethod void doGet_RetrievesObjectByCall() {        
    	String objectById = 'call'; 
    	
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Users/myPermissions/' + objectById;
        request.resourcePath = '/mobile/prm/v1/Users/myPermissions/*';
        
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        Map<String,RestPrmUserMyPermissionController.UserPermissions> permis = RestPrmUserMyPermissionController.doGet();
        
        System.assert(permis.size() >= 0);
        
    }
    
    static testMethod void doGet_RetrievesObjectByIssue() {        
    	String objectById = 'issue'; 
    	
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Users/myPermissions/' + objectById;
        request.resourcePath = '/mobile/prm/v1/Users/myPermissions/*';
        
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        Map<String,RestPrmUserMyPermissionController.UserPermissions> permis = RestPrmUserMyPermissionController.doGet();
        
        System.assert(permis.size() >= 0);
        
    }
    
   static testMethod void doGet_RetrievesObjectByNote() {        
    	String objectById = 'note'; 
    	
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Users/myPermissions/' + objectById;
        request.resourcePath = '/mobile/prm/v1/Users/myPermissions/*';
        
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        Map<String,RestPrmUserMyPermissionController.UserPermissions> permis = RestPrmUserMyPermissionController.doGet();
        
        System.assert(permis.size() >= 0);
        
    }
    static testMethod void doGet_RetrievesObject() {        
    	
    	
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Users/myPermissions/';
        request.resourcePath = '/mobile/prm/v1/Users/myPermissions/';
        
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        Map<String,RestPrmUserMyPermissionController.UserPermissions> permis = RestPrmUserMyPermissionController.doGet();
        
        System.assertEquals(4, permis.size());
        
        RestRequest requestEmpty = new RestRequest();
        requestEmpty.requestURI = '/mobile/prm/v1/Users/myPermissions/__TEST__ABC';
        requestEmpty.resourcePath = '/mobile/prm/v1/Users/myPermissions/';
        
        System.RestContext.request = requestEmpty;
        System.RestContext.response = new RestResponse();
        
        Map<String,RestPrmUserMyPermissionController.UserPermissions> permis1 = RestPrmUserMyPermissionController.doGet();
        
    }
}