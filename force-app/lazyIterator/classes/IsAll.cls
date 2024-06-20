/** A <code>BooleanFunction</code> that will return true if the <code>isTrueFor</code> method of all supplied <code>BooleanFunction</code>s evaluate
 * to true. If any of the <code>BooleanFunction</code>s evaluate to false, then false is returned.
 *
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-06-21
 */
global class IsAll implements BooleanFunction {

    private List<BooleanFunction> booleanFunctions;

    /** All of the supplied Boolean Functions must evaluate to true for IsAll to return a true value.
     *
     * @example
     * //filters out all Accounts where the Name is not equal to Test, Example, Dummy or Ignore.
     * List<Account> filteredAccounts = new nebc.LazySObjectIterator(accounts)
     *      .filterOnField(
     *          Account.Name,
     *          new nebc.IsAll(
     *              new List<nebc.BooleanFunction> {
     *                  new nebc.IsNotEqual('Test'),
     *                  new nebc.IsNotEqual('Example'),
     *                  new nebc.IsNotEqual('Dummy'),
     *                  new nebc.IsNotEqual('Ignore')
     *              }
     *          )
     *      )
     *      .toList()
     *
     * @param booleanFunctions a list of <code>BooleanFunction</code>'s.
     */
    global IsAll(List<BooleanFunction> booleanFunctions) {
        this.booleanFunctions = booleanFunctions;
    }

    /** All of the supplied Boolean Functions must evaluate to true for IsAll to return a true value.
     *
     * @example
     * //filters out all Accounts where the Name is not equal to Test or Example
     * List<Account> filteredAccounts = new nebc.LazySObjectIterator(accounts)
     *      .filterOnField(
     *          Account.Name,
     *          new nebc.IsAll(
     *              new nebc.IsNotEqual('Test'),
     *              new nebc.IsNotEqual('Example')
     *          )
     *      )
     *      .toList()
     *
     * @param booleanFunction1 the first supplied <code>BooleanFunction</code> for evaluation.
     * @param booleanFunction2 the second supplied <code>BooleanFunction</code> for evaluation.
     */
    global IsAll(BooleanFunction booleanFunction1, BooleanFunction booleanFunction2) {
        this(new List<BooleanFunction>{booleanFunction1, booleanFunction2});
    }

    /** All of the supplied Boolean Functions must evaluate to true for IsAll to return a true value.
     *
     * @example
     * //filters out all Accounts where the Name is not equal to Test or Example
     * List<Account> filteredAccounts = new nebc.LazySObjectIterator(accounts)
     *      .filterOnField(
     *          Account.Name,
     *          new nebc.IsAll(
     *              new nebc.IsNotEqual('Test'),
     *              new nebc.IsNotEqual('Example'),
     *              new nebc.IsNotEqual('Dummy')
     *          )
     *      )
     *      .toList()
     *
     * @param booleanFunction1 the first supplied <code>BooleanFunction</code> for evaluation.
     * @param booleanFunction2 the second supplied <code>BooleanFunction</code> for evaluation.
     * @param booleanFunction3 the third supplied <code>BooleanFunction</code> for evaluation.
     */
    global IsAll(BooleanFunction booleanFunction1, BooleanFunction booleanFunction2, BooleanFunction booleanFunction3) {
        this(new List<BooleanFunction>{booleanFunction1, booleanFunction2, booleanFunction3});
    }

    /**
     * @param o the object that will be evaluated by all of the contained <code>BooleanFunction</code>'s.
     *
     * @return if all BooleanFunctions evaluate to true, the IsAll will return true. If any fail, then false is returned
     */
    global Boolean isTrueFor(Object o) {
        for(BooleanFunction thisBooleanFunction : booleanFunctions) {
            if(!thisBooleanFunction.isTrueFor(o)) {
                return false;
            }
        }
        return true;
    }
}
