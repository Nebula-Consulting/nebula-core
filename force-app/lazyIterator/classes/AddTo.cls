/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 14/07/2021
 * @description Adds the given value to a collection-like class supporting add(). Note that this is not a terminator
 * function
 */
global with sharing class AddTo implements Function {

    private Addable addable;

    global AddTo(Set<String> container) {
        addable = new SetStringAddable(container);
    }

    global AddTo(Set<Id> container) {
        addable = new SetIdAddable(container);
    }

    global AddTo(List<Object> container) {
        addable = new ListObjectAddable(container);
    }

    global AddTo(SObjectIndex container) {
        addable = new SObjectIndexAddable(container);
    }

    /**
     * @description Adds the value to the container and returns it unchanged
     * @param o The value to add
     * @return The same value passed in
     */
    global Object call(Object o) {
        addable.add(o);
        return o;
    }

    private class SetStringAddable implements Addable {

        private Set<String> container;

        public SetStringAddable(Set<String> container) {
            this.container = container;
        }

        public void add(Object o) {
            container.add((String)o);
        }
    }
    private class SetIdAddable implements Addable {

        private Set<Id> container;

        public SetIdAddable(Set<Id> container) {
            this.container = container;
        }

        public void add(Object o) {
            container.add((Id)o);
        }
    }

    private class ListObjectAddable implements Addable {

        private List<Object> container;

        public ListObjectAddable(List<Object> container) {
            this.container = container;
        }

        public void add(Object o) {
            container.add(o);
        }
    }

    private class SObjectIndexAddable implements Addable {

        private SObjectIndex container;

        public SObjectIndexAddable(SObjectIndex container) {
            this.container = container;
        }

        public void add(Object o) {
            container.put((SObject)o);
        }
    }
}
