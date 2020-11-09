@isTest
public class ApexPlugin_Test 
{
    private static Type pluginType = ApexPlugin_Test.class;

    @isTest
    public static void getType() 
    {
        Plugin pluginFromString = new ApexPlugin('ApexPlugin_Test');
        Plugin pluginFromType = new ApexPlugin(pluginType);

        Type resultFromString = pluginFromString.type();
        Type resultFromType = pluginFromType.type();

        System.assertEquals(pluginType,resultFromString);
        System.assertEquals(pluginType,resultFromType);
    }

    @isTest
    public static void invalidDynamicTypeThrowsException() 
    {
        Plugin pluginFromString = new ApexPlugin('THIS IS AN INVALID TYPE');

        Exception failure;
        try {
            Type result = pluginFromString.type();
        } catch(Exception e) {
            failure = e;
        }

        System.assert(failure instanceof IllegalArgumentException);
    }

    @isTest
    public static void newInstance() {
        Plugin plugin = new ApexPlugin(pluginType);

        Object resultWithoutParams = plugin.newInstance();
        Object resultWithParams = plugin.newInstance(new Map<String,Object>{'test'=>'params'});

        System.assert(resultWithoutParams instanceof ApexPlugin_Test);
        System.assert(resultWithParams instanceof ApexPlugin_Test);
    }
}