@IsTest
private class SObjectIndexReproductionTest {
    
    @IsTest
    static void testInvalidKeyCaseThrowsException() {
        // Setup
        Account accA = new Account(Name = 'A', Id = new nebc.TestIdGenerator(Account.SObjectType).next());
        
        nebc.SObjectIndex index = new nebc.SObjectIndex('Name');
        index.put(accA);
        
        // Test: Query with wrong case 'name' instead of 'Name'
        Boolean caughtException = false;
        try {
            index.get(new Map<String, Object>{
                'name' => 'A'
            });
        } catch (IllegalArgumentException e) {
            caughtException = true;
            System.assert(e.getMessage().contains('Key name is not in the index fields'), 'Unexpected error message: ' + e.getMessage());
        }
        
        System.assert(caughtException, 'Should have thrown IllegalArgumentException for invalid key case');
    }
    
    @IsTest
    static void testUnknownKeyThrowsException() {
         // Setup
        Account accA = new Account(Name = 'A', Id = new nebc.TestIdGenerator(Account.SObjectType).next());
        
        nebc.SObjectIndex index = new nebc.SObjectIndex('Name');
        index.put(accA);
        
        // Test: Query with unknown key
        Boolean caughtException = false;
        try {
            index.get(new Map<String, Object>{
                'UnknownField' => 'XYZ'
            });
        } catch (IllegalArgumentException e) {
            caughtException = true;
            System.assert(e.getMessage().contains('Key UnknownField is not in the index fields'), 'Unexpected error message: ' + e.getMessage());
        }
        
        System.assert(caughtException, 'Should have thrown IllegalArgumentException for unknown key');
    }

    @IsTest
    static void testRemoveWithInvalidKeyThrowsException() {
        // Setup
        Account accA = new Account(Name = 'A', Id = new nebc.TestIdGenerator(Account.SObjectType).next());
        
        nebc.SObjectIndex index = new nebc.SObjectIndex('Name');
        index.put(accA);
        
        // Test: Remove with unknown key
        Boolean caughtException = false;
        try {
            index.remove(new Map<String, Object>{
                'UnknownField' => 'XYZ'
            });
        } catch (IllegalArgumentException e) {
            caughtException = true;
        }
        
        System.assert(caughtException, 'Should have thrown IllegalArgumentException for unknown key in remove');
    }

    @IsTest
    static void testValidKeySuccess() {
        // Setup
        Account accA = new Account(Name = 'A', Id = new nebc.TestIdGenerator(Account.SObjectType).next());
        
        nebc.SObjectIndex index = new nebc.SObjectIndex('Name');
        index.put(accA);
        
        // Test: Query with valid key
        Account result = (Account) index.get(new Map<String, Object>{
            'Name' => 'A'
        });
        
        System.assertEquals(accA.Id, result.Id, 'Should find the account with valid key');
    }
}
