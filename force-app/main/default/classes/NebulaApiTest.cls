/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-07-23
 */

@IsTest
private class NebulaApiTest {

    @IsTest
    static void urlEncodeBasic() {
        Map<String, String> values = new Map<String, String>{'a' => 'b', 'c' => 'd'};
        String result = NebulaApi.urlEncode(values);

        System.assertEquals('a=b&c=d', result);
    }

    @IsTest
    static void urlEncodeNullValue() {
        Map<String, String> values = new Map<String, String>{'a' => 'b', 'c' => null};
        String result = NebulaApi.urlEncode(values);

        System.assertEquals('a=b&c=', result);
    }

    @IsTest
    static void urlEncodeEmptyMap() {
        String result = NebulaApi.urlEncode(new Map<String, String>());

        System.assertEquals('', result);
    }
}