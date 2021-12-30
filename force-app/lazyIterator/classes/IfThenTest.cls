/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 29/12/2021
 */

@IsTest
private class IfThenTest {

    @IsTest
    static void callThen() {
        IfThen instance = new IfThen(new ConstantBooleanFunction(true), new ConstantFunction('a'));

        System.assertEquals('a', instance.call(null));
    }

    @IsTest
    static void callImplicitIdentity() {
        IfThen instance = new IfThen(new ConstantBooleanFunction(false), new ConstantFunction('a'));

        System.assertEquals('b', instance.call('b'));
    }

    @IsTest
    static void callElse() {
        IfThen instance = new IfThen(new ConstantBooleanFunction(false), new ConstantFunction('a'))
                .elseFunction(new ConstantFunction('b'));

        System.assertEquals('b', instance.call('c'));
    }
}