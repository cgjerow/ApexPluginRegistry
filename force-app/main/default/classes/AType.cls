public inherited sharing class AType implements Plugin 
{
    private final String className;
    private Boolean hasInvalidType = false;
    private Boolean isPlugin {
        get { return Plugin.class.isAssignableFrom(this.apexType); }
    }
    private Type apexType {
        get {
            if (this.apexType==null && !this.hasInvalidType) {
                this.apexType = Type.forName(this.className);
                hasInvalidType = this.apexType==null;
            }
            if (this.hasInvalidType) {
                throw new IllegalArgumentException('Invalid Apex Type for plugin: '+this.className);
            }
            return this.apexType;
        }
        set;
    }

    public AType(Type classType) {
        this.apexType = classType;
    }
    public AType(String className) {
        this.className = className;
    }

    public virtual Type type() {
        return this.apexType;
    }


    // For both newInstance calls we check if the inner type is itself a Plugin,
    // so that we can delegate down to custom newInstance methods for those classes.
    // This still requires that these custom Plugins have a default constructor.

    public virtual Object newInstance() {
        Object result = this.apexType.newInstance();
        if (this.isPlugin)
            result = ((Plugin)result).newInstance();
        return result;    
    }

    public virtual Object newInstance(Map<String,Object> params) {
        Object result = this.apexType.newInstance();
        if (this.isPlugin)
            result = ((Plugin)result).newInstance(params);
        return result;
    }
}