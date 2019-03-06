from pyspark.sql import functions as fn
from matrix_ops import matrix_dot_vector, vector_times_scalar, vector_plus_vector, vector_sub_vector
from matrix_ops2 import matrix_dot_vector_update
from pyspark.storagelevel import StorageLevel

__all__ = ['pagerank_compute_init_rho_transitions', 'pagerank_estimate_datarank']

def pagerank_compute_init_rho_transitions(vertices, edges, initial_value, data_damping_factor, pub_damping_factor, data_size, pub_size):
    """given initial value and Compute the distribution rho and transitions"""
    init = vertices.select('i', fn.lit(initial_value).alias('value')) 
    distribution = fn.lit((1-data_damping_factor)/data_size) + fn.lit((1-pub_damping_factor)/pub_size)
    rho = vertices.select('i', distribution.alias('value'))  

    cal_out = edges.groupBy('i').count().join(edges, 'i').selectExpr('j as i', 'i as j', 'type', '1/count as out_degree')
    damping_value = fn.when(fn.col('type') == 'data', fn.col('out_degree') * data_damping_factor).\
                    otherwise(fn.col('out_degree') * pub_damping_factor)
    transitions = cal_out.select('i', 'j', 'type', 'out_degree', damping_value.alias('value')) 
    return  init, rho, transitions


def pagerank_estimate_datarank(init, rho, transitions, tol=0.01, max_iter=100, checkpoint_interval=10, verbose=False):
    """Estimate datarank based on initial distribution `rho` and transition matrix `M`"""
    rho.persist(StorageLevel.MEMORY_ONLY)
    transitions.persist(StorageLevel.MEMORY_ONLY)
    datarank = init
    current_transitions = transitions
    min_term = rho
    for i in range(1, max_iter + 1):
        rho_forward = matrix_dot_vector_update(current_transitions, datarank)
        new_datarank = vector_plus_vector(min_term, rho_forward)
        if i % checkpoint_interval == 0:
            new_datarank = new_datarank.persist(StorageLevel.MEMORY_ONLY)
            
        if i % checkpoint_interval == 0:
            new_datarank.write.parquet("/user/feng/projects/datarank/geneBank/openCitation/result_data_pub/break_point/datarank_cache" ,mode="overwrite")
            
        diff = vector_sub_vector(new_datarank, datarank).selectExpr('sum(abs(value)) as diff').first().diff
        if verbose:
            print("Iteration {}: diff = {}".format(i, diff))
        datarank = new_datarank
        if diff < tol:
            break

    rho.unpersist()
    transitions.unpersist()
    new_datarank.unpersist()
    return datarank
