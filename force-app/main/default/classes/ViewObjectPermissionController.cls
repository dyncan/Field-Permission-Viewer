public class ViewObjectPermissionController {
  // Exclude all the unwanted Sobjects e.g. History, Share etc.
  private static boolean isIgnoredObject(Schema.SObjectType objTyp) {
    String name = objTyp.getDescribe().getName();
    return name.containsIgnoreCase('history') || // Track Field History for Custom Objects
      name.containsIgnoreCase('tag') || // Salesforce Tags
      name.containsIgnoreCase('share') || // Custom object sharing object
      name.containsIgnoreCase('feed'); // Article Type Feed or Custom Object Feed
  }

  // Retrieve a list of all objects contained in the organization
  @Auraenabled(cacheable=true)
  public static List<string> getObjects() {
    List<string> sObjectList = new List<string>();

    for (Schema.SObjectType objTyp : Schema.getGlobalDescribe().Values()) {
      String name = objTyp.getDescribe().getName();
      if (!isIgnoredObject(objTyp) && name.toLowerCase().right(3) == '__c') {
        sObjectList.add(name);
      }
    }
    return sObjectList;
  }

  // Get all fields of the given object
  @Auraenabled(cacheable=true)
  public static List<FieldWrap> getFields(string objectName) {
    Map<String, Schema.SobjectField> fieldsMap = Schema.getGlobalDescribe()
      .get(objectName)
      .getDescribe()
      .fields.getMap();
    List<FieldWrap> fieldWraps = new List<FieldWrap>();
    for (String fieldName : fieldsMap.keySet()) {
      Schema.DescribeFieldResult fieldDescribe = fieldsMap.get(fieldName)
        .getDescribe();
      fieldWraps.add(
        new FieldWrap(fieldDescribe.getName(), fieldDescribe.getLabel())
      );
    }
    return fieldWraps;
  }

  // Retrieve all active users contained in the organization
  @Auraenabled(cacheable=true)
  public static List<User> getOrgUsers() {
    return [SELECT id, name FROM User WHERE isactive = TRUE];
  }

  // Get all fields permissions for the given object and user
  @AuraEnabled(cacheable=true)
  public static List<FieldAccess> getObjectAccess(
    String objectName,
    String userId
  ) {
    Set<String> durableIds = new Set<String>();
    for (UserFieldAccess ufa : [
      SELECT DurableId
      FROM UserFieldAccess
      WHERE
        FieldDefinition.EntityDefinition.QualifiedApiName = :objectName // 所选对象
        AND User.Id = :userId // 所选用户
    ]) {
      durableIds.add(ufa.DurableId);
    }
    List<FieldAccess> fieldAccesses = new List<FieldAccess>();
    Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe()
      .get(objectName)
      .getDescribe()
      .fields.getMap();
    for (UserFieldAccess ufa : [
      SELECT
        Id,
        DurableId,
        EntityDefinitionId,
        FieldDefinition.QualifiedApiName,
        FieldDefinitionId,
        IsAccessible,
        IsCreatable,
        IsUpdatable
      FROM UserFieldAccess
      WHERE DurableId IN :durableIds
    ]) {
      String fieldName = ufa.FieldDefinition.QualifiedApiName;
      if (fieldsMap.containsKey(fieldName)) {
        fieldAccesses.add(
          new FieldAccess(
            ufa.Id,
            ufa.EntityDefinitionId,
            ufa.FieldDefinitionId,
            ufa.IsAccessible,
            ufa.IsCreatable,
            ufa.IsUpdatable,
            fieldName
          )
        );
      }
    }
    return fieldAccesses;
  }

  // Get the field permission for the given object, field and user
  @AuraEnabled(cacheable=true)
  public static List<FieldAccess> getFieldsAccess(
    String objectName,
    String fieldName,
    String userId
  ) {
    Set<String> durableIds = new Set<String>();
    for (UserFieldAccess ufa : [
      SELECT DurableId
      FROM UserFieldAccess
      WHERE
        FieldDefinition.EntityDefinition.QualifiedApiName = :objectName
        AND FieldDefinition.QualifiedApiName = :fieldName
        AND User.Id = :userId
    ]) {
      durableIds.add(ufa.DurableId);
    }
    List<FieldAccess> fieldAccesses = new List<FieldAccess>();
    Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe()
      .get(objectName)
      .getDescribe()
      .fields.getMap();
    for (UserFieldAccess ufa : [
      SELECT
        Id,
        DurableId,
        EntityDefinitionId,
        FieldDefinition.QualifiedApiName,
        FieldDefinitionId,
        IsAccessible,
        IsCreatable,
        IsUpdatable
      FROM UserFieldAccess
      WHERE DurableId IN :durableIds
    ]) {
      String fName = ufa.FieldDefinition.QualifiedApiName;
      if (fieldsMap.containsKey(fName)) {
        fieldAccesses.add(
          new FieldAccess(
            ufa.Id,
            ufa.EntityDefinitionId,
            ufa.FieldDefinitionId,
            ufa.IsAccessible,
            ufa.IsCreatable,
            ufa.IsUpdatable,
            fName
          )
        );
      }
    }
    return fieldAccesses;
  }

  // Classes for storing field names and labels to display on UI
  public class FieldWrap {
    @Auraenabled
    public string Name { get; set; }
    @Auraenabled
    public string Label { get; set; }

    public FieldWrap(String name, String label) {
      this.name = name;
      this.label = label;
    }
  }

  // Class for storing field access information to display on data table list
  public class FieldAccess {
    @Auraenabled
    public string Id { get; set; }
    @Auraenabled
    public string EntityDefinitionId { get; set; }
    @Auraenabled
    public string FieldDefinitionId { get; set; }
    @Auraenabled
    public boolean IsAccessible { get; set; }
    @Auraenabled
    public boolean IsUpdatable { get; set; }
    @Auraenabled
    public boolean IsCreatable { get; set; }
    @Auraenabled
    public string FieldName { get; set; }

    public FieldAccess(
      String id,
      String entityDefinitionId,
      String fieldDefinitionId,
      Boolean isAccessible,
      Boolean isCreatable,
      Boolean isUpdatable,
      String fieldName
    ) {
      this.id = id;
      this.entityDefinitionId = entityDefinitionId;
      this.fieldDefinitionId = fieldDefinitionId;
      this.isAccessible = isAccessible;
      this.isCreatable = isCreatable;
      this.isUpdatable = isUpdatable;
      this.fieldName = fieldName;
    }
  }
}
