from gpulab.simulator.core import Fleet, Job, SchedulerLab, Team


def lab(): return SchedulerLab(Fleet({"a100":4,"l40s":4}),[Team("research",4,2),Team("inference",2),Team("evaluation",2)])
def test_borrowing_and_reclaim_pressure():
    x=lab(); assert x.submit(Job("eval-1","evaluation",4,flavor="l40s"))=="ADMITTED:borrowed=2"; assert x.submit(Job("research-1","research",4))=="ADMITTED"
def test_gang_waits_without_full_capacity():
    x=lab(); x.submit(Job("a","research",2)); assert x.submit(Job("gang","inference",4,gang=4))=="PENDING:insufficient compatible capacity"
def test_invalid_request_and_flavor_pressure():
    x=lab(); assert x.submit(Job("bad","research",9)).startswith("DENIED"); assert x.submit(Job("too-many","research",5))=="PENDING:insufficient compatible capacity"
def test_fragmentation_is_distinct_from_total_free_capacity():
    x=lab(); assert x.fragmentation(Job("topo","research",4,topology="same-rack"))
