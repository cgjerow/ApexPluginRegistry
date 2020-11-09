public inherited sharing virtual class ApexPlugin implements Plugin 
{
    private final String className;
    private Boolean hasInvalidType = false;
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

    public ApexPlugin(Type classType) {
        this.apexType = classType;
    }
    public ApexPlugin(String className) {
        this.className = className;
    }

    public virtual Type type() {
        return this.apexType;
    }

    public virtual Object newInstance() {
        return this.apexType.newInstance();
    }

    // Sub classes may override this to allow for parameter base instantiations
    public virtual Object newInstance(Map<String,Object> params) {
        return this.apexType.newInstance();
    }
}