public class JobRequisitionTriggerHandler {
    public static void onAfterUpdate(Map<ID,Job_Requisition__c> pOldMap, 
                                    Map<ID,Job_Requisition__c> pNewMap){
        //Create Job_Application_Interview__c records based on the job type
        //Start by querying the extended values of the passed pNewMap.
        //This will ensure you have access to related record's values
        //such as Recruitment_Stage__r.Name
        Map<ID,Job_Requisition__c> pExtendedNewMap = 
            new Map<ID, Job_Requisition__c>([SELECT Id, Department__c, 
                                            Country__c, Recruiter__c, 
                                            Job_Description__c, 
                                            Recruitment_Stage__c, 
                                            Recruitment_Stage__r.Name
                                            FROM Job_Requisition__c
                                            where ID in :pNewMap.Keyset()]);
                                            
        //This map will be used to store the requisitions
        //that require creation of interview records
        Map<ID,Job_Requisition__c> pRequisitionsNeedInterviewRecords = 
                                        new Map<ID, Job_Requisition__c>();
        
        //This set will be used to store the Job_Description__c ID
        //that has requisitions that require creation of interview records
        Set<ID> JDs = new Set<ID>();
       
        
        //Start by detecting if the Recruitment_Stage__c field
        //of the passed Job_Requisition__c records has been changed
        for (Job_Requisition__c oNewReq: pExtendedNewMap.Values()) {
        //Get the older version of the same record
        //The older version will have the values of the object before the update
        Job_Requisition__c oOldReq = pOldMap.get(oNewReq.Id);
        //Check if the value of the Recruitment_Stage__c has changed
        if(oNewReq.Recruitment_Stage__c != oOldReq.Recruitment_Stage__c){
            //Check if the new value is equal to 'Interview panel selection'.
            //Both if statements can be combined in a single line.
            //They were separated for easy reading
            //Please note the usage of a constants class to avoid hard coding
            if(oNewReq.Recruitment_Stage__r.Name == 
                'Interview panel selection') { //Constants.InterviewPanelSelectionStageName
                //Remember, you should not create a SOQL query within a loop.
                //Capture the relevant Job_Requisition__c records
                //And add them to a map
                pRequisitionsNeedInterviewRecords.put(oNewReq.ID, oNewReq);
                //Also, capture a unique list of job descriptions
                JDs.add(oNewReq.Job_Description__c);
            }
        } 
        }//End of loop
        
        List<Job_Interviewer__c> JobInterviewerListToCreate = 
                        getJobInterviewerListToCreate(JDs, pExtendedNewMap);  
        
        if(!JobInterviewerListToCreate.IsEmpty()){
            Insert JobInterviewerListToCreate;
        }                                                                                           
    }
    
    private static List<Job_Interviewer__c> getJobInterviewerListToCreate(
                        Set<ID> pJDs,Map<ID,Job_Requisition__c> pJobReqsMap){
        List<Job_Interviewer__c> JobInterviewerListToCreate 
                                            = new List<Job_Interviewer__c>();
        
        //Query the interviewer profile templates that matches
        //the job description IDs captured in the previous loop
        List<Interviewer_Profile_Template__c> InterviewerTemplateList = 
            new List<Interviewer_Profile_Template__c>(
                    [SELECT Id, Job_Description__c
                    From Interviewer_Profile_Template__c
                    where Job_Description__c in :pJDs]);
        for (Job_Requisition__c oReq: pJobReqsMap.Values()) {
            for (Interviewer_Profile_Template__c 
                oInterviewerTemplate: InterviewerTemplateList){
                //Check if the job description matches.
                //Remember that triggers work in batches.
                //A mass update to job requisitions could have triggered this code
                //You need to ensure you are picking the relevant records only
                if(oReq.Job_Description__c == 
                    oInterviewerTemplate.Job_Description__c){
                    Job_Interviewer__c oNewJobInterview = 
                        new Job_Interviewer__c();
                    oNewJobInterview.Job_Requisition__c = 
                        oReq.Id;
                    oNewJobInterview.Interviewer_Profile_Template__c = 
                        oInterviewerTemplate.Id;
                    //Do not auto fill the remaining Job_Interviewer__c fields.
                    //The recruiter should fill them manually
                    JobInterviewerListToCreate.add(oNewJobInterview);
                }
            }
        } 
        return JobInterviewerListToCreate;
    }
}