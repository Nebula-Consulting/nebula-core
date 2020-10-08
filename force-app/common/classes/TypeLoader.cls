/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 04/09/2018
 * @description Functions for loading/instantiating types
 */

global class TypeLoader {

    /**
     * Loads a Type from a string, searching for the first ., indicating the namespace. If this fails,
     * also tries for no namespace, and the . indicating a nested class
     *
     * @param className class to load. Can contain namespaces and/or be an inner class
     *
     * @return The type requested, or null if it is not found
     */
    global static Type getType(String className) {
        List<String> splitClassName = className.split('\\.', 2);
        String classToLoadNamespace;
        String classToLoadName;

        if(splitClassName.size() > 1) {
            classToLoadNamespace = splitClassName[0];
            classToLoadName = splitClassName[1];
        } else {
            classToLoadNamespace = '';
            classToLoadName = splitClassName[0];
        }
        Type returnVal = Type.forName(classToLoadNamespace, classToLoadName);

        if(returnVal != null) {
            return returnVal;
        } else {
            return Type.forName(className);
        }
    }

    /**
     * Creates an instance from a Type object, and some possible string params. If the params are not null,
     * JSON.deserialize is used to pre-populate some instance variables
     *
     * @param aType a type to create
     * @param maybeParams if null, class is created with newInstance(). If non-null, JSON.deserialize() is used with the given params
     *
     * @return the instance
     */
    global static Object getInstance(Type aType, String maybeParams) {
        if(maybeParams == null) {
            return aType.newInstance();
        } else {
            return JSON.deserialize(maybeParams, aType);
        }
    }

}