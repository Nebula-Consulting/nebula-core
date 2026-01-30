/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-08-21
 * @description A <code>Function</code> that allows for the chaining of multiple supplied <code>Function</code> calls.
 */
global virtual class Composition implements Function {

    private List<Function> functions;

    /**A <code>Function</code> that allows for the chaining of multiple supplied <code>Function</code> calls.
     *
     * Constructs a Composition with the supplied function being the first function. Any additionally added functions are
     * called after function1 on it's results.
     *
     * @example
     * //Retrieves the account name from a map of related accounts
     * //Function 1 retrieves the Contact's AccountId field value
     * //Function 2 takes the account Id and uses it to retrieve the account from the map
     * //Function 3 retrieves the Account's Name field value
     * Map<Id, Account> accountMap = new Map<Id,Account>{[SELECT Id, Name FROM Account]}
     * new nebc.LazySObjectIterator(contacts)
     *      .put(
     *          Contact.Account_Name__c,
     *          new nebc.Composition(new nebc.FieldFromSObject(Contact.AccountId))
     *              .compose(new nebc.GetFrom(accountMap))
     *              .compose(new nebc.FieldFromSObject(Account.Name))
     *      )
     *      .forEach();
     *
     * @param function1 the first <code>Function</code> to be called
     */
    global Composition(Function function1) {
        functions = new List<Function> { function1 };
    }

    /**A <code>Function</code> that allows for the chaining of multiple supplied <code>Function</code> calls.
     *
     * Constructs a Composition where the first function is always FieldFromSObject. Any additionally added functions are
     * called on the retrieved field value
     *
     * @example
     * //Retrieves the account name from a map of related accounts
     * //Function 1 retrieves the Contact's AccountId field value
     * //Function 2 takes the account Id and uses it to retrieve the account from the map
     * //Function 3 retrieves the Account's Name field value
     * Map<Id, Account> accountMap = new Map<Id,Account>{[SELECT Id, Name FROM Account]}
     * new nebc.LazySObjectIterator(contacts)
     *      .put(
     *          Contact.Account_Name__c,
     *          new nebc.Composition(Contact.AccountId)
     *              .compose(new nebc.GetFrom(accountMap))
     *              .compose(new nebc.FieldFromSObject(Account.Name))
     *      )
     *      .forEach();
     *
     * @param field the <code>SObjectField</code> to be retrieved. Any additional functions added to the composition are
     * called on the field's value.
     */
    global Composition(SObjectField field) {
        functions = new List<Function> { new FieldFromSObject(field) };
    }

    /**A <code>Function</code> that allows for the chaining of multiple supplied <code>Function</code> calls.
     *
     * Constructs a Composition with the supplied functions being the first two functions. Any additionally added functions are
      * called after function2 on its results.
      *
      * @example
      * //Retrieves the account name from a map of related accounts
      * //Function 1 retrieves the Contact's AccountId field value
      * //Function 2 takes the account Id and uses it to retrieve the account from the map
      * //Function 3 retrieves the Account's Name field value
      * Map<Id, Account> accountMap = new Map<Id,Account>{[SELECT Id, Name FROM Account]}
      * new nebc.LazySObjectIterator(contacts)
      *      .put(
      *          Contact.Account_Name__c,
      *          new nebc.Composition(new nebc.FieldFromSObject(Contact.AccountId), new nebc.GetFrom(accountMap))
      *              .compose(new nebc.FieldFromSObject(Account.Name))
      *      )
      *      .forEach();
      *
      * @param function1 the first <code>Function</code> to be called
      * @param function2 the second <code>Function</code> to be called
      */
    global Composition(Function function1, Function function2) {
        functions = new List<Function> { function1, function2 };
    }

    /**A <code>Function</code> that allows for the chaining of multiple supplied <code>Function</code> calls.
    *
    * Constructs a Composition with the supplied functions being the first three functions. Any additionally added functions are
    * called after function 3 on its results.
    *
    * @example
    * //Retrieves the account name from a map of related accounts
    * //Function 1 retrieves the Contact's AccountId field value
    * //Function 2 takes the account Id and uses it to retrieve the account from the map
    * //Function 3 retrieves the Account's Name field value
    * Map<Id, Account> accountMap = new Map<Id,Account>{[SELECT Id, Name FROM Account]}
    * new nebc.LazySObjectIterator(contacts)
    *      .put(
    *          Contact.Account_Name__c,
    *          new nebc.Composition(
    *               new nebc.FieldFromSObject(Contact.AccountId),
    *               new nebc.GetFrom(accountMap),
    *               new nebc.FieldFromSObject(Account.Name)
    *          )
    *      )
    *      .forEach();
    *
    * @param function1 the first <code>Function</code> to be called
    * @param function2 the second <code>Function</code> to be called
    * @param function3 the third <code>Function</code> to be called
    */
    global Composition(Function function1, Function function2, Function function3) {
        functions = new List<Function> { function1, function2, function3 };
    }

    /**
    * Adds a new <code>Function</code> to the list of functions.
    *
    * @example
    * //Adds two additional functions to a instantiated composition
    * new nebc.Composition(Contact.AccountId)
    *              .add(new nebc.GetFrom(accountMap))
    *              .add(new nebc.FieldFromSObject(Account.Name))
    *
    * @param function the <code>Function</code> to be added to the composition's function list
    * @return returns the same composition
    */
    global Composition add(Function function) {
        functions.add(function);
        return this;
    }

    /**
    * Adds a new <code>Function</code> to the list of functions.
    *
    * @example
    * //Adds two additional functions to a instantiated composition
    * new nebc.Composition(Contact.AccountId)
    *              .compose(new nebc.GetFrom(accountMap))
    *              .compose(new nebc.FieldFromSObject(Account.Name))
    *
    * @param function the <code>Function</code> to be added to the composition's function list
    * @return returns the same composition
    */
    global Composition compose(Function function) {
        functions.add(function);
        return this;
    }

    /**
    * Calls every function in the composition in order
    *
    * @param o Object which the first function of the composition is called
    * @return returns the result of the composition
    */
    global virtual Object call(Object o) {
        Object returnVal = o;
        for(Integer i=0; i < functions.size(); i++) {
            returnVal = functions[i].call(returnVal);
        }
        return returnVal;
    }
}