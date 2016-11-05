/* Copyright (c) 2008-2014 Evariant */
@isTest
private with sharing class TestRestPrmFeedbackController {
    static testMethod void doPost_ReturnsBadRequestOnNullParameter() {        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Feedback';
        request.resourcePath = '/mobile/prm/v1/Feedback/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmFeedbackController.doPost(null);
        
        System.assertEquals(400, RestContext.response.statusCode);
    }
    
    static testMethod void doPost_ReturnsPreconditionFailedOnNoComments() {        
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Feedback';
        request.resourcePath = '/mobile/prm/v1/Feedback/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmFeedbackController.Feedback f = new RestPrmFeedbackController.Feedback();
        
        RestPrmFeedbackController.doPost(f);
        
        System.assertEquals(412, RestContext.response.statusCode);
    }
    
    static testMethod void doPost_ReturnsCreated() {                
        RestRequest request = new RestRequest();
        request.requestURI = '/mobile/prm/v1/Feedback';
        request.resourcePath = '/mobile/prm/v1/Feedback/*';
        System.RestContext.request = request;
        System.RestContext.response = new RestResponse();
        
        RestPrmFeedbackController.Feedback f = new RestPrmFeedbackController.Feedback();
        f.comments = '__TESTING__';
        
        RestPrmFeedbackController.Feedback f2 = RestPrmFeedbackController.doPost(f);
        
        System.assertEquals(f.comments, f2.comments);
    }
}