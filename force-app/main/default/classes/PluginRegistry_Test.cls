@isTest
public class PluginRegistry_Test 
{

    private static final String useCase = 'apexTest';
    private static final Type pluginType = PluginRegistry_Test.class;

    @isTest
    public static void registerAndLookupNewPlugin() 
    {
        PluginRegistry registry = PluginRegistry.newRegistry();
        registry.register(useCase,pluginType);

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
        PluginRegistry registry = PluginRegistry.newConfiguredRegistry();
        System.assertNotEquals(null,registry);
    }


    @isTest
    public static void overrideNewPluginRegistries() 
    {
        PluginRegistry registry = PluginRegistry.newRegistry();
        registry.register(useCase,pluginType);
        PluginRegistry.registryOverride = registry;

        PluginRegistry newRegistry = PluginRegistry.newRegistry();
        PluginRegistry newConfiguredRegistry = PluginRegistry.newConfiguredRegistry();

        System.assertEquals(pluginType, newRegistry.lookup(useCase).type());
        System.assertEquals(pluginType, newConfiguredRegistry.lookup(useCase).type());
    }

    private static void defaultCache() 
    {
        PluginRegistry.cacheDefaults = new Map<String,Type> {useCase => pluginType};
    }
}