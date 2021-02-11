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

    global QueryBuilder(SObjectType sObjectType) {
        this(sObjectType.getDescribe().getName());
    }

    global QueryBuilder(String typeName) {
        this.typeName = typeName;
        this.fieldsLowerCase = new Set<String>{'id'};
    }

    global QueryBuilder addFieldSet(String fieldSetName) {
        List<FieldSetMember> fieldsetMembers = DescribeCache.getFieldSet(typeName, fieldSetName).getFields();
        for(Schema.FieldSetMember thisField : fieldsetMembers) {
            fieldsLowerCase.add(thisField.getFieldPath().toLowerCase());
        }
        return this;
    }

    global QueryBuilder addAllFields(BooleanFunction fieldFilter) {
        List<SObjectField> allFields = ((SObject)Type.forName(typeName).newInstance()).getSObjectType().getDescribe().fields.getMap().values();
        for(SObjectField f : allFields) {
            if(fieldFilter.isTrueFor(f)) {
                fieldsLowerCase.add(f.getDescribe().getName().toLowerCase());
            }
        }
        return this;
    }

    global QueryBuilder addAllFields() {
        return addAllFields(new ConstantFunction(true));
    }

    global QueryBuilder setOrderByClause(String orderByClause) {
        this.orderByClause = orderByClause;
        return this;
    }

    global QueryBuilder setPaginationClause(String paginationClause) {
        this.paginationClause = paginationClause;
        return this;
    }

    global QueryBuilder setWhereClause(String whereClause) {
        this.whereClause = whereClause;
        return this;
    }

    global QueryBuilder addField(String field) {
        fieldsLowerCase.add(field.toLowerCase());
        return this;
    }

    global QueryBuilder addField(SObjectField field) {
        fieldsLowerCase.add(field.getDescribe().getName().toLowerCase());
        return this;
    }

    global QueryBuilder addFields(Set<String> fields) {
        for(String f : fields) {
            addField(f);
        }
        return this;
    }

    global QueryBuilder addFields(List<String> fields) {
        for(String f : fields) {
            addField(f);
        }
        return this;
    }

    global QueryBuilder addFields(Set<SObjectField> fields) {
        for(SObjectField f : fields) {
            addField(f);
        }
        return this;
    }

    global QueryBuilder addFields(List<SObjectField> fields) {
        for(SObjectField f : fields) {
            addField(f);
        }
        return this;
    }

    global QueryBuilder addSubQuery(QueryBuilder subQuery) {
        subQueries.add(subQuery);
        return this;
    }

    global QueryBuilder withSecurityEnforced() {
        withSecurityEnforced = true;
        return this;
    }

    global String getQuery() {

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

        if(orderByClause != null) {
            theQuery += ' ORDER BY ' + orderByClause;
        }

        if(paginationClause != null) {
            theQuery += ' ' + paginationClause;
        }

        return theQuery;
    }
}