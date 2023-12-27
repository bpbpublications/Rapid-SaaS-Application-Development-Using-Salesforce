@isTest
public class TestDataFactory {
    public static List<Contact> createContacts(Integer pContactCount) {
        List<Contact> oNewContacts = new List<Contact>();
        for(Integer i=0;i<pContactCount;i++) {
            Contact oContact = new Contact(FirstName='TestFirst' + i, 
                                            LastName='TestLast' + i, 
                                            email='TestEmail'+i+'@Domain.com');
            oNewContacts.add(oContact);
        }
        
        return oNewContacts;
    }
    
    public static List<Job_Requisition__c> createJobRequisitions(
                                                Integer pReqCount,
                                                Department__c pDep,
                                                Contact pContact,
                                                Recruitment_Stage__c pRecS) {
        List<Job_Requisition__c> oNewReqs = new List<Job_Requisition__c>();
        for(Integer i=0;i<pReqCount;i++) {
            Job_Requisition__c oReq = new Job_Requisition__c();
            oReq.Department__c = pDep.ID;
            oReq.Recruiter__c = pContact.ID;
            oReq.Recruitment_Stage__c = pRecS.ID;
            
            oNewReqs.add(oReq);
        }
        
        return oNewReqs;
    } 
    
    public static List<Department__c> createDepartments(Integer pCount) {
        List<Department__c> oNewRecords = new List<Department__c>();
        for(Integer i=0;i<pCount;i++) {
            Department__c oDept = new Department__c(Name='TestDepartment' + i);
            oNewRecords.add(oDept);
        }
        
        return oNewRecords;
    }
    
    public static List<Recruitment_Stage__c> createRecStage(
                                                Integer pCount, 
                                                Department__c pDepartment) {
        List<Recruitment_Stage__c> oNewRecords = 
                                    new List<Recruitment_Stage__c>();
        for(Integer i=0;i<pCount;i++) {
            Recruitment_Stage__c oRecStage = 
                new Recruitment_Stage__c(Name='TestDepartment' + i,
                                        Department__c = pDepartment.Id,
                                        Sequence_Number__c = i);
            oNewRecords.add(oRecStage);
        }
        
        return oNewRecords;
    }
}