@isTest
public class PluginRegistry_Test 
{

    private static final Type pluginType = PluginRegistry_Test.class;
    private static final String useCase = 'PluginRegistryTest';
    
    @isTest
    public static void configuredPluginNotFound()
    {
        Integer failures = 0;
        try {
            PluginRegistry.newRegistry().lookup(useCase);
        } catch(PluginRegistry.NotRegisteredException e) { failures++; }

        System.assertEquals(1, failures);
    }

    @isTest
    public static void configuredPluginFound()
    {
        PluginRegistry.testCase = 'Pass';
        Plugin plugin = PluginRegistry.newRegistry().lookup(useCase);

        System.assertEquals(PluginRegistry_Test.class, plugin.type());
    }

    @isTest
    public static void registerAndLookupNewPluginByTypeName() 
    {
        PluginRegistry registry = PluginRegistry.newCacheOnlyRegistry();
        registry.register(useCase,'PluginRegistry_Test');

        Plugin result = registry.lookup(useCase);

        System.assertEquals(pluginType, result.type());
    }

    @isTest
    public static void registerAndLookupNewPluginByType() 
    {
        PluginRegistry registry = PluginRegistry.newCacheOnlyRegistry();
        registry.register(useCase,pluginType);

        Plugin result = registry.lookup(useCase);

        System.assertEquals(pluginType, result.type());
    }

    @isTest
    public static void registerAndLookupNewPlugin() 
    {
        PluginRegistry registry = PluginRegistry.newCacheOnlyRegistry();
        registry.register(useCase,new AType(pluginType));

        Plugin result = registry.lookup(useCase);

        System.assertEquals(pluginType, result.type());
    }

    @isTest
    public static void registerPreExistingPlugin()
    {
        defaultCache();
        PluginRegistry registry = PluginRegistry.newCacheOnlyRegistry();

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
        PluginRegistry registry = PluginRegistry.newCacheOnlyRegistry();

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
        PluginRegistry registry = PluginRegistry.newCacheOnlyRegistry();
        registry.reregister(useCase,'PluginRegistry_Test');

        Plugin result = registry.lookup(useCase);

        System.assertEquals(pluginType, result.type());
    }

    @isTest
    public static void reregisterAndLookupNewPluginByType() 
    {
        PluginRegistry registry = PluginRegistry.newCacheOnlyRegistry();
        registry.reregister(useCase,pluginType);

        Plugin result = registry.lookup(useCase);

        System.assertEquals(pluginType, result.type());
    }
    
    @isTest
    public static void reregisterPluginWithouExistingThenWithExisting()
    {
        PluginRegistry registry = PluginRegistry.newCacheOnlyRegistry();
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
        PluginRegistry registry = PluginRegistry.newCacheOnlyRegistry();
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
        PluginRegistry registry = PluginRegistry.newCacheOnlyRegistry();
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
        PluginRegistry registry = PluginRegistry.newRegistry();
        System.assertNotEquals(null,registry);
    }


    @isTest
    public static void overrideNewPluginRegistries() 
    {
        PluginRegistry registry = PluginRegistry.newCacheOnlyRegistry();
        registry.register(useCase,pluginType);
        PluginRegistry.registryOverride = registry;

        PluginRegistry newCacheOnlyRegistry = PluginRegistry.newCacheOnlyRegistry();
        PluginRegistry newConfiguredRegistry = PluginRegistry.newRegistry();

        System.assertEquals(pluginType, newCacheOnlyRegistry.lookup(useCase).type());
        System.assertEquals(pluginType, newConfiguredRegistry.lookup(useCase).type());
    }


    @isTest
    public static void registeringInvalidTypeByStringThrowsInvalidArgumentExceptionOnEvaluation()
    {
        PluginRegistry registry = PluginRegistry.newCacheOnlyRegistry();
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


    @isTest
    public static void lookupAll() 
    {
        PluginRegistry registry = PluginRegistry.newRegistry();
        registry.register(useCase, new PluginModule(PluginRegistry_Test.class)
            .append(new AType(PluginRegistry_Test.class))
            .append(new AType(PluginRegistry_Test.class))
        );

        List<PluginRegistry_Test> results = (List<PluginRegistry_Test>)registry.lookupAll(useCase).newInstance();
        System.assertEquals(2,results.size());
    }

    @isTest
    public static void lookupAllOrdersPluginsBySortPositionWithNullsAtTheEnd()
    {
        PluginRegistry.testCase = 'MultipleRegistrations';
        PluginRegistry registry = PluginRegistry.newRegistry();

        List<Object> results = (List<Object>)registry.lookupAll(useCase).newInstance();
        System.assertEquals(3,results.size());
        System.assert(results[0] instanceof One);
        System.assert(results[1] instanceof Two);
        System.assert(results[2] instanceof Three);
    }

    @isTest
    public static void loadAll()
    {
        PluginRegistry.testCase = 'MultipleRegistrations';
        PluginRegistry registry = PluginRegistry.newRegistry();

        Map<String,PluginModule> modules = registry.loadAll();
        System.assert(modules.containsKey(useCase));
        System.assertEquals(1,modules.size());

        List<Object> plugins = (List<Object>)modules.get(useCase).newInstance();
        System.assertEquals(3,plugins.size());
    }

    private static void defaultCache() 
    {
        PluginRegistry.cacheDefaults = new Map<String,PluginModule> {useCase => new PluginModule().append((Plugin)new AType(pluginType)) };
    }

    public class One {}
    public class Two {}
    public class Three {}
}