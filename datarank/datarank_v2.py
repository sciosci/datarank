from pyspark.sql import functions as fn
from matrix_ops import matrix_dot_vector, vector_times_scalar, vector_plus_vector, vector_sub_vector
from pyspark.storagelevel import StorageLevel

__all__ = ['compute_rho_transitions_bf', 'estimate_datarank']


def compute_rho_transitions_bf(vertices, edges, pub_decay_time, data_decay_time):
    """Compute the initial distribution rho and transitions"""
    distribution = fn.when(fn.col('type') == 'data', fn.exp(-fn.col('age') / fn.lit(data_decay_time))). \
        otherwise(fn.exp(-fn.col('age') / fn.lit(pub_decay_time)))
    rho = vertices.select('i', distribution.alias('value'))

    transitions_out = edges.groupBy('i').count().join(edges, 'i'). \
        selectExpr('j as i', 'i as j', '1/count as value')


    transitions_in = edges.groupBy('j').count().join(edges, 'j'). \
        selectExpr('i', 'j', '1/count as value')
    return rho, transitions_in, transitions_out



def estimate_datarank(rho, transitions_in, transitions_out, alpha, beta, tol=0.01, max_iter=5, checkpoint_interval=2, verbose=False):
    """Estimate datarank based on initial distribution `rho` and transition matrix `M`"""
    rho.persist(StorageLevel.MEMORY_AND_DISK)
	transitions_in.persist(StorageLevel.MEMORY_AND_DISK)
    transitions_out.persist(StorageLevel.MEMORY_AND_DISK)
    datarank = rho
    current_transitions_in = transitions_in
    current_transitions_out = transitions_out
    current_sum_term_forward = rho
    current_sum_term_backward = rho
    for i in range(1, max_iter + 1):
        rho_forward = matrix_dot_vector(current_transitions_out, current_sum_term_forward)
        current_sum_term_forward = vector_times_scalar(rho_forward, (alpha))

        rho_backward = matrix_dot_vector(current_transitions_in, current_sum_term_backward)
        #current_sum_term_backward = vector_times_scalar(rho_backward, (beta)**i)
        current_sum_term_backward = vector_times_scalar(rho_backward, (beta))

        new_datarank = vector_plus_vector(datarank, current_sum_term_forward)
        new_datarank = vector_plus_vector(new_datarank, current_sum_term_backward)
        if i % checkpoint_interval == 0:
            new_datarank = new_datarank.persist(StorageLevel.MEMORY_AND_DISK)
            current_sum_term_forward = current_sum_term_forward.persist(StorageLevel.MEMORY_AND_DISK)
            current_sum_term_backward = current_sum_term_backward.persist(StorageLevel.MEMORY_AND_DISK)

        diff = vector_sub_vector(new_datarank, datarank).selectExpr('avg(value*value) as mse').first().mse
        if verbose:
            print("Iteration {}: MSE = {}".format(i, diff))
        datarank = new_datarank
        if diff < tol:
            break

    rho.unpersist()
	transitions_in.unpersist()
    transitions_out.unpersist()
    return datarank
