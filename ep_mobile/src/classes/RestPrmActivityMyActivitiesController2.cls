/* Copyright (c) 2008-2014 Evariant */
@RestResource(urlMapping='/mobile/prm/v2/ActivityFeed/myActivityFeed')
global with sharing class RestPrmActivityMyActivitiesController2 {
    @HttpGet
    global static RestPrmActivityController2.ActivityFeed doGet() {
     RestPrmActivityController2.ActivityFeed response = new RestPrmActivityController2.ActivityFeed();
        
        try {
        	response.calls.addAll(RestPrmCallMyCallsController2.doGet());
        	response.issues.addAll(RestPrmIssueMyIssuesController2.doGet());
        	response.notes.addAll(RestPrmNoteMyNotesController2.doGet());
        	response.tasks.addAll(RestPrmTaskMyTasksController2.doGet());
        }
        catch(Exception e) {
            System.debug(LoggingLevel.ERROR, e);
            uRestController.setStatusCode(uRestController.NotFound);
        }

        return response;
    }
}