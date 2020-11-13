@isTest
public class PluginRegistry_Test 
{

    private static final String useCase = 'apexTest';
    private static final Type pluginType = PluginRegistry_Test.class;

    @isTest
    public static void registerAndLookupNewPluginByTypeName() 
    {
        PluginRegistry registry = PluginRegistry.newRegistry();
        registry.register(useCase,'PluginRegistry_Test');

        Plugin result = registry.lookup(useCase);

        System.assertEquals(pluginType, result.type());
    }

    @isTest
    public static void registerAndLookupNewPluginByType() 
    {
        PluginRegistry registry = PluginRegistry.newRegistry();
        registry.register(useCase,pluginType);

        Plugin result = registry.lookup(useCase);

        System.assertEquals(pluginType, result.type());
    }

    @isTest
    public static void registerAndLookupNewPlugin() 
    {
        PluginRegistry registry = PluginRegistry.newRegistry();
        registry.register(useCase,new AType(pluginType));

        Plugin result = registry.lookup(useCase);

        System.assertEquals(pluginType, result.type());
    }

    @isTest
    public static void registerPreExistingPlugin()
    {
        defaultCache();
        PluginRegistry registry = PluginRegistry.newRegistry();

        Exception failure;
        try {
            registry.register(useCase, pluginType);
        } catch(PluginRegistry.AlreadyRegisteredException e) {
            failure = e;
        }

        System.assert(failure instanceof PluginRegistry.AlreadyRegisteredException);
    }

    @isTest
    public static void lookupUnregisteredPlugin()
    {
        PluginRegistry registry = PluginRegistry.newRegistry();

        Exception failure;
        try {
            registry.lookup('Unregistered Use Case');
        } catch(PluginRegistry.NotRegisteredException e) {
            failure = e;
        }

        System.assert(failure instanceof PluginRegistry.NotRegisteredException);
    }

    @isTest
    public static void reregisterAndLookupNewPluginByTypeName() 
    {
        PluginRegistry registry = PluginRegistry.newRegistry();
        registry.reregister(useCase,'PluginRegistry_Test');

        Plugin result = registry.lookup(useCase);

        System.assertEquals(pluginType, result.type());
    }

    @isTest
    public static void reregisterAndLookupNewPluginByType() 
    {
        PluginRegistry registry = PluginRegistry.newRegistry();
        registry.reregister(useCase,pluginType);

        Plugin result = registry.lookup(useCase);

        System.assertEquals(pluginType, result.type());
    }
    
    @isTest
    public static void reregisterPluginWithouExistingThenWithExisting()
    {
        PluginRegistry registry = PluginRegistry.newRegistry();
        registry.reregister(useCase,pluginType);
        Plugin firstResult = registry.lookup(useCase);
        registry.reregister(useCase,pluginType);
        Plugin secondResult = registry.lookup(useCase);

        System.assertEquals(pluginType, firstResult.type());
        System.assertEquals(pluginType, secondResult.type());
    }

    @isTest
    public static void removeExistingItem() 
    {
        defaultCache();
        PluginRegistry registry = PluginRegistry.newRegistry();
        registry.remove(useCase);

        Exception failure;
        try {
            registry.lookup(useCase);
        } catch(PluginRegistry.NotRegisteredException e) {
            failure = e;
        }

        System.assert(failure instanceof PluginRegistry.NotRegisteredException);
    }

    @isTest
    public static void removeNonExistentItem() 
    {
        PluginRegistry registry = PluginRegistry.newRegistry();
        try {
            registry.remove(useCase);
        } catch(Exception e) {
            System.assert(false, 'remove should not throw an exception, even if item cannot be found in registry.');
        }

        Exception failure;
        try {
            registry.lookup(useCase);
        } catch(PluginRegistry.NotRegisteredException e) {
            failure = e;
        }

        System.assert(failure instanceof PluginRegistry.NotRegisteredException);
    }

    @isTest
    public static void getConfiguredRegistry() 
    {
        PluginRegistry registry = PluginRegistry.newRegistryWithConfigurationSupport();
        System.assertNotEquals(null,registry);
    }


    @isTest
    public static void overrideNewPluginRegistries() 
    {
        PluginRegistry registry = PluginRegistry.newRegistry();
        registry.register(useCase,pluginType);
        PluginRegistry.registryOverride = registry;

        PluginRegistry newRegistry = PluginRegistry.newRegistry();
        PluginRegistry newConfiguredRegistry = PluginRegistry.newRegistryWithConfigurationSupport();

        System.assertEquals(pluginType, newRegistry.lookup(useCase).type());
        System.assertEquals(pluginType, newConfiguredRegistry.lookup(useCase).type());
    }


    @isTest
    public static void registeringInvalidTypeByStringThrowsInvalidArgumentExceptionOnEvaluation()
    {
        PluginRegistry registry = PluginRegistry.newRegistry();
        registry.register(useCase, 'THIS IS AN INVALID TYPE');
        Plugin pluginFromString = registry.lookup(useCase);

        Exception failure;
        try {
            Type result = pluginFromString.type();
        } catch(Exception e) {
            failure = e;
        }

        System.assert(failure instanceof IllegalArgumentException);
        System.assert(!(failure instanceof NullPointerException));
    }

    private static void defaultCache() 
    {
        PluginRegistry.cacheDefaults = new Map<String,Plugin> {useCase => new AType(pluginType)};
    }
}