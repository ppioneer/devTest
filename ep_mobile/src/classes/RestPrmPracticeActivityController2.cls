/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v2/Practices/*/ActivityFeed')
global with sharing class RestPrmPracticeActivityController2 {
	
	@HttpGet
    global static RestPrmActivityController2.ActivityFeed doGet() {
     
	    RestPrmActivityController2.ActivityFeed response = new RestPrmActivityController2.ActivityFeed();        
	        
        try {
            response.calls.addAll(RestPrmPracticeCallController2.doGet());
            response.notes.addAll(RestPrmPracticeNoteController2.doGet());            
            response.tasks.addAll(RestPrmPracticeTaskController2.doGet());
        }
        catch(Exception e) {
            System.debug(LoggingLevel.ERROR, e);
            uRestController.setStatusCode(uRestController.NotFound);
        }
	        
	    return response;
    }
}