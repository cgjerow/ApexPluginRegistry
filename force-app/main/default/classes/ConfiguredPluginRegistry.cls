public inherited sharing class ConfiguredPluginRegistry extends PluginRegistry 
{
    @testVisible
    private static String testCase = '';

    public ConfiguredPluginRegistry() {
        super();
    }
    public ConfiguredPluginRegistry(Map<String, Plugin> cacheDefaults) {
        super(cacheDefaults);
    }

    override public Plugin lookup(String useCase) {
        if (!this.pluginCache.containsKey(useCase)) {
            loadConfiguration(useCase);
        }
        return this.pluginCache.get(useCase);
    }

    private void loadConfiguration(String useCase) {
        List<Apex_Factory_Configuration__mdt> pluginConfigurations = 
        [SELECT 
            DeveloperName, 
            Apex_Class_Name__c 
            FROM Apex_Factory_Configuration__mdt 
            WHERE Configuration_Name__c = :useCase
            AND Test_Case__c = :testCase
        ];
        if (pluginConfigurations.isEmpty()) 
            throw new NotRegisteredException(new UseCase(useCase));
        else if (pluginConfigurations.size()>1)
            throw new MultipleRegistrationsException(new UseCase(useCase));
 
        this.reregister(
            useCase, 
            pluginConfigurations[0].Apex_Class_Name__c
        );
    }
}