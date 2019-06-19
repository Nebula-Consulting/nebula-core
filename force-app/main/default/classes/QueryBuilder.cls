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
    private String orderByClause;
    private String paginationClause;

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

    global QueryBuilder addFields(Set<String> fields) {
        for(String f : fields) {
            this.fieldsLowerCase.add(f.toLowerCase());
        }
        return this;
    }

    global String getQuery() {

        // Set<T> does not implement Iterable<T>, see https://success.salesforce.com/ideaView?id=08730000000kxLyAAI
        String selectFields = String.join(new List<String>(fieldsLowerCase), ', ');

        String theQuery = 'SELECT ' + selectFields + ' '
                + 'FROM ' + typeName + ' '
                + 'WHERE ' + whereClause;

        if(orderByClause != null) {
            theQuery += ' ORDER BY ' + orderByClause;
        }

        if(paginationClause != null) {
            theQuery += ' ' + paginationClause;
        }

        return theQuery;
    }
}