public with sharing class PMReportSignatureService {
    public class Request {
        @InvocableVariable(required=true label='PM Service Report Id')
        public Id reportId;
        @InvocableVariable(label='Store Representative Signature (data URL)')
        public String storeRepSignature;
        @InvocableVariable(label='Service Technician Signature (data URL)')
        public String technicianSignature;
    }

    @InvocableMethod(label='Save PM Report Signatures' description='Saves signature images as files on a PM Service Report')
    public static void save(List<Request> requests) {
        List<ContentVersion> versions = new List<ContentVersion>();
        for (Request req : requests) {
            addVersion(versions, req.reportId, 'Store Representative Signature', req.storeRepSignature);
            addVersion(versions, req.reportId, 'Service Technician Signature', req.technicianSignature);
        }
        if (!versions.isEmpty()) {
            insert versions;
        }
    }

    private static void addVersion(List<ContentVersion> versions, Id reportId, String title, String dataUrl) {
        if (String.isBlank(dataUrl)) {
            return;
        }
        String base64 = dataUrl.contains(',') ? dataUrl.substringAfter(',') : dataUrl;
        versions.add(new ContentVersion(
            Title = title,
            PathOnClient = title.replace(' ', '') + '.png',
            VersionData = EncodingUtil.base64Decode(base64),
            FirstPublishLocationId = reportId
        ));
    }
}
