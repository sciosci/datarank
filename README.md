# Datarank: Giving credit to data submissions

This algorithm is an adaptation of https://arxiv.org/abs/physics/0612122 
to consider data repositories as part of the citation network. 
It adapts a different decay time for publications and for data submissions.

# Usage

You need to have a Dataframe with columns `i`, `type`, and `age` where `i`
is the vertex id, `type` the type of vertex ( `pub` for publication or 
`data` for data), and `age` is the time since publication.

You need another Dataframe with columns `i` and `j` which contains the citations
from `i` to `j`.

```python
from datarank import compute_rho_transitions, estimate_datarank

rho, transitions = \
    compute_rho_transitions(vertices, edges, pub_decay_time=5, data_decay_time=10)
ranks = estimate_datarank(rho, transitions, alpha=0.2)

# show the edges with most value
ranks.orderBy('value', ascending=False).show()
```



# Example: DBLP 

Obtain the DBLP dataset v10 from Aminer (https://static.aminer.org/lab-datasets/citation/dblp.v10.zip)
and place the JSON files in a folder. Let's assume that that folder is in `data`.
The following code will compute the _datarank_ of the publications, which is equivalent
to _citerank_ since all of them are publications.

```python
from pyspark.sql import functions as fn
import datarank

dblp = spark.read.json('data/dblp-ref/*.json')

# we will create a numerical id instead of the long string ID from DBLP - saves intermediate space
dblp_w_id = dblp.withColumn('i', fn.monotonically_increasing_id())

vertices = dblp_w_id.select(fn.expr('i'), fn.lit('pub').alias('type'), 
    (2018 - fn.col('year')).alias('age'))

edges = dblp_w_id.select('i', fn.explode('references').alias('id')).\
    join(dblp_w_id.selectExpr('i as j', 'id'), 'id').drop('id')
    
# all data are publications so `data_decay_time` doesn't matter.
rho, transitions = datarank.compute_rho_transitions(vertices, edges, 
    pub_decay_time=2, data_decay_time=3)

# run algorithm 
ranks = datarank.estimate_datarank(rho, transitions, alpha=0.25, 
    tol=0.1, max_iter=10, verbose=True)
```
```
Iteration 1: MSE = 12.471878471605324
Iteration 2: MSE = 3.6335926962769705
Iteration 3: MSE = 1.5872437783429947
Iteration 4: MSE = 0.7629295327447363
Iteration 5: MSE = 0.383738469533167
Iteration 6: MSE = 0.19812267367345787
Iteration 7: MSE = 0.10415927670263239
Iteration 8: MSE = 0.055725091680802856 
```

The top 20 publications according to datarank are:

```python
(
dblp_w_id
    .join(ranks, 'i')
    .orderBy('value', ascending=False)
    .select('value', 'year', 'title', 'authors')
    .show()
)
```
```
+------------------+----+--------------------+--------------------+             
|             value|year|               title|             authors|
+------------------+----+--------------------+--------------------+
| 4428.919046564288|1989|Genetic Algorithm...| [David E. Goldberg]|
| 2125.954793098966|2004|Distinctive Image...|     [David G. Lowe]|
|2102.8177116662728|2011|LIBSVM: A library...|[Chih-Chung Chang...|
|1676.5289092517648|1988|Probabilistic Rea...|       [Judea Pearl]|
|1496.0928109007607|1993|C4.5: Programs fo...|   [J. Ross Quinlan]|
|1462.6191412043224|1974|The Design and An...|[Alfred V. Aho, J...|
|1401.4123541217332|1988|Snakes: Active Co...|[Michael Kass, An...|
|1288.9018931968308|1989|A theory for mult...|   [Stéphane Mallat]|
|1284.3316300425938|2002|A fast and elitis...|[Kalyanmoy Deb, A...|
|1274.8415617899816|1999|Reinforcement Lea...|[Richard S. Sutto...|
|1260.1180082025232|1998|A simple transmit...|[Siavash M. Alamo...|
|1247.5305932004994|2001|      Random Forests|       [Leo Breiman]|
|1225.5639177665412|1992|Genetic programmi...|      [John R. Koza]|
|1206.1629724422555|1978|A method for obta...|[Ronald L. Rivest...|
|1174.8652313520759|1992|Genetic algorithm...|[Zbigniew Michale...|
|1169.0421193247178|1986|Induction of Deci...| [John Ross Quinlan]|
|1161.5427756575639|1999|Capacity of multi...|      [Emre Telatar]|
|1159.3826125508328|1995|Support-Vector Ne...|[Corinna Cortes, ...|
|1146.2298617546014|1995|          Rough sets|[Zdzisław Pawlak,...|
| 1137.093905988581|1985|Fuzzy identificat...|[Tomohiro Takagi,...|
+------------------+----+--------------------+--------------------+
only showing top 20 rows
```

And there is a strong correlation between number of citations and datarank

```python
(
edges
    .groupBy('j')
    .agg(fn.count('*').alias('n_citations'))
    .selectExpr('j as i', 'n_citations')
    .join(ranks, 'i')
    .select(fn.corr('n_citations', 'value'))
    .show()
)
```
```
+------------------------+                                                      
|corr(n_citations, value)|
+------------------------+
|      0.9397311074391694|
+------------------------+
```

# License

(c) 2018 Daniel E. Acuna <deacuna@syr.edu>