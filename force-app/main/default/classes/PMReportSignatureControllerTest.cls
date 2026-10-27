@IsTest
private class PMReportSignatureControllerTest {
    // 1x1 transparent PNG
    private static final String PNG = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==';

    @IsTest
    static void returnsLatestReportForWorkOrder() {
        WorkOrder wo = new WorkOrder();
        insert wo;
        PM_Service_Report__c older = new PM_Service_Report__c(Work_Order__c = wo.Id);
        insert older;
        Test.setCreatedDate(older.Id, Datetime.now().addDays(-1));
        PM_Service_Report__c latest = new PM_Service_Report__c(Work_Order__c = wo.Id);
        insert latest;

        System.assertEquals(latest.Id, PMReportSignatureController.getLatestReport(wo.Id).Id);
    }

    @IsTest
    static void returnsNullWhenWorkOrderHasNoReport() {
        WorkOrder wo = new WorkOrder();
        insert wo;

        System.assertEquals(null, PMReportSignatureController.getLatestReport(wo.Id));
    }

    @IsTest
    static void savesSignaturesAndStampsDates() {
        WorkOrder wo = new WorkOrder();
        insert wo;
        PM_Service_Report__c report = new PM_Service_Report__c(Work_Order__c = wo.Id);
        insert report;

        PMReportSignatureController.saveSignatures(report.Id, PNG, PNG);

        report = [SELECT Store_Rep_Signature_Date__c, Technician_Signature_Date__c FROM PM_Service_Report__c WHERE Id = :report.Id];
        System.assertEquals(Date.today(), report.Store_Rep_Signature_Date__c);
        System.assertEquals(Date.today(), report.Technician_Signature_Date__c);
        System.assertEquals(2, [SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId = :report.Id]);
    }

    @IsTest
    static void leavesDateBlankForMissingSignature() {
        WorkOrder wo = new WorkOrder();
        insert wo;
        PM_Service_Report__c report = new PM_Service_Report__c(Work_Order__c = wo.Id);
        insert report;

        PMReportSignatureController.saveSignatures(report.Id, PNG, null);

        report = [SELECT Store_Rep_Signature_Date__c, Technician_Signature_Date__c FROM PM_Service_Report__c WHERE Id = :report.Id];
        System.assertEquals(Date.today(), report.Store_Rep_Signature_Date__c);
        System.assertEquals(null, report.Technician_Signature_Date__c);
    }
}
