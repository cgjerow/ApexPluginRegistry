public inherited sharing virtual class PluginRegistry 
{

    @testVisible private static Map<String,PluginModule> cacheDefaults = new Map<String,PluginModule>();
    @testVisible private static PluginRegistry registryOverride;
    @testVisible private static String testCase = '';

    public static PluginRegistry newRegistry() {
        PluginRegistry registry = new PluginRegistry(cacheDefaults);
        if (registryOverride!=null)
            registry = registryOverride;
        return registry;
    }

    public static PluginRegistry newCacheOnlyRegistry() {
        PluginRegistry registry = new PluginRegistry(cacheDefaults);
        registry.finder = new CacheOnlyFinder(); 
        if (registryOverride!=null)
            registry = registryOverride;
        return registry;
    }



    protected Map<String,PluginModule> pluginCache = new Map<String,PluginModule>();
    protected Finder finder = new ConfiguredFinder(testCase);

    protected PluginRegistry() {} 
    protected PluginRegistry(Map<String,PluginModule> cacheDefaults) {
        for(String useCase : cacheDefaults.keySet()) {
            this.forceRegister(useCase, (Plugin)cacheDefaults.get(useCase));
        }
    }

    virtual public void register(String useCase, Plugin plugin) {
        if (this.pluginCache.containsKey(useCase))
            throw new AlreadyRegisteredException(new UseCase(useCase));
        this.forceRegister(useCase, plugin);
    }
    virtual public void register(String useCase, Type type) {
        this.register(useCase, new AType(type));
    }
    virtual public void register(String useCase, String typeName) {
        this.register(useCase, new AType(typeName));
    }

    virtual public void reregister(String useCase, Plugin plugin) {
        this.forceRegister(useCase, plugin);
    }
    virtual public void reregister(String useCase, Type type) {
        this.reregister(useCase, new AType(type));
    }
    virtual public void reregister(String useCase, String typeName) {
        this.reregister(useCase, new AType(typeName));
    }

    virtual public void remove(String useCase) {
        this.pluginCache.remove(useCase);
    }

    virtual public Plugin lookup(String useCase) {
        return this.lookupAll(useCase).peek();
    }

    virtual public PluginModule lookupAll(String useCase) {
        if (!this.pluginCache.containsKey(useCase))
            this.pluginCache.put(useCase, finder.load(useCase));
        return this.pluginCache.get(useCase);
    }


    protected void forceRegister(String useCase, Plugin plugin) {
        if (!(plugin instanceof PluginModule))
            plugin = new PluginModule().append(plugin);
        this.pluginCache.put(useCase, (PluginModule)plugin);
    }

    public class UseCase {
        private final String name;

        public UseCase(String name) {
            this.name = name;
        }

        public String name() {
            return this.name;
        }
    }


    public class ConfiguredFinder implements Finder 
    {
        private String testCase = '';
        public ConfiguredFinder(String testCase) {
            this.testCase = testCase;
        }

        public PluginModule load(String useCase) {
            List<Apex_Factory_Configuration__mdt> pluginConfigurations = 
            [SELECT 
                DeveloperName, 
                Apex_Class_Name__c,
                Sort_Position__c
                FROM Apex_Factory_Configuration__mdt 
                WHERE Configuration_Name__c = :useCase
                AND Test_Case__c = :testCase
                ORDER BY Sort_Position__c ASC
            ];
            if (pluginConfigurations.isEmpty()) 
                throw new NotRegisteredException(new UseCase(useCase));
            
            PluginModule plugins = new PluginModule();
            for (Apex_Factory_Configuration__mdt config : pluginConfigurations) {
                if (config.Sort_Position__c==null)
                    config.Sort_Position__c = -1;
                plugins.insertAt((Plugin)new AType(config.Apex_Class_Name__c),(Integer)config.Sort_Position__c);
            }
            return plugins;
        }
    }

    public class CacheOnlyFinder implements Finder {
        public PluginModule load(String useCase) {
            throw new NotRegisteredException(new UseCase(useCase));
        }
    }




    public class NotRegisteredException extends Exception {
        public NotRegisteredException(UseCase useCase) {
            this(String.format('Plugin for {0} cannot be found.', new List<String>{useCase.name()}));
        }
    }

    public class AlreadyRegisteredException extends Exception {
        public AlreadyRegisteredException(UseCase useCase) {
            this(String.format('A Plugin for {0} is already registered.', new List<String>{useCase.name()}));
        }
    }


    private interface Finder {
        PluginModule load(String useCase);
    }
}