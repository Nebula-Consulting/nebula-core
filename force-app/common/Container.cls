/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 07/05/2020
 * @description Containers that you can call contains() on e.g Set, Map, SObjectIndex
 */

global interface Container {
    Boolean contains(Object o);
}