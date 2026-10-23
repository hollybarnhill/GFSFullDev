@IsTest
private class PMReportSignatureServiceTest {
    // 1x1 transparent PNG
    private static final String PNG = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==';

    @IsTest
    static void savesBothSignaturesAsFilesOnTheReport() {
        WorkOrder wo = new WorkOrder();
        insert wo;
        PM_Service_Report__c report = new PM_Service_Report__c(Work_Order__c = wo.Id);
        insert report;

        PMReportSignatureService.Request req = new PMReportSignatureService.Request();
        req.reportId = report.Id;
        req.storeRepSignature = PNG;
        req.technicianSignature = PNG;

        Test.startTest();
        PMReportSignatureService.save(new List<PMReportSignatureService.Request>{ req });
        Test.stopTest();

        System.assertEquals(2, [SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId = :report.Id]);
    }

    @IsTest
    static void skipsBlankSignatures() {
        WorkOrder wo = new WorkOrder();
        insert wo;
        PM_Service_Report__c report = new PM_Service_Report__c(Work_Order__c = wo.Id);
        insert report;

        PMReportSignatureService.Request req = new PMReportSignatureService.Request();
        req.reportId = report.Id;
        req.storeRepSignature = PNG;

        PMReportSignatureService.save(new List<PMReportSignatureService.Request>{ req });

        System.assertEquals(1, [SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId = :report.Id]);
    }
}
