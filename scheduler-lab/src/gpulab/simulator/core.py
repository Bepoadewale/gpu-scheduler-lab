from __future__ import annotations

from dataclasses import dataclass, field


@dataclass
class Team: name:str; quota:int; weight:int=1
@dataclass
class Job: id:str; team:str; gpus:int; priority:int=0; gang:int=1; flavor:str="a100"; topology:str|None=None; admitted:bool=False
@dataclass
class Fleet:
    capacity:dict[str,int]; used:dict[str,int]=field(default_factory=dict); allocations:dict[str,int]=field(default_factory=dict); timeline:list[str]=field(default_factory=list)
    def available(self, flavor:str)->int:return self.capacity.get(flavor,0)-self.used.get(flavor,0)
class SchedulerLab:
    """Policy simulator: GPU units are SIMULATED; no CUDA/performance claim."""
    def __init__(self, fleet:Fleet, teams:list[Team]): self.fleet,self.teams=fleet,{t.name:t for t in teams}; self.jobs={}
    def submit(self, job:Job)->str:
        if job.team not in self.teams:return "DENIED:unknown team"
        if job.gpus<=0 or job.gpus>8:return "DENIED:invalid gpu request"
        if job.gang>job.gpus:return "DENIED:invalid gang"
        self.jobs[job.id]=job; team=self.teams[job.team]; allocated=self.fleet.allocations.get(job.team,0)
        # Borrowing is permitted only while physical capacity and a valid flavor exist.
        if self.fleet.available(job.flavor)<job.gpus:return "PENDING:insufficient compatible capacity"
        if job.gang>self.fleet.available(job.flavor):return "PENDING:gang waits for all members"
        self.fleet.used[job.flavor]=self.fleet.used.get(job.flavor,0)+job.gpus; self.fleet.allocations[job.team]=allocated+job.gpus; job.admitted=True
        borrowed=max(0,allocated+job.gpus-team.quota); self.fleet.timeline.append(f"{job.id} admitted; borrowed={borrowed}")
        return "ADMITTED" if not borrowed else f"ADMITTED:borrowed={borrowed}"
    def release(self, job_id:str):
        job=self.jobs[job_id]; self.fleet.used[job.flavor]-=job.gpus; self.fleet.allocations[job.team]-=job.gpus; job.admitted=False; self.fleet.timeline.append(f"{job.id} released")
    def fragmentation(self, job:Job)->bool:
        return self.fleet.available(job.flavor)>=job.gpus and job.topology=="same-rack" # illustrative topology inventory lacks same rack block
    def fairness(self)->float:
        shares=[self.fleet.allocations.get(t.name,0)/t.weight for t in self.teams.values()]
        return 0 if not sum(shares) else sum(shares)**2/(len(shares)*sum(x*x for x in shares))
