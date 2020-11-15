public inherited sharing class PluginModule implements Plugin
{
    private List<SortablePlugin> plugins = new List<SortablePlugin>();
    private Integer position = 0;
    private Type listType = List<Object>.class;

    public PluginModule() {}
    public PluginModule(Type pluginType) {
        this.setType(pluginType);
    }

    public PluginModule append(Plugin plugin) {
        this.plugins.add(new SortablePlugin(plugin,position));
        position++;
        return this;
    }

    public PluginModule insertAt(Plugin plugin, Integer position) {
        this.plugins.add(new SortablePlugin(plugin,position));
        if (this.position < position+1)
            this.position = position+1;
        return this;
    }

    public Type type() {
        return this.listType;
    }
    public PluginModule setType(Type pluginType) {
        this.listType = Type.forName('List<'+pluginType.toString()+'>');
        return this;
    }


    virtual public Plugin peek() {
        this.plugins.sort();
        return plugins[0];
    }

    virtual public Object newInstance() {
        this.plugins.sort();
        List<Object> results = this.newTypedList();
        for (Plugin plugin : plugins)
            results.add(plugin.newInstance());
        return results;
    }

    virtual public Object newInstance(Map<String,Object> params) {
        this.plugins.sort();
        List<Object> results = this.newTypedList();
        for (Plugin plugin : plugins)
            results.add(plugin.newInstance(params));
        return results;
    }

    private List<Object> newTypedList() {
        return (List<Object>)this.listType.newInstance();
    }



    public class SortablePlugin implements Plugin, Comparable
    {
        private final Integer position;
        private final Plugin plugin;

        public SortablePlugin(Plugin plugin, Integer position) {
            this.plugin = plugin;
            this.position = position;
        }

        public Integer compareTo(Object toCompare) {
            Integer result;
            if (!(toCompare instanceof SortablePlugin))
                result = 1;
            else
                result = this.position - ((SortablePlugin)toCompare).position;

            Boolean haveSamePosition = result==0;
            if (haveSamePosition)
                result = new AType(this.type()).compareTo(new AType(((Plugin)toCompare).type()));
            
            return result;
        }

        public Type type() {
            return this.plugin.type();
        }

        public Object newInstance() {
            return this.plugin.newInstance();
        }

        public Object newInstance(Map<String,Object> params) {
            return this.plugin.newInstance(params);
        }
    }
}