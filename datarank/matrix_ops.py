"""Defines matrix operations within the Dataframe data structure"""

from pyspark.sql import functions as fn

__all__ = [
    'compute_rho_transitions', 'estimate_datarank'
]


def matrix_dot_vector(m, v):
    """Compute m*v where m is a matrix and v is a vector"""
    return m.join(v.selectExpr('i as j'), on='j'). \
        groupBy('i').agg(fn.sum('value').alias('value'))


def vector_times_scalar(m, scalar):
    """Compute vector v1 * scalar"""
    return m.select('i', (fn.col('value') * scalar).alias('value'))


def vector_sub_vector(v1, v2):
    """Compute vector v1 - v2"""
    return v1.selectExpr('i', 'value as v1').join(
        v2.selectExpr('i', 'value as v2'), 'i').selectExpr('i', '(v1 - v2) as value')


def vector_plus_vector(v1, v2):
    """Compute vector v1 + v2 where some components of v1 may not appear in v2"""
    return v1.selectExpr('i', 'value as v1').join(
        v2.selectExpr('i', 'value as v2'), on='i', how='left'). \
        select('i', (fn.col('v1') + fn.coalesce(fn.col('v2'), fn.lit(0))).alias('value'))


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
    cite_rank = rho
    current_transitions = transitions
    current_sum_term = rho
    for i in range(1, max_iter + 1):
        rho_forward = matrix_dot_vector(current_transitions, current_sum_term)
        current_sum_term = vector_times_scalar(rho_forward, (1 - alpha) ** i)
        new_cite_rank = vector_plus_vector(cite_rank, current_sum_term)
        if i % checkpoint_interval == 0:
            new_cite_rank = new_cite_rank.checkpoint()
            current_sum_term = current_sum_term.checkpoint()

        diff = vector_sub_vector(new_cite_rank, cite_rank).selectExpr('avg(value*value) as mse').first().mse
        if verbose:
            print("Iteration {}: MSE = {}".format(i, diff))
        cite_rank = new_cite_rank
        if diff < tol:
            if verbose:
                print("Finished")
            break

    return cite_rank
