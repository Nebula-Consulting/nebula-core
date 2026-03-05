/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 2019-03-05
 * @description Simplifies making dynamic queries by handling FieldSets, and sorting out sets of fields to remove 
 * duplicates
 */
global inherited sharing class QueryBuilder {

    private String typeName;
    private String whereClause;

    private Set<String> fieldsLowerCase;
    private List<QueryBuilder> subQueries = new List<QueryBuilder>();
    private String orderByClause;
    private String paginationClause;
    private Boolean withSecurityEnforced = false;
    private String groupBy;

    /**
     * @description Creates a QueryBuilder for the specified SObjectType
     * @param sObjectType The SObjectType to query
     */
    global QueryBuilder(SObjectType sObjectType) {
        this(sObjectType.getDescribe().getName());
    }

    /**
     * @description Creates a QueryBuilder for the specified SObject type name
     * @param typeName The API name of the SObject type
     */
    global QueryBuilder(String typeName) {
        this.typeName = typeName;
        this.fieldsLowerCase = new Set<String>();
    }

    /**
     * @description Adds all fields from a field set to the query
     * @param fieldSetName The API name of the field set
     * @return This QueryBuilder instance for method chaining
     */
    global QueryBuilder addFieldSet(String fieldSetName) {
        List<FieldSetMember> fieldsetMembers = DescribeCache.getFieldSet(typeName, fieldSetName).getFields();
        for(Schema.FieldSetMember thisField : fieldsetMembers) {
            fieldsLowerCase.add(thisField.getFieldPath().toLowerCase());
        }
        return this;
    }

    /**
     * @description Adds all fields from the object that match the filter
     * @param fieldFilter BooleanFunction to determine which fields to include
     * @return This QueryBuilder instance for method chaining
     */
    global QueryBuilder addAllFields(BooleanFunction fieldFilter) {
        List<SObjectField> allFields = DescribeCache.describeSObject(typeName).fields.getMap().values();
        for(SObjectField f : allFields) {
            if(fieldFilter.isTrueFor(f)) {
                fieldsLowerCase.add(f.getDescribe().getName().toLowerCase());
            }
        }
        return this;
    }

    /**
     * @description Adds all fields from the object to the query
     * @return This QueryBuilder instance for method chaining
     */
    global QueryBuilder addAllFields() {
        return addAllFields(new ConstantFunction(true));
    }

    /**
     * @description Sets the ORDER BY clause for the query
     * @param orderByClause The ORDER BY clause (e.g., 'Name ASC, CreatedDate DESC')
     * @return This QueryBuilder instance for method chaining
     */
    global QueryBuilder setOrderByClause(String orderByClause) {
        this.orderByClause = orderByClause;
        return this;
    }

    /**
     * @description Sets the pagination clause for the query (LIMIT and/or OFFSET)
     * @param paginationClause The pagination clause (e.g., 'LIMIT 100', 'LIMIT 10 OFFSET 20')
     * @return This QueryBuilder instance for method chaining
     */
    global QueryBuilder setPaginationClause(String paginationClause) {
        this.paginationClause = paginationClause;
        return this;
    }

    /**
     * @description Sets the GROUP BY field for the query
     * @param field The SObjectField to group by
     * @return This QueryBuilder instance for method chaining
     */
    global QueryBuilder groupBy(SObjectField field) {
        this.groupBy = field.getDescribe().name;
        return this;
    }

    /**
     * @description Sets the GROUP BY clause for the query
     * @param groupBy The GROUP BY clause (field name or expression)
     * @return This QueryBuilder instance for method chaining
     */
    global QueryBuilder groupBy(String groupBy) {
        this.groupBy = groupBy;
        return this;
    }

    /**
     * @description Sets the WHERE clause for the query
     * @param whereClause The WHERE clause (without the WHERE keyword)
     * @return This QueryBuilder instance for method chaining
     */
    global QueryBuilder setWhereClause(String whereClause) {
        this.whereClause = whereClause;
        return this;
    }

    /**
     * @description Adds a field to the query by field name
     * @param field The field API name as a string
     * @return This QueryBuilder instance for method chaining
     */
    global QueryBuilder addField(String field) {
        fieldsLowerCase.add(field.toLowerCase());
        return this;
    }

    /**
     * @description Adds a field to the query by SObjectField token
     * @param field The SObjectField to add
     * @return This QueryBuilder instance for method chaining
     */
    global QueryBuilder addField(SObjectField field) {
        fieldsLowerCase.add(field.getDescribe().getName().toLowerCase());
        return this;
    }

    /**
     * @description Adds multiple fields to the query from a set of field names
     * @param fields Set of field API names
     * @return This QueryBuilder instance for method chaining
     */
    global QueryBuilder addFields(Set<String> fields) {
        for(String f : fields) {
            addField(f);
        }
        return this;
    }

    /**
     * @description Adds multiple fields to the query from a list of field names
     * @param fields List of field API names
     * @return This QueryBuilder instance for method chaining
     */
    global QueryBuilder addFields(List<String> fields) {
        for(String f : fields) {
            addField(f);
        }
        return this;
    }

    /**
     * @description Adds multiple fields to the query from a set of SObjectField tokens
     * @param fields Set of SObjectFields
     * @return This QueryBuilder instance for method chaining
     */
    global QueryBuilder addFields(Set<SObjectField> fields) {
        for(SObjectField f : fields) {
            addField(f);
        }
        return this;
    }

    /**
     * @description Adds multiple fields to the query from a list of SObjectField tokens
     * @param fields List of SObjectFields
     * @return This QueryBuilder instance for method chaining
     */
    global QueryBuilder addFields(List<SObjectField> fields) {
        for(SObjectField f : fields) {
            addField(f);
        }
        return this;
    }

    /**
     * @description Adds multiple fields to the query from an iterator of Strings or SObjectFields
     * @param stringOrFieldIterator Iterator containing String field names or SObjectField tokens
     * @return This QueryBuilder instance for method chaining
     */
    global QueryBuilder addFields(Iterator<Object> stringOrFieldIterator) {
        while(stringOrFieldIterator.hasNext()) {
            Object stringOrField = stringOrFieldIterator.next();
            if(stringOrField instanceof String) {
                addField((String)stringOrField);
            } else {
                addField((SObjectField)stringOrField);
            }
        }
        return this;
    }

    /**
     * @description Adds a subquery to the main query
     * @param subQuery QueryBuilder representing the subquery
     * @return This QueryBuilder instance for method chaining
     */
    global QueryBuilder addSubQuery(QueryBuilder subQuery) {
        subQueries.add(subQuery);
        return this;
    }

    /**
     * @description Adds WITH SECURITY_ENFORCED to the query for field-level security enforcement
     * @return This QueryBuilder instance for method chaining
     */
    global QueryBuilder withSecurityEnforced() {
        withSecurityEnforced = true;
        return this;
    }

    /**
     * @description Generates the final SOQL query string
     * @return The complete SOQL query
     */
    global String getQuery() {

        if(fieldsLowerCase.isEmpty()) {
            fieldsLowerCase.add('id');
        }

        for(QueryBuilder thisSubQuery : subQueries) {
            fieldsLowerCase.add('(' + thisSubQuery.getQuery() + ')');
        }

        // Set<T> does not implement Iterable<T>, see https://success.salesforce.com/ideaView?id=08730000000kxLyAAI
        String selectFields = String.join(new List<String>(fieldsLowerCase), ', ');

        String theQuery = 'SELECT ' + selectFields + ' '
                + 'FROM ' + typeName;

        if(whereClause != null) {
            theQuery += ' WHERE ' + whereClause;
        }

        if(withSecurityEnforced) {
            theQuery += ' WITH SECURITY_ENFORCED';
        }

        if(groupBy != null) {
            theQuery += ' GROUP BY ' + groupBy;
        }

        if(orderByClause != null) {
            theQuery += ' ORDER BY ' + orderByClause;
        }

        if(paginationClause != null) {
            theQuery += ' ' + paginationClause;
        }

        return theQuery;
    }
}