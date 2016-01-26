This page attempts to document the current branch cutting tasks that are needed
to be performed at various milestones and which team has the necessary
permissions in order to perform the necessary task in Parentheses.

M5 Offset 0

- Update JJB jobs to include pre-{release} branch
  **(releng/builder committers)**
- Use Gerrit to create pre-boron branches for all projects, save their hash
  **(Release Engineering Team)**
- Merge .gitreview update to list pre-boron branch
  **(Release Engineering Team)**
- Merge version bump by 0.1.0 patch
  **(Release Engineering Team)**

M5 Offset 2

JJB:
- Remove pre-boron JJB jobs
  **(releng/builder committers)**
- Change JJB stream:beryllium branch pointer from master -> stable/beryllium
  **(releng/builder committers)**
- Create new stream:boron branch pointer to branch master
  **(releng/builder committers)**

Process:
- Disable Submit permission on master branch
  **(Helpdesk)**
- Create stable/beryllium branches based on HEAD master
  **(Release Engineering Team)**
- Contribute .gitreview updates to stable/beryllium
  **(Release Engineering Team)**
- Version bump master by 0.1.0
  **(Release Engineering Team)**
- Re-enable Submit permission on master branch
  **(Helpdesk)**
- Cherry-pick patches from pre-boron to master if necessary
  **(Release Engineering Team)**
