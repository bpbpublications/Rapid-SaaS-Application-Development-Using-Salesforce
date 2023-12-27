public class JobApplicationTriggerHandler {
    public static void onBeforeUpdate(Map<ID,Job_Application__c> pOldMap, 
                                    Map<ID,Job_Application__c> pNewMap){
        //Check if the Is_Invitation__c check box has been updated
        //and the new value is true, then generate a new unique ID (GUID)
        //for the invitation.
        
        for (Job_Application__c oUpdatedJobAppRecord: pNewMap.Values()) {
            if((oUpdatedJobAppRecord.Is_Invitation__c != 
                pOldMap.get(oUpdatedJobAppRecord.Id).Is_Invitation__c) &&
               (oUpdatedJobAppRecord.Is_Invitation__c)){
               
               oUpdatedJobAppRecord.Unique_Invitation_ID__c = generateGUID();
            }
        }
                                                                                                   
    }
    
    private static String generateGUID(){
        //This is a reusable code that can generate GUIDs
        //There are also other ways to generate GUID.
        Blob oAESKey = Crypto.GenerateAESKey(128);
        String oHexAESKey = EncodingUtil.ConvertTohex(oAESKey);
        String GUID = oHexAESKey.SubString(0,8)+ '-' + 
                        oHexAESKey.SubString(8,12) + '-' + 
                        oHexAESKey.SubString(12,16) + '-' + 
                        oHexAESKey.SubString(16,20) + '-' + 
                        oHexAESKey.substring(20);
        return GUID;
    }
}