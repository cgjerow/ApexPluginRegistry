@isTest
public class PluginModule_Test 
{

    @isTest
    public static void newInstanceReturnsTypedList()
    {
        Object result = new PluginModule(CustomPlugin.class).newInstance();
        
        System.assert(result instanceof List<CustomPlugin>);
    }

    @isTest
    public static void appendTwoPlugins() 
    {
        PluginModule plugins = new PluginModule(CustomPlugin.class)
            .append(new CustomPlugin('One'))
            .append(new CustomPlugin('Two'));

        List<CustomPlugin> results = (List<CustomPlugin>)plugins.newInstance();

        System.assertEquals(2, results.size());
        System.assertEquals('One',results[0].name);
        System.assertEquals('Two',results[1].name);
    }

    @isTest
    public static void delegateParamsInNewInstance()
    {
        PluginModule plugins = new PluginModule(CustomPlugin.class)
            .append(new CustomPlugin('Overriden Name'));
        
        List<CustomPlugin> results = (List<CustomPlugin>)plugins.newInstance(new Map<String,Object>{'name'=>'Actual Name'});

        System.assertEquals(1, results.size());
        System.assertEquals('Actual Name',results[0].name);
    }

    @isTest
    public static void manuallySetPosition()
    {
        PluginModule plugins = new PluginModule(CustomPlugin.class)
            .insertAt(new CustomPlugin('One'),2)
            .insertAt(new CustomPlugin('Two'),0);
        
        List<CustomPlugin> results = (List<CustomPlugin>)plugins.newInstance();

        System.assertEquals(2, results.size());
        System.assertEquals('Two',results[0].name);
        System.assertEquals('One',results[1].name); 
    }

    @isTest
    public static void positionalSortingConflictsResolvedByTypeComparison()
    {
        PluginModule plugins = new PluginModule(CustomPlugin.class)
            .insertAt(new ZZCustomPlugin('One'),0)
            .insertAt(new CustomPlugin('Two'),0);
        
        List<CustomPlugin> results = (List<CustomPlugin>)plugins.newInstance();

        System.assertEquals(2, results.size());
        System.assertEquals('Two',results[0].name);
        System.assertEquals('One',results[1].name); 
    }

    @isTest
    public static void pluginsAreAppendedAfterManuallyPositionedPlugins()
    {
        PluginModule plugins = new PluginModule(CustomPlugin.class)
            .insertAt(new CustomPlugin('One'),2)
            .append(new CustomPlugin('Two'));
        
        List<CustomPlugin> results = (List<CustomPlugin>)plugins.newInstance();

        System.assertEquals(2, results.size());
        System.assertEquals('One',results[0].name);
        System.assertEquals('Two',results[1].name); 
    }

    @isTest
    public static void pluginsAppendedAtEndEvenIfPluginManuallyPositionedAheadOfOthers()
    {
        PluginModule plugins = new PluginModule(CustomPlugin.class)
            .append(new CustomPlugin('One'))
            .append(new CustomPlugin('Two'))
            .append(new CustomPlugin('Three'))
            .insertAt(new CustomPlugin('Four'),0)
            .append(new CustomPlugin('Five'));
        
        List<CustomPlugin> results = (List<CustomPlugin>)plugins.newInstance();

        System.assertEquals(5, results.size());
        System.assertEquals('Five',results[4].name);
    }

    @isTest
    public static void peek()
    {
        Plugin result = new PluginModule(CustomPlugin.class).append(new CustomPlugin('One')).peek();
        System.assertEquals('One',((CustomPlugin)result.newInstance()).name);
    }

    @isTest
    public static void peekReturnsSortedFirstElement()
    {
        Plugin result = new PluginModule(CustomPlugin.class)
            .insertAt(new CustomPlugin('One'),2)
            .insertAt(new CustomPlugin('Two'),0)
            .peek();
        System.assertEquals('Two',((CustomPlugin)result.newInstance()).name);
    }

    @isTest
    public static void moduleCanUseInterfaceAsType() 
    {
        PluginModule module = new PluginModule(DoesWork.class).append(new AType(Worker.class));
        List<DoesWork> results = (List<DoesWork>)module.newInstance();
        System.assertEquals(1,results.size());
        System.assert(results[0] instanceof Worker);
    }

    @isTest
    public static void setType() 
    {
        PluginModule module = new PluginModule();
        module.setType(DoesWork.class);
        System.assertEquals(List<DoesWork>.class, module.type());
    }

    @isTest
    public static void setTypeThenNewInstanceReturnsTypedListWithNewType() 
    {
        PluginModule module = new PluginModule().append(new AType(Worker.class));
        module.setType(DoesWork.class);
        List<DoesWork> results = (List<DoesWork>)module.newInstance();
        System.assertEquals(1,results.size());
        System.assert(results[0] instanceof Worker);
    }

    public virtual class CustomPlugin implements Plugin 
    {
        public String name;
        public CustomPlugin(){}
        public CustomPlugin(String name) {
            this.name = name;
        }

        virtual public Type type() {
            return CustomPlugin.class;
        }
        
        public Object newInstance() {
            return new CustomPlugin(this.name);
        }

        public Object newInstance(Map<String,Object> params) {
            return new CustomPlugin((String)params.get('name'));
        }
    }

    @isTest
    public static void compareSortablePluginToOtherTypeReturnsGreater() 
    {
        Integer result = new PluginModule.SortablePlugin(new CustomPlugin(),0).compareTo(new Worker());
        System.assert(result > 0);
    }

    public class ZZCustomPlugin extends CustomPlugin
    {
        public ZZCustomPlugin(String name) {
            super(name);
        }

        override public Type type() {
            return ZZCustomPlugin.class;
        }
    }

    public interface DoesWork {}
    public class Worker implements DoesWork {}
}