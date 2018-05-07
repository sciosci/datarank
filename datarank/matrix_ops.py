"""Defines matrix operations within the Dataframe data structure"""

from pyspark.sql import functions as fn

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
