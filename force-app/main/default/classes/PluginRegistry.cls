public inherited sharing virtual class PluginRegistry 
{

    @testVisible private static Map<String,Plugin> cacheDefaults = new Map<String,Plugin>();
    @testVisible private static PluginRegistry registryOverride;

    public static PluginRegistry newRegistryWithConfigurationSupport() {
        PluginRegistry registry = new ConfiguredPluginRegistry(cacheDefaults);
        if (registryOverride!=null)
            registry = registryOverride;
        return registry;
    }

    public static PluginRegistry newRegistry() {
        PluginRegistry registry = new PluginRegistry(cacheDefaults);
        if (registryOverride!=null)
            registry = registryOverride;
        return registry;
    }



    protected Boolean configurationRegistryEnabled = true;
    protected Map<String,Plugin> pluginCache = new Map<String,Plugin>();

    protected PluginRegistry() {} 
    protected PluginRegistry(Map<String,Plugin> cacheDefaults) {
        for(String useCase : cacheDefaults.keySet()) {
            this.forceRegister(useCase, cacheDefaults.get(useCase));
        }
    }

    virtual public void register(String useCase, Plugin plugin) {
        if (this.pluginCache.containsKey(useCase))
            throw new AlreadyRegisteredException(new UseCase(useCase));
        this.forceRegister(useCase,plugin);
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
        if (!this.pluginCache.containsKey(useCase))
            throw new NotRegisteredException(new UseCase(useCase));
        return this.pluginCache.get(useCase);
    }

    protected void forceRegister(String useCase, Plugin plugin) {
        this.pluginCache.put(useCase, plugin);
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
}