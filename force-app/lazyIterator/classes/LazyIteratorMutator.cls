/**
 * @author aidan@nebulaconsulting.co.uk
 * @date 11/12/2019
 * @description A marker interface to identify derivatives of LazyIterator which mutate data as it passes through.
 * Examples include LazyMappingIterator and LazyFilterIterator. Counter-examples include LazySObjectIterator, which only
 * exists to navigate the type-conversions.
 */

public interface LazyIteratorMutator {

}