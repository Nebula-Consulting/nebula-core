/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-02-28
 * @description Allows you to pass functions around
 */

global interface Function {
    Object call(Object o);
}