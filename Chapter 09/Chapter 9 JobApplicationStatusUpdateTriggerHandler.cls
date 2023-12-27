public class JobApplicationStatusUpdateTriggerHandler {
    //The following static field will only be used in Apex tests
    public static List<Job_Application_Status_Update__e> ListOfReceivedEvents 
        = new List<Job_Application_Status_Update__e>();
        
    public static void onAfterInsert(
            Map<ID,Job_Application_Status_Update__e> pNewMap){
        //Trigger.NewMap is only available in before update,
        //after insert, after update, and after undelete triggers
        
        //Execute the following statement only during tests
        if(Test.isRunningTest()){
            //Add the received events to the static field (a list)
            ListOfReceivedEvents.add(pNewMap.values());
        }                                                                                             
    }
}