/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-06-21
 */
global class IsInSObjectIndex implements BooleanFunction {
    private SObjectIndex theIndex;

    global IsInSObjectIndex(SObjectIndex theIndex) {
        this.theIndex = theIndex;
    }

    global Boolean isTrueFor(Object o) {
        if(o instanceof SObject) {
            return theIndex.get((SObject) o) != null;
        } else {
            return theIndex.get(o) != null;
        }
    }
}
