/* Copyright (c) 2008-2014 Evariant */
global with sharing class RestPrmAlertController {

    global class AlertFeed {
    	
        public List<RestPrmIssueController.Issue> openIssues { get; private set; }
        public List<RestPrmTaskController.RestTask> overdueTasks { get; private set; }
        
        public AlertFeed () {
            this.openIssues = new List<RestPrmIssueController.Issue>();
            this.overdueTasks = new List<RestPrmTaskController.RestTask>();
        }
    }   
}