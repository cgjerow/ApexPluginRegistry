public interface Plugin { // ideally this would be generic Plugin<T>
    Type type();
    Object newInstance();
    Object newInstance(Map<String,Object> params);
}