@isTest
private class JobApplicationStatusChangeFLTest {
    public static List<Job_Requisition__c> oTestRequisitions;
    public static List<Recruitment_Stage__c> oRecStages;
    @TestSetup static void setupTestData() {
        //Create 2 contacts, one to be used for the recruiter
        //The other to be used for the candidate
        List<Contact> oTestContacts = TestDataFactory.createContacts(2);
        insert oTestContacts;
        //Create a department
        List<Department__c> oTestDepartments = TestDataFactory.createDepartments(1);
        insert oTestDepartments;
        //Create a recruitment stage linked to the department
        oRecStages = TestDataFactory.createRecStage(2,oTestDepartments[0]);
        insert oRecStages;
        //Create a job requisition
        oTestRequisitions = TestDataFactory.createJobRequisitions(1, 
                                                            oTestDepartments[0], 
                                                            oTestContacts[0], 
                                                            oRecStages[0]);
                                                            
        //Set the recruiter__c value for the job requisition to the first contact
        oTestRequisitions[0].Recruiter__c = oTestContacts[0].Id;
        insert oTestRequisitions;
        //Create a job application
        Job_Application__c oNewJobApp = new Job_Application__c();
        oNewJobApp.Candidate__c = oTestContacts[1].Id;
        oNewJobApp.Job_Requisition__c = oTestRequisitions[0].Id;
        //Hardcoded Status__c value for simplicity, avoid in real life
        oNewJobApp.Status__c = 'Submitted';
        
        Insert oNewJobApp;
    }
    
    @IsTest
    static void validatePublishingJobApplicationStatusEvent() {
        Job_Application__c oJob = [select ID, Status__c 
                                        from Job_Application__c];
        //Hardcoded Status__c value for simplicity, avoid in real life
        oJob.Status__c = 'Offer accepted';
        oJob.Is_Invitation__c = true;
        
        //Start the test
        Test.startTest();
        Update oJob;
        //Stop the test
        //This ensures that Apex code and Flow executions have all complete
        Test.stopTest();
        
        //Assess the test results using the System class       
        //As the test here is updating a single Job application, the expected
        //result is to have a single Job_Application_Status_Update__e event in the
        //JobApplicationStatusUpdateTriggerHandler.ListOfReceivedEvents list
        //Note that the JobApplicationStatusUpdateTriggerHandler.ListOfReceivedEvents
        //list has been created just to facilitate this test as currently there is
        //no direct mechanism to validate if a platform event has been
        //published by a flow or not from within an Apex unit test
        Assert.areEqual(1,
            JobApplicationStatusUpdateTriggerHandler.ListOfReceivedEvents.size());

    }
}