/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-06
 */

@IsTest
private class TestMetadataRecordGeneratorTest {

    static TestRecordSource testRecordSource = new TestRecordSource();
    static TestMetadataRecordGenerator generator = new TestMetadataRecordGenerator();

    @IsTest
    static void basicValue() {
        String accountName = 'ACME';
        generator.setup(
                testRecordSource,
                new Test_Record_Generator__mdt(
                        SObject__c = 'Account',
                        Parameters__c = JSON.serialize(
                                new Map<String, Object>{
                                        'Name' => new Map<String, Object>{
                                                'value' => accountName
                                        }
                                }
                        )
                )
        );
        Account generatedAccount = (Account)generator.getObjectNoInsert(null);

        System.assertEquals(accountName, generatedAccount.Name);
    }

    @IsTest
    static void appendRandomNumber() {
        String accountName = 'ACME';
        generator.setup(
                testRecordSource,
                new Test_Record_Generator__mdt(
                        SObject__c = 'Account',
                        Parameters__c = JSON.serialize(
                                new Map<String, Object>{'Name' => new Map<String, Object>{
                                        'valueFunction' =>
                                                new TestMetadataRecordGenerator.ValueFunction(
                                                        TestFieldFunctions.AppendRandomNumber.class.getName(),
                                                        new Map<String, Object>{
                                                                'value' => accountName
                                                        }
                                                )

                                }}
                        )
                )
        );
        Account generatedAccount = (Account)generator.getObjectNoInsert(null);

        System.assert(generatedAccount.Name.length() > accountName.length());
        System.assert(generatedAccount.Name.startsWith(accountName));
    }

    @IsTest
    static void parseDate() {
        Date birthDate = Date.newInstance(2019, 3, 5);
        generator.setup(
                testRecordSource,
                new Test_Record_Generator__mdt(
                        SObject__c = 'Contact',
                        Parameters__c = JSON.serialize(
                                new Map<String, Object>{'BirthDate' => new Map<String, Object>{
                                        'value' => birthDate
                                }
                                }
                        )
                )
        );
        Contact generatedContact = (Contact)generator.getObjectNoInsert(null);

        System.assertEquals(birthDate, generatedContact.Birthdate);
    }

    @IsTest
    static void parseDateTime() {
        Datetime closeDate = Datetime.now();

        generator.setup(
                testRecordSource,
                new Test_Record_Generator__mdt(
                        SObject__c = 'Case',
                        Parameters__c = JSON.serialize(
                                new Map<String, Object>{'ClosedDate' => new Map<String, Object>{
                                        'value' => closeDate
                                }
                                }
                        )
                )
        );
        Case generatedCase = (Case)generator.getObjectNoInsert(null);

        System.assertEquals(closeDate, generatedCase.ClosedDate);
    }

}