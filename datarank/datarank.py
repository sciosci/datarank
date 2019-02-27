from pyspark.sql import functions as fn
#from .matrix_ops import matrix_dot_vector, vector_times_scalar, vector_plus_vector, vector_sub_vector
from matrix_ops import matrix_dot_vector, vector_times_scalar, vector_plus_vector, vector_sub_vector
from pyspark.storagelevel import StorageLevel

__all__ = ['compute_rho_transitions', 'estimate_datarank']


def compute_rho_transitions(vertices, edges, pub_decay_time, data_decay_time):
    """Compute the initial distribution rho and transitions"""
    distribution = fn.when(fn.col('type') == 'data', fn.exp(-fn.col('age') / fn.lit(data_decay_time))). \
        otherwise(fn.exp(-fn.col('age') / fn.lit(pub_decay_time)))
    rho = vertices.select('i', distribution.alias('value'))

    transitions = edges.groupBy('i').count().join(edges, 'i'). \
        selectExpr('j as i', 'i as j', '1/count as value')
    return rho, transitions


def estimate_datarank(rho, transitions, alpha, tol=0.01, max_iter=5, checkpoint_interval=2, verbose=False):
    """Estimate datarank based on initial distribution `rho` and transition matrix `M`"""
    rho.persist(StorageLevel.MEMORY_AND_DISK)
    transitions.persist(StorageLevel.MEMORY_AND_DISK)
    datarank = rho
    current_transitions = transitions
    current_sum_term = rho
    for i in range(1, max_iter + 1):
        rho_forward = matrix_dot_vector(current_transitions, current_sum_term)
        #current_sum_term = vector_times_scalar(rho_forward, (1 - alpha) ** i)
        current_sum_term = vector_times_scalar(rho_forward, (1 - alpha))
        new_datarank = vector_plus_vector(datarank, current_sum_term)
        if i % checkpoint_interval == 0:
            new_datarank = new_datarank.persist(StorageLevel.MEMORY_AND_DISK)
            current_sum_term = current_sum_term.persist(StorageLevel.MEMORY_AND_DISK)

        diff = vector_sub_vector(new_datarank, datarank).selectExpr('avg(value*value) as mse').first().mse
        if verbose:
            print("Iteration {}: MSE = {}".format(i, diff))
        datarank = new_datarank
        if diff < tol:
            break

    rho.unpersist()
    transitions.unpersist()
    return datarank
