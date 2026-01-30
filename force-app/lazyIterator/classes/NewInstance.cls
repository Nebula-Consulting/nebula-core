/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 10/09/2020
 * @description For classes that can be constructed with a no-arg constructor, and then initialised after (e.g. when
 * they are reflectively constructed)
 */
global interface NewInstance {
    Object newInstance(List<Object> parameters);
}