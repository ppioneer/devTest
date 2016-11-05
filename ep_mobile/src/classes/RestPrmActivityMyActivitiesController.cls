/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v1/ActivityFeed/myActivityFeed')
global with sharing class RestPrmActivityMyActivitiesController {
    @HttpGet
    global static RestPrmActivityController.ActivityFeed doGet() {
     RestPrmActivityController.ActivityFeed response = new RestPrmActivityController.ActivityFeed();
        
        try {
        	response.calls.addAll(RestPrmCallMyCallsController.doGet());
        	response.issues.addAll(RestPrmIssueMyIssuesController.doGet());
        	response.notes.addAll(RestPrmNoteMyNotesController.doGet());
        	response.tasks.addAll(RestPrmTaskMyTasksController.doGet());
        }
        catch(Exception e) {
            System.debug(LoggingLevel.ERROR, e);
            uRestController.setStatusCode(uRestController.NotFound);
        }

        return response;
    }
}