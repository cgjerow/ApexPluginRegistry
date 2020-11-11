@isTest 
public class AType_Test 
{
    private static Type pluginType = AType_Test.class;

    @isTest
    public static void getType() 
    {
        Plugin pluginFromString = new AType('AType_Test');
        Plugin pluginFromType = new AType(pluginType);

        Type resultFromString = pluginFromString.type();
        Type resultFromType = pluginFromType.type();

        System.assertEquals(pluginType,resultFromString);
        System.assertEquals(pluginType,resultFromType);
    }

    @isTest
    public static void invalidDynamicTypeThrowsException() 
    {
        Plugin pluginFromString = new AType('THIS IS AN INVALID TYPE');

        Exception failure;
        try {
            Type result = pluginFromString.type();
        } catch(Exception e) {
            failure = e;
        }

        System.assert(failure instanceof IllegalArgumentException);
    }

    @isTest
    public static void newInstance() 
    {
        Plugin plugin = new AType(pluginType);

        Object resultWithoutParams = plugin.newInstance();
        Object resultWithParams = plugin.newInstance(new Map<String,Object>{'test'=>'params'});

        System.assert(resultWithoutParams instanceof AType_Test);
        System.assert(resultWithParams instanceof AType_Test);
    }


    @isTest
    public static void newCustomPluginInstance() 
    {
        Plugin customPlugin = new AType(CustomPlugin.class);
        CustomPlugin result = (CustomPlugin)customPlugin.newInstance();

        System.assert(result.defaultSuccess);
    }

    @isTest
    public static void newCustomPluginInstanceWithParams() 
    {
        Plugin customPlugin = new AType(CustomPlugin.class);
        CustomPlugin result = (CustomPlugin)customPlugin.newInstance(new Map<String,Object>{'success'=>true});

        System.assert(result.parameterizedSuccess);
    }

    private class CustomPlugin implements Plugin 
    {
        public final Boolean defaultSuccess;
        public final Boolean parameterizedSuccess;

        public CustomPlugin() {
            this.defaultSuccess = false;
            this.parameterizedSuccess = false;
        }
        public CustomPlugin(Boolean defaultSuccess, Boolean parameterizedSuccess) {
            this.defaultSuccess = defaultSuccess;
            this.parameterizedSuccess = parameterizedSuccess;
        }

        public Type type() {
            return CustomPlugin.class;
        }
        
        public Object newInstance() {
            return new CustomPlugin(true,false);
        }

        public Object newInstance(Map<String,Object> params) {
            return new CustomPlugin(false,(Boolean)params.get('success'));
        }
    }
}