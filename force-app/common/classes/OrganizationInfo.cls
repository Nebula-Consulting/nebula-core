/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-08-16
 * @description Cached access to Organization info
 */
global with sharing class OrganizationInfo {

    global static Organization organization;

    static {
        List<Organization> organizationInfos =
        [
                SELECT
                        City,
                        ComplianceBccEmail,
                        Country,
                        CreatedById,
                        CreatedDate,
                        DefaultAccountAccess,
                        DefaultCalendarAccess,
                        DefaultCampaignAccess,
                        DefaultCaseAccess,
                        DefaultContactAccess,
                        DefaultLeadAccess,
                        DefaultLocaleSidKey,
                        DefaultOpportunityAccess,
                        DefaultPricebookAccess,
                        Division,
                        Fax,
                        FiscalYearStartMonth,
                        GeocodeAccuracy,
                        InstanceName,
                        IsReadOnly,
                        IsSandbox,
                        LanguageLocaleKey,
                        LastModifiedById,
                        LastModifiedDate,
                        Latitude,
                        Longitude,
                        MonthlyPageViewsEntitlement,
                        MonthlyPageViewsUsed,
                        Name,
                        NamespacePrefix,
                        NumKnowledgeService,
                        OrganizationType,
                        Phone,
                        PostalCode,
                        PrimaryContact,
                        ReceivesAdminInfoEmails,
                        ReceivesInfoEmails,
                        SignupCountryIsoCode,
                        State,
                        Street,
                        SystemModstamp,
                        TimeZoneSidKey,
                        TrialExpirationDate,
                        UiSkin,
                        UsesStartDateAsFiscalYearName,
                        WebToCaseDefaultOrigin
                FROM Organization
        ];
        if(!organizationInfos.isEmpty()) {
            organization = organizationInfos[0];
        }
    }
}