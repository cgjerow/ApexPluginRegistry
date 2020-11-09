public inherited sharing class ConfiguredPluginRegistry extends PluginRegistry 
{
    @testVisible
    private static String testCase = '';

    public ConfiguredPluginRegistry() {
        super();
    }
    public ConfiguredPluginRegistry(Map<String, Type> cacheDefaults) {
        super(cacheDefaults);
    }

    override public Plugin lookup(String useCase) {
        try {
            if (!this.pluginCache.containsKey(useCase)) {
                this.forceRegister(
                    useCase, 
                    [SELECT 
                        DeveloperName, 
                        Apex_Class_Name__c 
                        FROM Apex_Factory_Configuration__mdt 
                        WHERE Configuration_Name__c = :useCase
                        AND Test_Case__c = :testCase
                    ].Apex_Class_Name__c
                );
            }
            return this.pluginCache.get(useCase);
        }
        catch(Exception e) {
            throw new NotRegisteredException(new UseCase(useCase));
        }
    }
}