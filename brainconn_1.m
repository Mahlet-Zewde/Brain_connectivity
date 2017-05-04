%Brain Connectivity
clear all
load('macaque71');


%%
% 1)Degree and Similarity
%Node degree is the number of links connected to the node. The indegree 
%   is the number of inward links and the outdegree is the number of 
%   outward links.


[id,od,deg2] = degrees_dir(CIJ);% calculates both outward and inward links

figure();
subplot(2,1,1)
stem(id);
xlabel('Node no')
ylabel('Number of inward Links')
title('Node degree ')

subplot(2,1,2)
stem(od);
xlabel('Node no')
ylabel('Number of outward Links')
title('Node degree ')


 [J,J_od,J_id,J_bl] = jdegree(CIJ); % joint degree distribution matrix
 
figure();
imagesc(J);
colorbar();
%

[EC,ec,degij] = edge_nei_overlap_bd(CIJ);%   This function determines the neighbors of two nodes that are linked by an edge, and then computes their overlap. 


figure();
subplot(2,1,1)
stem(ec);
xlabel('Node no')
ylabel('Number of inward Links')
title('Node degree ')

subplot(2,1,2)
imagesc(EC);
colorbar();
%%
% 2) Density and Rentian Scaling
[kden,N,K] = density_dir(CIJ);%Density is the fraction of present connections to possible connections. Connection weights are ignored in calculations.



%% 
% 3) Clustering and Community Structure
 
 C=clustering_coef_bd(CIJ); %he fraction of triangles around a node and is equivalent to the fraction of node’s neighbors that are neighbors of each other.

 T=transitivity_bd(CIJ); %Transitivity: 
 E=efficiency_bin(CIJ,1);% global efficiency (see below) computed on node neighborhoods, and is related to the clustering coefficient.
 figure();
subplot(2,1,1)
 stem(C);
 xlabel('Node no');
ylabel('Clustering coeficient');
title('Clustering');
subplot(2,1,2)
 stem(E);
 xlabel('Node no');
ylabel('Efficiency Eloc');
title('Local Efficiency');

[M,Q]=community_louvain(CIJ);%Louvain community detection algorithm with added finetuning.
[Ci,Q2]=modularity_und(CIJ); % MODULARITY
 figure();
 subplot(2,1,1)
 stem(M);
 xlabel('Node no');
ylabel('community affiliation vector');
title('Community structure and modularity');
 subplot(2,1,2)
 stem(Ci);
 xlabel('Node no');
ylabel(' optimal community structure');

NCA=link_communities(CIJ);%

 figure();
imagesc(NCA);
colorbar();
 xlabel('Node no');
title('Nodal community affiliation vector');

%%
% 4)Assortativity and Core Structure
 r = assortativity_bin(CIJ,0); % Assortivity coefficient
 
 [R,Nk,Ek] = rich_club_bd(CIJ,40);% Rich club coefficients

 figure();
 subplot(3,1,1)
 stem(R);
 xlabel('Node no')
ylabel('R for levels 1 to 40')
title('Rich club coefficients')
 subplot(3,1,2)
 stem(Nk);
 xlabel('Node no')
ylabel('Nk with degree>40')
subplot(3,1,3)
 stem(Ek);
 xlabel('Node no')
ylabel(' Ek with degree>40')

[C, q]=core_periphery_dir(CIJ);% partition  into two non-overlapping groups of nodes
C = categorical(C,[0 1 ],{'periphery','core'}); 
figure();
histogram( C);
title('type of connectivity')

%%
% 5) Paths and Distances

 [Pq,tpath,plq,qstop,allpths,util] = findpaths(CIJ,70,4,1);%sequences of linked nodes, that never visit a single node more than once.

 D=distance_bin(CIJ); % Distance matrix, shortest distance between nodes
  figure();
imagesc(D);
colorbar();
title('lengths of shortest paths between all pairs of nodes')
 
 %%
 % 6)Efficiency and Diffusion
 Eloc=efficiency_bin(CIJ,1);%local efficiency is the global efficiency computed on the neighborhood of the node
  EGlo=efficiency_bin(CIJ,0);%global efficiency is the average of inverse shortest path length
 disp(EGlo);

   figure();
stem(Eloc);
title('local efficiency of a node');
xlabel('node no');
ylabel('Eloc');
 [GEdiff,Ediff] = diffusion_efficiency(CIJ);% DIFFUSION_EFFICIENCY Global mean and pair-wise diffusion efficiency
 disp(GEdiff);% Mean Global diffusion efficiency
 
   figure();
imagesc(Ediff);
colorbar();
title('Pair-wise diffusion efficiency');

 
 %%
 % 7)Centrality Measure
 
 BC=betweenness_bin(CIJ); %BETWEENNESS_BIN    Node betweenness centrality
   figure();
stem(Eloc);
title('node betweenness centrality vector');
xlabel('node no');
ylabel('Bc');

[EBC,BC_EDGE]=edge_betweenness_bin(CIJ);% Edge betweenness centrality
   figure();
   subplot(2,1,1)
stem(BC_EDGE);
title('node betweenness centrality vector');
xlabel('node no');
ylabel('Bc');
subplot(2,1,2)
imagesc(EBC);
colorbar();
title('edge betweenness centrality matrix');

 %%
 % 8) Motifs
 
%   [f,F]=motif3funct_bin(CIJ); %Frequency of functional class-3 motifs
%   [f_struct,F_struct]=motif3struct_bin(CIJ); %Frequency of structural class-3 motifs