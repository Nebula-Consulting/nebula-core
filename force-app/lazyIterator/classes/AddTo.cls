/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 14/07/2021
 * @description Adds the given value to a collection-like class supporting add(). Supports Set, List, SObjectIndex,
 * and Map (using TwoTuple for key-value pairs). Note that this is not a terminator function
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

    global AddTo(Map<Object, Object> container) {
        addable = new MapObjectAddable(container);
    }

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

    private class MapObjectAddable implements Addable {

        private Map<Object, Object> container;

        public MapObjectAddable(Map<Object, Object> container) {
            this.container = container;
        }

        public void add(Object o) {
            TwoTuple tuple = (TwoTuple)o;
            container.put(tuple.left, tuple.right);
        }
    }
}
