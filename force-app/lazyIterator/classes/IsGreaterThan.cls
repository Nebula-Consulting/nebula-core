/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 25/09/2019
 * @description A <code>BooleanFunction</code> which takes two <code>Functions</code>/Objects that can be applied to the test values before
 * comparing with >
 */
global class IsGreaterThan implements BooleanFunction {

    private FunctionList functions;

    /** Constructs a boolean function that when called will evaluate whether left is greater than right
     * @example
     * //filtering a list of accounts to find accounts created in the past 7 days.
     * List<Account> filteredAccounts = new nebc.LazySObjectIterator(accounts)
     *      .filterT(
     *          new nebc.IsGreaterThan(new nebc.FieldFromSObject(Account.CreatedDate), Date.today().addDays(-7))
     *      )
     *      .toList();
     *
     * @param left object that will be evaluated for being greater than right
     * @param right object that left will be evaluated for being greater than
     */
    global IsGreaterThan(Object left, Object right) {
        functions = new FunctionList(left, right);
    }

    /** Constructs a boolean function that when called will evaluate whether left is greater than right
     * @example
     * //filtering a list of accounts to find accounts created in the past 7 days.
     * List<Account> filteredAccounts = new nebc.LazySObjectIterator(accounts)
     *      .filterT(
     *          new nebc.IsGreaterThan(Account.CreatedDate, Date.today().addDays(-7))
     *      )
     *      .toList();
     *
     * @param left an <code>SObjectField</code> whose value will be evaluated for being greater than right
     * @param right object that left will be evaluated for being greater than
     */
    global IsGreaterThan(SObjectField left, Object right) {
        functions = new FunctionList(new FieldFromSObject(left), right);
    }

    /** Constructs a boolean function that when called will evaluate whether left is greater than right
     * @example
     * //filtering a list of accounts to find accounts that have more cases than orders.
     * List<Account> filteredAccounts = new nebc.LazySObjectIterator(accounts)
     *      .filterT(
     *          new nebc.IsGreaterThan(Account.Total_Cases__c, Account.Total_Orders__c)
     *      )
     *      .toList();
     *
     * @param left an <code>SObjectField</code> whose value will be evaluated for being greater than right
     * @param right an <code>SObjectField</code> whose value left will be evaluated for being greater than
     */
    global IsGreaterThan(SObjectField left, SObjectField right) {
        functions = new FunctionList(new FieldFromSObject(left), new FieldFromSObject(right));
    }

    /** Constructs a boolean function that when called will evaluate whether the current iterator member is greater than right
     * @example
     * //getting a count of the number of accounts created this week
     * Integer numberOfAccountsCreatedThisWeek = new nebc.LazySObjectIterator(accounts)
     *      .get(Account.CreatedDate)
     *      .filter(new nebc.IsGreaterThan(Date.today().addDays(-7)))
     *      .toList(new List<Datetime>())
     *      .size();
     *
     * @param right object that right will be evaluated for being greater than
     */
    global IsGreaterThan(Object right) {
        functions = new FunctionList(new IdentityFunction(), right);
    }

    global Boolean isTrueFor(Object o) {
        Object leftValue = functions.functions[0].call(o);
        Object rightValue = functions.functions[1].call(o);

        if(leftValue instanceof String) {
            return (String)leftValue > (String)rightValue;
        } else if (leftValue instanceof Integer) {
            return (Integer)leftValue > (Integer)rightValue;
        } else if (leftValue instanceof Decimal) {
            return (Decimal)leftValue > (Decimal)rightValue;
        } else if (leftValue instanceof Datetime) {
            return (Datetime)leftValue > (Datetime)rightValue;
        } else if (leftValue instanceof Date) {
            return (Date)leftValue > (Date)rightValue;
        }

        throw new TypeException('Cannot convert ' + leftValue + ' to a suitable type for ' + IsGreaterThan.class.getName());
    }
}