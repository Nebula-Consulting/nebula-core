/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 16/11/2022
 */

@IsTest
private class ValueFromMapTest {

    static ValueFromMap valueFromMap = new ValueFromMap('f');

    @IsTest
    static void valueExists() {
        System.assertEquals('a', valueFromMap.call(new Map<String, Object>{ 'f' => 'a' }));
    }

    @IsTest
    static void nullValue() {
        System.assertEquals(null, valueFromMap.call(new Map<String, Object>{ 'f' => null }));
    }
    @IsTest
    static void noValue() {
        System.assertEquals(null, valueFromMap.call(new Map<String, Object>()));
    }
    @IsTest
    static void nullKey() {
        System.assertEquals(null, new ValueFromMap(null).call(new Map<String, Object>()));
    }
}