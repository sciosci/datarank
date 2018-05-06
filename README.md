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
import citerank as cr

rho, transitions = \
    cr.compute_rho_transitions(vertices, edges, pub_decay_time=5, data_decay_time=10)
datarank = cr.estimate_datarank(rho, transitions, alpha=0.2)

# show the edges with most value
datarank.orderBy('value', ascending=False).show()
```



