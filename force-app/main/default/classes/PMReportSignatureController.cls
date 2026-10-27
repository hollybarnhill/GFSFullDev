public with sharing class PMReportSignatureController {
    @AuraEnabled
    public static PM_Service_Report__c getLatestReport(Id workOrderId) {
        List<PM_Service_Report__c> reports = [
            SELECT Id, Name, Service_Date__c
            FROM PM_Service_Report__c
            WHERE Work_Order__c = :workOrderId
            ORDER BY CreatedDate DESC, Id DESC
            LIMIT 1
        ];
        return reports.isEmpty() ? null : reports[0];
    }

    @AuraEnabled
    public static void saveSignatures(Id reportId, String storeRepSignature, String technicianSignature) {
        PMReportSignatureService.Request req = new PMReportSignatureService.Request();
        req.reportId = reportId;
        req.storeRepSignature = storeRepSignature;
        req.technicianSignature = technicianSignature;
        PMReportSignatureService.save(new List<PMReportSignatureService.Request>{ req });

        PM_Service_Report__c report = new PM_Service_Report__c(Id = reportId);
        if (String.isNotBlank(storeRepSignature)) {
            report.Store_Rep_Signature_Date__c = Date.today();
        }
        if (String.isNotBlank(technicianSignature)) {
            report.Technician_Signature_Date__c = Date.today();
        }
        update report;
    }
}
