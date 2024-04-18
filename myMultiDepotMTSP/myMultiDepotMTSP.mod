/*********************************************
 * OPL 22.1.1.0 Model
 * Title: Single-Depot Multiple-Travelling-Salesman Problem
 * Author: ajifoster3
 * Creation Date: Apr 17, 2024 at 9:39:38 PM
 *********************************************/
 
int numberOfCities = 10;
int teamSize = 2;
int numberOfNonDepotCities = numberOfCities-teamSize;

range Cities = 0..numberOfCities-1;
range NonDepotCities = teamSize-1..numberOfNonDepotCities;
range TeamMembers = 0..teamSize-1;

float distance[Cities][Cities] = [
    [0, 5, 4, 8, 2, 6, 3, 7, 9, 1],
    [5, 0, 2, 9, 1, 4, 7, 5, 6, 2],
    [4, 2, 0, 7, 2, 8, 5, 9, 4, 3],
    [8, 9, 7, 0, 1, 3, 6, 2, 8, 5],
    [2, 1, 2, 1, 0, 6, 4, 3, 7, 9],
    [6, 4, 8, 3, 6, 0, 5, 9, 2, 4],
    [3, 7, 5, 6, 4, 5, 0, 8, 1, 7],
    [7, 5, 9, 2, 3, 9, 8, 0, 6, 2],
    [9, 6, 4, 8, 7, 2, 1, 6, 0, 5],
    [1, 2, 3, 5, 9, 4, 7, 2, 5, 0]
];


dvar boolean pathUsed[TeamMembers][Cities][Cities];

dvar float maxDistance;

dvar int+ u[NonDepotCities];

minimize maxDistance;

subject to {
    
  // There should be no more than 1 path from the depot to any given city
  forall (j in Cities)
    sum (t in TeamMembers) pathUsed[t][t][j] <= 1;
  
  // Each depot should be left exactly once
  forall (t in TeamMembers)
    sum (ti in TeamMembers, j in Cities) pathUsed[ti][t][j] == 1;
    
  // Each Team member must leave its own Depot
  forall (t in TeamMembers)
    sum (j in Cities) pathUsed[t][t][j] == 1;
    
  // Each Team member must enter its own Depot
  forall (t in TeamMembers)
    sum (i in Cities) pathUsed[t][i][t] == 1;
  
  // Each city should only be left by one agent
  forall (i in Cities)
    sum (t in TeamMembers, j in Cities) pathUsed[t][i][j] == 1;
  
  // The maxDistance must be greater than the path cost for each agent
  forall (t in TeamMembers)
    sum (i in Cities, j in Cities) distance[i][j] * pathUsed[t][i][j] <= maxDistance;
  
  // All non-depot Cities must be visited exactly once
  forall (j in NonDepotCities)
    sum (t in TeamMembers, i in Cities) pathUsed[t][i][j] == 1;
  
  // Should only be one destination per origin
  forall (i in NonDepotCities)
    sum (t in TeamMembers, j in NonDepotCities) pathUsed[t][i][j] <= 1; 
  
  // An agent shouldn't move to itself
  forall (t in TeamMembers, i in Cities)
    pathUsed[t][i][i] == 0;
    
  // If an agent enters a city, it must exit
  forall (t in TeamMembers, j in NonDepotCities)
    sum(i in Cities) pathUsed[t][i][j] == sum(i in Cities) pathUsed[t][j][i];
    
  // Subtour elimination constraints
  forall(t in TeamMembers)
    forall(i in NonDepotCities, j in NonDepotCities: i != j)
      (u[i] - u[j] + numberOfCities * pathUsed[t][i][j] <= numberOfCities - 1);
  
}