# Datarank: Giving credit to data submissions

This algorithm is an adaptation of https://arxiv.org/abs/physics/0612122 
to consider data repositories as part of the citation network. 
It adapts a different decay time for publications and for data submissions.

# Usage

You need to have a Dataframe with columns `i`, `type`, and `age` where `i`
is the column id, `type` is `pub` or `data`, and `age` is the time since
publication.

You need another Dataframe with columns `i` and `j` which contains the citations
from `i` to `j`.

```python
from datarank import compute_rho_transitions, estimate_datarank

# you need to setup a check point location
spark.sparkContext.setCheckpointDir('/tmp/')

rho, transitions = \
    compute_rho_transitions(vertices, edges, pub_decay_time=5, data_decay_time=10)
dataranks = estimate_datarank(rho, transitions, alpha=0.2)

# show the edges with most value
dataranks.orderBy('value', ascending=False).show()
```



# Example: DBLP 

Obtain the DBLP dataset v10 from Aminer (https://static.aminer.org/lab-datasets/citation/dblp.v10.zip)
and place the JSON files in a folder. Let's assume that that folder is in `data`.
The following code will compute the `datarank` of the publications, even though all
of them of the type publication and none are data.

```python
from pyspark.sql import functions as fn
import datarank

dblp = spark.read.json('data/dblp-ref/*.json')
spark.sparkContext.setCheckpointDir('/tmp/')

# we will create a numerical id instead of the long string ID from DBLP
dblp_w_id = dblp.withColumn('i', fn.monotonically_increasing_id())

vertices = dblp_w_id.select(fn.expr('i'), fn.lit('pub').alias('type'), 
    (2018 - fn.col('year')).alias('age'))

edges = dblp_w_id.select('i', fn.explode('references').alias('id')).\
    join(dblp_w_id.selectExpr('i as j', 'id'), 'id').drop('id')
    

# there is no data so decay time of it doesn't matter
rho, transitions = datarank.compute_rho_transitions(vertices, edges, 
    pub_decay_time=2, data_decay_time=3)

# run algorithm and save results with 0.25 probability of stopping random surfer (alpha=0.25)
ranks = datarank.estimate_datarank(rho, transitions, alpha=0.25, 
    tol=0.2, max_iter=5, verbose=True)
ranks.write.parquet('datarank_dblp.parquet')
```