/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 07/05/2020
 * @description Construct with a container (Set, SObjectIndex, List), then isTrueFor() delegates to contains() for
 * the container
 */

global class IsContainedIn implements BooleanFunction {

    private Container theContainer;

    global IsContainedIn(SObjectIndex sObjectIndex) {
        theContainer = sObjectIndex;
    }

    global IsContainedIn(Set<Object> aSet) {
        theContainer = new SetObjectContainer(aSet);
    }

    global IsContainedIn(Set<String> aSet) {
        theContainer = new SetStringContainer(aSet);
    }

    global IsContainedIn(Set<Id> aSet) {
        theContainer = new SetIdContainer(aSet);
    }

    global IsContainedIn(List<Object> aList) {
        theContainer = new ListContainer(aList);
    }

    global Boolean isTrueFor(Object o) {
        return theContainer.contains(o);
    }

    private class SetObjectContainer implements Container {
        private Set<Object> theSet;

        public SetObjectContainer(Set<Object> theSet) {
            this.theSet = theSet;
        }

        public Boolean contains(Object o) {
            return theSet.contains(o);
        }
    }

    private class SetStringContainer implements Container {
        private Set<String> theSet;

        public SetStringContainer(Set<String> theSet) {
            this.theSet = theSet;
        }

        public Boolean contains(Object o) {
            return theSet.contains((String)o);
        }
    }

    private class SetIdContainer implements Container {
        private Set<Id> theSet;

        public SetIdContainer(Set<Id> theSet) {
            this.theSet = theSet;
        }

        public Boolean contains(Object o) {
            return theSet.contains((Id)o);
        }
    }

    private class ListContainer implements Container {

        private List<Object> aList;

        public ListContainer(List<Object> aList) {
            this.aList = aList;
        }

        public Boolean contains(Object o) {
            return aList.contains(o);
        }
    }
}