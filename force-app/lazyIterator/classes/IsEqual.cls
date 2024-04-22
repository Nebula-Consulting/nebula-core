/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 25/09/2019
 * @description <code>BooleanFunction</code> which takes two <code>Functions</code>/Objects that can be applied to the test values before
 * comparing with .isEqual(). Note that this means Strings are treated case-sensitively
 */
global class IsEqual implements BooleanFunction {

    private FunctionList functions;

    /** Constructs a boolean function that when called will evaluate whether left is equal to right
     * @example
     * //filtering a list of accounts to find accounts with Name equal to 'Test Account'
     * List<Account> filteredAccounts = new nebc.LazySObjectIterator(accounts)
     *      .filterT(
     *          new nebc.IsEqual(new nebc.FieldFromSObject(Account.Name), 'Test Account')
     *      )
     *      .toList();
     *
     * @param leftFunctionOrValue function or value that will be evaluated for being equal to right
     * @param rightFunctionOrValue function or value that will be evaluated for being equal to left
     */
    global IsEqual(Object leftFunctionOrValue, Object rightFunctionOrValue) {
        functions = new FunctionList(leftFunctionOrValue, rightFunctionOrValue);
    }

    /** Constructs a boolean function that when called will evaluate whether left is equal to right
     * @example
     * //filtering a list of accounts to find accounts with Name equal to 'Test Account'
     * List<Account> filteredAccounts = new nebc.LazySObjectIterator(accounts)
     *      .filterT(new nebc.IsEqual(Account.Name, 'Test Account'))
     *      .toList();
     *
     * @param field a <code>SObjectField</code> that provides a value to compare to rightFunctionOrValue
     * @param rightFunctionOrValue function or value that will be evaluated for being equal to left
     */
    global IsEqual(SObjectField field, Object rightFunctionOrValue) {
        functions = new FunctionList(new FieldFromSObject(field), rightFunctionOrValue);
    }

    /** Constructs a boolean function that when called will evaluate whether left is equal to right
     * @example
     * //filtering a list of accounts to find accounts where Billing and Shipping Country are equal
     * List<Account> filteredAccounts = new nebc.LazySObjectIterator(accounts)
     *      .filterT(new nebc.IsEqual(Account.BillingCountry, Account.ShippingCountry))
     *      .toList();
     *
     * @param left a <code>SObjectField</code> that provides a value to compare to right
     * @param right a <code>SObjectField</code> that provides a value to compare to left
     */
    global IsEqual(SObjectField left, SObjectField right) {
        functions = new FunctionList(new FieldFromSObject(left), new FieldFromSObject(right));
    }

    /** Constructs a boolean function that when called will evaluate whether the current iterator member is greater than right
     * @example
     * //getting a count of the number of accounts with name 'Test Account'
     * Integer numberOfTestAccounts = new nebc.LazySObjectIterator(accounts)
     *      .get(Account.Name)
     *      .filter(new nebc.IsEqual('Test Account'))
     *      .toList(new List<String>())
     *      .size();
     *
     * @param rightFunctionOrValue object that right will be evaluated for being greater than
     */
    global IsEqual(Object rightFunctionOrValue) {
        functions = new FunctionList(new IdentityFunction(), rightFunctionOrValue);
    }

    global Boolean isTrueFor(Object o) {
        Object leftValue = functions.functions[0].call(o);
        Object rightValue = functions.functions[1].call(o);

        return (leftValue == null && rightValue == null) || (leftValue != null && leftValue.equals(rightValue));
    }
}