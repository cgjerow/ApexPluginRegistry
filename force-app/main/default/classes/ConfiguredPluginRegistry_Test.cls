@isTest
public class ConfiguredPluginRegistry_Test 
{
    private static final String useCase = 'PluginRegistryTest';
    
    @isTest
    public static void pluginNotFound()
    {
        Integer failures = 0;
        try {
            new ConfiguredPluginRegistry().lookup(useCase);
        } catch(PluginRegistry.NotRegisteredException e) { failures++; }

        System.assertEquals(1, failures);
    }

    @isTest
    public static void pluginFound()
    {
        ConfiguredPluginRegistry.testCase = 'Pass';
        Plugin plugin = new ConfiguredPluginRegistry().lookup(useCase);

        System.assertEquals(ConfiguredPluginRegistry_Test.class, plugin.type());
    }

    @isTest
    public static void multipleRegistrationsFound()
    {
        ConfiguredPluginRegistry.testCase = 'MultipleRegistrations';

        Exception failure;
        try { 
            Plugin plugin = new ConfiguredPluginRegistry().lookup(useCase);
        } catch(PluginRegistry.MultipleRegistrationsException e) {
            failure = e;
        }

        System.assert(failure instanceof PluginRegistry.MultipleRegistrationsException);
    }
}