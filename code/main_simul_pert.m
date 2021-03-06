%% This file tests the robustness of the 22 different clustering methods with respect to additive Gaussian noise.
%% need for Fig2(C) type results

addpath(genpath(pwd))

rng(100);

load('all_data')

ind_cancer=setdiff(1:33, [10 11 12 16 20 24 25 27 29 31 33]); 



pat_num=[];
for ii=1:33; pat_num=[pat_num,sum(all_pat==ii)];end;  find(pat_num>30)   %%this is the cancer index having at least 30 patients

ind_cancer=setdiff(1:33, [10 11 12 16 20 24 25 27 29 31 33]); 

ind_sel=[]; size_ind_sel=[]; size_ind_sel0=[]; size_cum=0;
for iii=1:length(ind_cancer)
    ind_sel=[ind_sel;find(all_pat==ind_cancer(iii))]; size_ind_sel=[size_ind_sel, sum(all_pat==ind_cancer(iii))];
    size_cum=size_cum+sum(all_pat==ind_cancer(iii));
    size_ind_sel0=[size_ind_sel0, size_cum];
end
size_ind_sel0=[0,size_ind_sel0];


%start from here
ksize=length(ind_cancer);  %%ksize is the number of cancer types.

nmi_cen1=[]; nmi_cen2=[]; nmi_cen3=[]; nmi_cen123=[];
nmi_cm123=[]; nmi_pm123=[];
nmik1=[]; nmik2=[]; nmik3=[]; nmik123=[];
nmis1=[]; nmis2=[]; nmis3=[]; nmis123=[];
nmi_keradd123=[];
nmi_wd123=[]; nmi_wde123=[]; nmi_wdf123=[];
nmi_ed123=[]; nmi_edf123=[];
nmi_sml1=[]; nmi_sml2=[]; nmi_sml3=[]; nmi_sml123=[];
nmi_ssc1=[]; nmi_ssc2=[]; nmi_ssc3=[]; nmi_ssc123=[];

pmi_cen1=[]; pmi_cen2=[]; pmi_cen3=[]; pmi_cen123=[];
pmi_cm123=[]; pmi_pm123=[];
pmik1=[]; pmik2=[]; pmik3=[]; pmik123=[];
pmis1=[]; pmis2=[]; pmis3=[]; pmis123=[];
pmi_keradd123=[];
pmi_wd123=[]; pmi_wde123=[]; pmi_wdf123=[];
pmi_ed123=[]; pmi_edf123=[];
pmi_sml1=[]; pmi_sml2=[]; pmi_sml3=[]; pmi_sml123=[];
pmi_ssc1=[]; pmi_ssc2=[]; pmi_ssc3=[]; pmi_ssc123=[];


rmi_cen1=[]; rmi_cen2=[]; rmi_cen3=[]; rmi_cen123=[];
rmi_cm123=[]; rmi_pm123=[];
rmik1=[]; rmik2=[]; rmik3=[]; rmik123=[];
rmis1=[]; rmis2=[]; rmis3=[]; rmis123=[];
rmi_keradd123=[];
rmi_wd123=[]; rmi_wde123=[]; rmi_wdf123=[];
rmi_ed123=[]; rmi_edf123=[];
rmi_sml1=[]; rmi_sml2=[]; rmi_sml3=[]; rmi_sml123=[];
rmi_ssc1=[]; rmi_ssc2=[]; rmi_ssc3=[]; rmi_ssc123=[];

data_sset=cell(1,50); clus_ind_set12=cell(1,50);

parfor uuu=1:50   %% number of iterations
n4= 30*22;  %% consider total random 280 pateints; 280 should be multiple of ksize.
ttt10=[];
for tuu=1:ksize
ttt0=randperm(size_ind_sel(tuu)); ttt10=[ttt10, ttt0(1:(n4/ksize))+size_ind_sel0(tuu)];
end
ttt1=ind_sel(ttt10);

n=n4;

sel_exp=(all_exp(:,ttt1));   
sel_cna=(all_cna(:,ttt1));   
sel_mirna=(all_mirna(:,ttt1));   
sel_clin=all_clin(ttt1,:); 
true_labs=all_pat(ttt1);   true_labs0=true_labs;

sel_exp=double(sel_exp); sel_cna=double(sel_cna); sel_mirna=double(sel_mirna);

data_sset{uuu}={sel_exp,sel_mirna,sel_cna};

for jjj=1:ksize;  true_labs0(true_labs==ind_cancer(jjj))=jjj; end
true_labs=true_labs0;
C = max(true_labs); CCC=C; 


sel_exp2 = reg_pca(sel_exp',100);
sel_cna2 = reg_pca(sel_cna',100);
sel_mirna2 = reg_pca(sel_mirna',100);


data_set3={sel_exp2,sel_mirna2 sel_cna2};   %sel_mirna2

data_set33={double(sel_exp2),double(sel_mirna2), double(sel_cna2)}; 
in_Xi= [sel_exp2,sel_mirna2,sel_cna2]; 


%% consensus 
U = {'U_H','std',[]};   
r = 100;
w = ones(r,1); % the weight of each partitioning
rep = 10; % the number of ECC runs
maxIter = 40;
minThres = 1e-5;
utilFlag = 0;


IDX1 = BasicCluster_RPS(data_set33{1},r,CCC,'sqEuclidean',1);%Generate basic partitions
[pi_sumbest,pi_index1,pi_converge,pi_utility,cons1] = RunECC(IDX1,CCC,U,w,rep,maxIter,minThres,utilFlag); % run KCC for consensus clustering

IDX2 = BasicCluster_RPS(data_set33{2},r,CCC,'sqEuclidean',1);%Generate basic partitions
[pi_sumbest,pi_index2,pi_converge,pi_utility,cons2] = RunECC(IDX2,CCC,U,w,rep,maxIter,minThres,utilFlag); % run KCC for consensus clustering

IDX3 = BasicCluster_RPS(data_set33{3},r,CCC,'sqEuclidean',1);%Generate basic partitions
[pi_sumbest,pi_index3,pi_converge,pi_utility,cons2] = RunECC(IDX3,CCC,U,w,rep,maxIter,minThres,utilFlag); % run KCC for consensus clustering

IDXX123=[IDX1,IDX2,IDX3];
[pi_sumbest,pi_index123,pi_converge,pi_utility,cons3] = RunECC(IDXX123,CCC,U,ones(3*r,1),rep,maxIter,minThres,utilFlag); 

nmi_cen1=[nmi_cen1,Cal_NMI(pi_index1, true_labs)];pmi_cen1=[pmi_cen1,purity(CCC, pi_index1, true_labs)];
rmi_cen1=[rmi_cen1,RandIndex(true_labs, pi_index1)];
nmi_cen2=[nmi_cen2,Cal_NMI(pi_index2, true_labs)];pmi_cen2=[pmi_cen2,purity(CCC, pi_index2, true_labs)];
rmi_cen2=[rmi_cen2,RandIndex(true_labs, pi_index2)];
nmi_cen3=[nmi_cen3,Cal_NMI(pi_index3, true_labs)];pmi_cen3=[pmi_cen3,purity(CCC, pi_index3, true_labs)];
rmi_cen3=[rmi_cen3,RandIndex(true_labs, pi_index3)];

nmi_cen123=[nmi_cen123,Cal_NMI(pi_index123, true_labs)];pmi_cen123=[pmi_cen123,purity(CCC, pi_index123, true_labs)];
rmi_cen123=[rmi_cen123,RandIndex(true_labs, pi_index123)];


%% spectral_centroid_multiview
num_views=length(data_set33); sigma_c=10*ones(1,num_views); %true_labs=[ones(1,round(3/n)),1*ones(1,round(3/n))
[Fc Pc Rc nmi_cm2 avgent_cm AR_cm  idx_cm123] = spectral_centroid_multiview(data_set33,num_views,CCC,sigma_c, 0.01*ones(1,num_views),true_labs,30);
nmi_cm123=[nmi_cm123,Cal_NMI(idx_cm123, true_labs)];pmi_cm123=[pmi_cm123,purity(CCC, idx_cm123, true_labs)];
rmi_cm123=[rmi_cm123,RandIndex(true_labs, idx_cm123)];


%% spectral_pairwise_multview
num_views=length(data_set33); sigma_c=10*ones(1,num_views); %true_labs=[ones(1,round(3/n)),1*ones(1,round(3/n))
[Fc Pc Rc nmi_pm2 avgent_cm AR_cm  idx_pm123] = spectral_pairwise_multview(data_set33,num_views,CCC,sigma_c, 0.01,true_labs,30);
nmi_pm123=[nmi_pm123,Cal_NMI(idx_pm123, true_labs)];pmi_pm123=[pmi_pm123,purity(CCC, idx_pm123, true_labs)];
rmi_pm123=[rmi_pm123,RandIndex(true_labs, idx_pm123)];



%% this is for multiple cancer
K=length(data_set3);  gg=ones(1,K);
Wfc0s_euc_reg=cell(1,K); Wfc0s_euc_near=cell(1,K);  %Wfg_euc_reg_n=cell(1,K); 

sigma_set=1:0.25:2;   %sigma_set=sigma_set(1:7);
k_set=10:2:30;

[Wfc0s_euc_near_n]=generate_sim_matrices(K,data_set3,gg, true_labs,sigma_set,k_set);

Wfc0s_euc_near_n_average=cell(1,K);
for iii=1:K
    ini_average=0;
    for iiaverage=1:55
    Wfc0s_euc_near_n_average{iii}{1}{1}=ini_average+Wfc0s_euc_near_n{iii}{1}{iiaverage}/55;
    end
end


%% this is the k-menas using only first omic data
idxxk1=litekmeans(double(data_set3{1}),CCC,'Replicates',50); %% run k-means on embeddings to get cell populations
idxxk2=litekmeans(double(data_set3{2}),CCC,'Replicates',50); %% run k-means on embeddings to get cell populations
idxxk3=litekmeans(double(data_set3{3}),CCC,'Replicates',50); %% run k-means on embeddings to get cell populations

%% this is the k-menas using all omic datasets
idxxk123=litekmeans(double(in_Xi),CCC,'Replicates',50); %% run k-means on embeddings to get cell populations

nmik1=[nmik1,Cal_NMI(idxxk1, true_labs)];pmik1=[pmik1,purity(CCC, idxxk1, true_labs)];
rmik1=[rmik1,RandIndex(true_labs, idxxk1)];
nmik2=[nmik2,Cal_NMI(idxxk2, true_labs)];pmik2=[pmik2,purity(CCC, idxxk2, true_labs)];
rmik2=[rmik2,RandIndex(true_labs, idxxk2)];
nmik3=[nmik3,Cal_NMI(idxxk3, true_labs)];pmik3=[pmik3,purity(CCC, idxxk3, true_labs)];
rmik3=[rmik3,RandIndex(true_labs, idxxk3)];
nmik123=[nmik123,Cal_NMI(idxxk123, true_labs)];pmik123=[pmik123,purity(CCC, idxxk123, true_labs)];
rmik123=[rmik123,RandIndex(true_labs, idxxk123)];



%% this is the spectral clustering using the first omic data
[V_tot1, temp, evs]=eig1(double(Wfc0s_euc_near_n{1}{1}{22}), CCC); 
Clus_ind_spec1=litekmeans(V_tot1,CCC,'Replicates',50);  %% run k-means on embeddings to get cell populations

[V_tot2, temp, evs]=eig1(double(Wfc0s_euc_near_n{2}{1}{22}), CCC); 
Clus_ind_spec2=litekmeans(V_tot2,CCC,'Replicates',50);  %% run k-means on embeddings to get cell populations

[V_tot3, temp, evs]=eig1(double(Wfc0s_euc_near_n{3}{1}{22}), CCC); 
Clus_ind_spec3=litekmeans(V_tot3,CCC,'Replicates',50);  %% run k-means on embeddings to get cell populations

Clus_ind_spec123=litekmeans([V_tot1,V_tot2,V_tot3],CCC,'Replicates',50);  %% run k-means on embeddings to get cell populations

nmis1=[nmis1,Cal_NMI(true_labs, Clus_ind_spec1)]; pmis1=[pmis1,purity(CCC, Clus_ind_spec1, true_labs)];
rmis1=[rmis1,RandIndex(true_labs, Clus_ind_spec1)];
nmis2=[nmis2,Cal_NMI(true_labs, Clus_ind_spec2)]; pmis2=[pmis2,purity(CCC, Clus_ind_spec2, true_labs)];
rmis2=[rmis2,RandIndex(true_labs, Clus_ind_spec2)];
nmis3=[nmis3,Cal_NMI(true_labs, Clus_ind_spec3)]; pmis3=[pmis3,purity(CCC, Clus_ind_spec3, true_labs)];
rmis3=[rmis3,RandIndex(true_labs, Clus_ind_spec3)];
nmis123=[nmis123,Cal_NMI(true_labs, Clus_ind_spec123)]; pmis123=[pmis123,purity(CCC, Clus_ind_spec123, true_labs)];
rmis123=[rmis123,RandIndex(true_labs, Clus_ind_spec123)];


%% this is our algorithm without kernel learning to each omic data
K=length(data_set3); gg=ones(1,K);  c=0.1; rho=2;  lam=0.001; mu=0.1; eta=1;     %K=1; gg=[1];
[P_set,V_set,V_tot,ck,W_set,Wg_set]=clus_sim_update(CCC, c,rho, n, K, 1,1, gg, lam, mu, eta, Wfc0s_euc_near_n_average);   %Wfc0_euc_reg); % Wfc0_euc_near_n) ;
tresult=[P_set,V_set,V_tot,ck,W_set,Wg_set]; 
V_tot=[]; for dd=1:K;  V_tot=[V_tot, tresult{K+1}(dd)*tresult{K+2}(:,(dd*CCC-CCC+1):(dd*CCC))]; end
V_tot=V_tot./ repmat(sqrt(sum(V_tot.^2,2)),1,size(V_tot,2));
Clus_ind_wok123=litekmeans(V_tot,CCC,'Replicates',50);  %% run k-means on embeddings to get cell populations

nmi_keradd123=[nmi_keradd123,Cal_NMI(true_labs, Clus_ind_wok123)]; pmi_keradd123=[pmi_keradd123,purity(CCC, Clus_ind_wok123, true_labs)];
rmi_keradd123=[rmi_keradd123,RandIndex(true_labs, Clus_ind_wok123)];



%% this is our algorithm with learned weight to each omic data
K=length(data_set3); gg=ones(1,K); c=0.1; rho=2;  lam=0.001; mu=0.1; eta=1;     %K=1; gg=[1];
[P_set,V_set,V_tot,ck,W_set,Wg_set]=clus_sim_update(CCC, c,rho, n, K, 5,11, gg, lam, mu, eta, Wfc0s_euc_near_n);   %Wfc0_euc_reg); % Wfc0_euc_near_n) ;
ck123=ck;
%this incorportates learned weight in the three target matrices for clustering analysis
tresult=[P_set,V_set,V_tot,ck,W_set,Wg_set];  tresult_final=tresult;
V_tot=[]; for dd=1:K;  V_tot=[V_tot, tresult{K+1}(dd)*tresult{K+2}(:,(dd*CCC-CCC+1):(dd*CCC))]; end
V_tot=V_tot./ repmat(sqrt(sum(V_tot.^2,2)),1,size(V_tot,2));
Clus_ind_wd123=litekmeans(V_tot,CCC,'Replicates',50);  %% run k-means on embeddings to get cell populations

V_tot=[]; for dd=1:K;  V_tot=[V_tot, 1*tresult{K+2}(:,(dd*CCC-CCC+1):(dd*CCC))]; end
V_tot=V_tot./ repmat(sqrt(sum(V_tot.^2,2)),1,size(V_tot,2));
Clus_ind_wde123=litekmeans(V_tot,CCC,'Replicates',50);  %% run k-means on embeddings to get cell populations

%this uses the first leared target matrix for clustering analysis
V_tot=tresult{2}; 
V_tot=V_tot./ repmat(sqrt(sum(V_tot.^2,2)),1,size(V_tot,2));
Clus_ind_wdf123=litekmeans(V_tot,CCC,'Replicates',50);  %% run k-means on embeddings to get cell populations

nmi_wd123=[nmi_wd123,Cal_NMI(true_labs, Clus_ind_wd123)]; pmi_wd123=[pmi_wd123,purity(CCC, Clus_ind_wd123, true_labs)];
rmi_wd123=[rmi_wd123,RandIndex(true_labs, Clus_ind_wd123)];
nmi_wde123=[nmi_wde123,Cal_NMI(true_labs, Clus_ind_wde123)]; pmi_wde123=[pmi_wde123,purity(CCC, Clus_ind_wde123, true_labs)];
rmi_wde123=[rmi_wde123,RandIndex(true_labs, Clus_ind_wde123)];
nmi_wdf123=[nmi_wdf123,Cal_NMI(true_labs, Clus_ind_wdf123)]; pmi_wdf123=[pmi_wdf123,purity(CCC, Clus_ind_wdf123, true_labs)];
rmi_wdf123=[rmi_wdf123,RandIndex(true_labs, Clus_ind_wdf123)];


%% this is our algorithm using equal weight to each omic data
 K=length(data_set3);gg=ones(1,K);  c=0.1; rho=2;  lam=0.001; lam=0.001;  mu=1; eta=1;     
[P_set,V_set,V_tot,ck,W_set,Wg_set]=clus_sim_update2(CCC, c,rho, n, K, 5,11, gg, lam, mu, eta, Wfc0s_euc_near_n);   %Wfc0_euc_reg); % Wfc0_euc_near_n) ;

%this use all the learned target matrices for clustering analysis
tresult=[P_set,V_set,V_tot,ck,W_set,Wg_set]; 
%V_tot=[tresult{K+3}(1)*tresult{K+2}(:,1:CCC),tresult{K+3}(2)*tresult{K+2}(:,(CCC+1):(2*CCC)),tresult{K+3}(3)*tresult{K+2}(:,(2*CCC+1):(3*CCC))];
V_tot=[]; for dd=1:K;  V_tot=[V_tot, tresult{K+1}(dd)*tresult{K+2}(:,(dd*CCC-CCC+1):(dd*CCC))]; end
V_tot=V_tot./ repmat(sqrt(sum(V_tot.^2,2)),1,size(V_tot,2));
Clus_ind_ed123=litekmeans(V_tot,CCC,'Replicates',50);  %% run k-means on embeddings to get cell populations

%this only use the first leared target matrix for clustering analysis
V_tot=tresult{2}; 
V_tot=V_tot./ repmat(sqrt(sum(V_tot.^2,2)),1,size(V_tot,2));
Clus_ind_edf123=litekmeans(V_tot,CCC,'Replicates',50);  %% run k-means on embeddings to get cell populations

nmi_ed123=[nmi_ed123,Cal_NMI(true_labs, Clus_ind_ed123)]; pmi_ed123=[pmi_ed123,purity(CCC, Clus_ind_ed123, true_labs)];
rmi_ed123=[rmi_ed123,RandIndex(true_labs, Clus_ind_ed123)];
nmi_edf123=[nmi_edf123,Cal_NMI(true_labs, Clus_ind_edf123)]; pmi_edf123=[pmi_edf123,purity(CCC, Clus_ind_edf123, true_labs)];
rmi_edf123=[rmi_edf123,RandIndex(true_labs, Clus_ind_edf123)];

%% this is simlr1 using all the omic data
[S_simlr00, F1] = SIMLR_LARGE(double(data_set3{1}),CCC,30); %Y is already decreased matrix, %%S is the learned similarity, F is the latent embedding 
Clus_simlr1=litekmeans(F1,CCC,'Replicates',50); %% run k-means on embeddings to get cell populations

[S_simlr00, F2] = SIMLR_LARGE(double(data_set3{2}),CCC,30); %Y is already decreased matrix, %%S is the learned similarity, F is the latent embedding 
Clus_simlr2=litekmeans(F2,CCC,'Replicates',50); %% run k-means on embeddings to get cell populations

[S_simlr00, F3] = SIMLR_LARGE(double(data_set3{3}),CCC,30); %Y is already decreased matrix, %%S is the learned similarity, F is the latent embedding 
Clus_simlr3=litekmeans(F3,CCC,'Replicates',50); %% run k-means on embeddings to get cell populations

Clus_simlr123=litekmeans([F1,F2,F3],CCC,'Replicates',50); %% run k-means on embeddings to get cell populations

nmi_sml1=[nmi_sml1,Cal_NMI(true_labs, Clus_simlr1)]; pmi_sml1=[pmi_sml1,purity(CCC, Clus_simlr1, true_labs)];
rmi_sml1=[rmi_sml1,RandIndex(true_labs, Clus_simlr1)];
nmi_sml2=[nmi_sml2,Cal_NMI(true_labs, Clus_simlr2)]; pmi_sml2=[pmi_sml2,purity(CCC, Clus_simlr2, true_labs)];
rmi_sml2=[rmi_sml2,RandIndex(true_labs, Clus_simlr2)];
nmi_sml3=[nmi_sml3,Cal_NMI(true_labs, Clus_simlr3)]; pmi_sml3=[pmi_sml3,purity(CCC, Clus_simlr3, true_labs)];
rmi_sml3=[rmi_sml3,RandIndex(true_labs, Clus_simlr3)];
nmi_sml123=[nmi_sml123,Cal_NMI(true_labs, Clus_simlr123)]; pmi_sml123=[pmi_sml123,purity(CCC, Clus_simlr123, true_labs)];
rmi_sml123=[rmi_sml123,RandIndex(true_labs, Clus_simlr123)];



%% sparse spect cluster
[Ps,objs,errs,iters] = sparsesc(eye(n)-Wfc0s_euc_near_n{1}{1}{22},0.00001,CCC);
[V_tot1, temp, evs]=eig1(Ps, CCC); 
Clus_ind_sparsc1=litekmeans(double(V_tot1),CCC,'Replicates',50);  %% run k-means on embeddings to get cell populations

[Ps,objs,errs,iters] = sparsesc(eye(n)-Wfc0s_euc_near_n{2}{1}{22},0.00001,CCC);
[V_tot2, temp, evs]=eig1(Ps, CCC); 
Clus_ind_sparsc2=litekmeans(double(V_tot2),CCC,'Replicates',50); 

[Ps,objs,errs,iters] = sparsesc(eye(n)-Wfc0s_euc_near_n{3}{1}{22},0.00001,CCC);
[V_tot3, temp, evs]=eig1(Ps, CCC); 
Clus_ind_sparsc3=litekmeans(double(V_tot3),CCC,'Replicates',50); 

Clus_ind_sparsc123=litekmeans(double([V_tot1,V_tot2,V_tot3]),CCC,'Replicates',50); 

nmi_ssc1=[nmi_ssc1,Cal_NMI(true_labs, Clus_ind_sparsc1)]; pmi_ssc1=[pmi_ssc1,purity(CCC, Clus_ind_sparsc1, true_labs)];
rmi_ssc1=[rmi_ssc1,RandIndex(true_labs, Clus_ind_sparsc1)];
nmi_ssc2=[nmi_ssc2,Cal_NMI(true_labs, Clus_ind_sparsc2)]; pmi_ssc2=[pmi_ssc2,purity(CCC, Clus_ind_sparsc2, true_labs)];
rmi_ssc2=[rmi_ssc2,RandIndex(true_labs, Clus_ind_sparsc2)];
nmi_ssc3=[nmi_ssc3,Cal_NMI(true_labs, Clus_ind_sparsc3)]; pmi_ssc3=[pmi_ssc3,purity(CCC, Clus_ind_sparsc3, true_labs)];
rmi_ssc3=[rmi_ssc3,RandIndex(true_labs, Clus_ind_sparsc3)];
nmi_ssc123=[nmi_ssc123,Cal_NMI(true_labs, Clus_ind_sparsc123)]; pmi_ssc123=[pmi_ssc123,purity(CCC, Clus_ind_sparsc123, true_labs)];
rmi_ssc123=[rmi_ssc123,RandIndex(true_labs, Clus_ind_sparsc123)];

clus_ind_set12{uuu}={idxxk1 idxxk2 idxxk3 idxxk123 Clus_ind_spec1 Clus_ind_spec2 Clus_ind_spec3 Clus_ind_spec123, ...
    Clus_ind_sparsc1 Clus_ind_sparsc2 Clus_ind_sparsc3  Clus_ind_sparsc123, ...
    Clus_simlr1 Clus_simlr2 Clus_simlr3  Clus_simlr123, ...
    pi_index1 pi_index2 pi_index3  pi_index123, ...
    idx_cm123, ...
     idx_pm123, ...
    Clus_ind_wok123 Clus_ind_ed123 Clus_ind_edf123, ...
    Clus_ind_wd123, ...
    Clus_ind_wde123, ...
    Clus_ind_wdf123}

end

%save('simul_threedata_22_stability_1118.mat','data_sset','clus_ind_set12')
data_ssett=data_sset;
clus_ind_set122=clus_ind_set12;

meanmat_mult=[mean(nmi_cen1),mean(nmi_cen2),mean(nmi_cen3),mean(nmi_cen123), mean(nmi_cm123),mean(nmi_pm123) ,mean(nmik1),mean(nmik2),mean(nmik3),mean(nmik123),mean(nmis1), mean(nmis2), mean(nmis3), mean(nmis123),mean(nmi_keradd123), mean(nmi_wd123),mean(nmi_wde123),mean(nmi_wdf123), mean(nmi_ed123),mean(nmi_edf123), mean(nmi_sml1),mean(nmi_sml2),mean(nmi_sml3),mean(nmi_sml123); ...
mean(pmi_cen1),mean(pmi_cen2),mean(pmi_cen3),mean(pmi_cen123), mean(pmi_cm123),mean(pmi_pm123) ,mean(pmik1),mean(pmik2),mean(pmik3),mean(pmik123),mean(pmis1), mean(pmis2), mean(pmis3), mean(pmis123),mean(pmi_keradd123), mean(pmi_wd123),mean(pmi_wde123),mean(pmi_wdf123), mean(pmi_ed123),mean(pmi_edf123), mean(pmi_sml1),mean(pmi_sml2),mean(pmi_sml3),mean(pmi_sml123); ...
mean(rmi_cen1),mean(rmi_cen2),mean(rmi_cen3),mean(rmi_cen123), mean(rmi_cm123),mean(rmi_pm123) ,mean(rmik1),mean(rmik2),mean(rmik3),mean(rmik123),mean(rmis1), mean(rmis2), mean(rmis3), mean(rmis123),mean(rmi_keradd123), mean(rmi_wd123),mean(rmi_wde123),mean(rmi_wdf123), mean(rmi_ed123),mean(rmi_edf123), mean(rmi_sml1),mean(rmi_sml2),mean(rmi_sml3),mean(rmi_sml123)]




%%
nnmi_cen1=[]; nnmi_cen2=[]; nnmi_cen3=[]; nnmi_cen123=[];
nnmi_cm123=[]; nnmi_pm123=[];
nnmik1=[]; nnmik2=[]; nnmik3=[]; nnmik123=[];
nnmis1=[]; nnmis2=[]; nnmis3=[]; nnmis123=[];
nnmi_keradd123=[];
nnmi_wd123=[]; nnmi_wde123=[]; nnmi_wdf123=[];
nnmi_ed123=[]; nnmi_edf123=[];
nnmi_sml1=[]; nnmi_sml2=[]; nnmi_sml3=[]; nnmi_sml123=[];
nnmi_ssc1=[]; nnmi_ssc2=[]; nnmi_ssc3=[]; nnmi_ssc123=[];


ppmi_cen1=[]; ppmi_cen2=[]; ppmi_cen3=[]; ppmi_cen123=[];
ppmi_cm123=[]; ppmi_pm123=[];
ppmik1=[]; ppmik2=[]; ppmik3=[]; ppmik123=[];
ppmis1=[]; ppmis2=[]; ppmis3=[]; ppmis123=[];
ppmi_keradd123=[];
ppmi_wd123=[]; ppmi_wde123=[]; ppmi_wdf123=[];
ppmi_ed123=[]; ppmi_edf123=[];
ppmi_sml1=[]; ppmi_sml2=[]; ppmi_sml3=[]; ppmi_sml123=[];
ppmi_ssc1=[]; ppmi_ssc2=[]; ppmi_ssc3=[]; ppmi_ssc123=[];



rrmi_cen1=[]; rrmi_cen2=[]; rrmi_cen3=[]; rrmi_cen123=[];
rrmi_cm123=[]; rrmi_pm123=[];
rrmik1=[]; rrmik2=[]; rrmik3=[]; rrmik123=[];
rrmis1=[]; rrmis2=[]; rrmis3=[]; rrmis123=[];
rrmi_keradd123=[];
rrmi_wd123=[]; rrmi_wde123=[]; rrmi_wdf123=[];
rrmi_ed123=[]; rrmi_edf123=[];
rrmi_sml1=[]; rrmi_sml2=[]; rrmi_sml3=[]; rrmi_sml123=[];
rrmi_ssc1=[]; rrmi_ssc2=[]; rrmi_ssc3=[]; rrmi_ssc123=[];
%aaa=importdata('simul_threedata_22_stability_1118.mat');


sig_noise_set=[0.5 1 2];
for sij=1:3
    sigma_noise=sig_noise_set(sij);
 
nmi_cen1=[]; nmi_cen2=[]; nmi_cen3=[]; nmi_cen123=[];
nmi_cm123=[]; nmi_pm123=[];
nmik1=[]; nmik2=[]; nmik3=[]; nmik123=[];
nmis1=[]; nmis2=[]; nmis3=[]; nmis123=[];
nmi_keradd123=[];
nmi_wd123=[]; nmi_wde123=[]; nmi_wdf123=[];
nmi_ed123=[]; nmi_edf123=[];
nmi_sml1=[]; nmi_sml2=[]; nmi_sml3=[]; nmi_sml123=[];
nmi_ssc1=[]; nmi_ssc2=[]; nmi_ssc3=[]; nmi_ssc123=[];

pmi_cen1=[]; pmi_cen2=[]; pmi_cen3=[]; pmi_cen123=[];
pmi_cm123=[]; pmi_pm123=[];
pmik1=[]; pmik2=[]; pmik3=[]; pmik123=[];
pmis1=[]; pmis2=[]; pmis3=[]; pmis123=[];
pmi_keradd123=[];
pmi_wd123=[]; pmi_wde123=[]; pmi_wdf123=[];
pmi_ed123=[]; pmi_edf123=[];
pmi_sml1=[]; pmi_sml2=[]; pmi_sml3=[]; pmi_sml123=[];
pmi_ssc1=[]; pmi_ssc2=[]; pmi_ssc3=[]; pmi_ssc123=[];


rmi_cen1=[]; rmi_cen2=[]; rmi_cen3=[]; rmi_cen123=[];
rmi_cm123=[]; rmi_pm123=[];
rmik1=[]; rmik2=[]; rmik3=[]; rmik123=[];
rmis1=[]; rmis2=[]; rmis3=[]; rmis123=[];
rmi_keradd123=[];
rmi_wd123=[]; rmi_wde123=[]; rmi_wdf123=[];
rmi_ed123=[]; rmi_edf123=[];
rmi_sml1=[]; rmi_sml2=[]; rmi_sml3=[]; rmi_sml123=[];
rmi_ssc1=[]; rmi_ssc2=[]; rmi_ssc3=[]; rmi_ssc123=[];



parfor uuu=1:50    %% number of iterations
n4= 30*22; % 280;   %% consider total random 280 pateints; 280 should be multiple of ksize.
n=n4;

sel_exp=data_ssett{uuu}{1};    % 20530       10460
sel_cna=data_ssett{uuu}{3};    % 24776       10846
sel_mirna=data_ssett{uuu}{2};    % 39688        4430

C = max(clus_ind_set122{uuu}{1}); CCC=C; 

sel_exp=sel_exp+normrnd(0,sigma_noise,size(sel_exp,1),n);
sel_cna=sel_cna+normrnd(0,sigma_noise,size(sel_cna,1),n);
sel_mirna=sel_mirna+normrnd(0,sigma_noise,size(sel_mirna,1),n);

sel_exp2 = reg_pca(sel_exp',100);
sel_cna2 = reg_pca(sel_cna',100);
sel_mirna2 = reg_pca(sel_mirna',100);

data_set3={sel_exp2,sel_mirna2 sel_cna2};   %sel_mirna2

data_set33={double(sel_exp2),double(sel_mirna2), double(sel_cna2)}; 
in_Xi= [sel_exp2,sel_mirna2,sel_cna2]; 


%% this is the k-menas using only first omic data
idxxk1=litekmeans(double(data_set3{1}),CCC,'Replicates',50); %% run k-means on embeddings to get cell populations
idxxk2=litekmeans(double(data_set3{2}),CCC,'Replicates',50); %% run k-means on embeddings to get cell populations
idxxk3=litekmeans(double(data_set3{3}),CCC,'Replicates',50); %% run k-means on embeddings to get cell populations

%% this is the k-menas using all omic datasets
idxxk123=litekmeans(double(in_Xi),CCC,'Replicates',50); %% run k-means on embeddings to get cell populations

nmik1=[nmik1,Cal_NMI(idxxk1, clus_ind_set122{uuu}{1})];pmik1=[pmik1,purity(CCC, idxxk1,clus_ind_set122{uuu}{1})];
rmik1=[rmik1,RandIndex(idxxk1, clus_ind_set122{uuu}{1})];
nmik2=[nmik2,Cal_NMI(idxxk2, clus_ind_set122{uuu}{2})];pmik2=[pmik2,purity(CCC, idxxk2, clus_ind_set122{uuu}{2})];
rmik2=[rmik2,RandIndex(idxxk2,clus_ind_set122{uuu}{2})];
nmik3=[nmik3,Cal_NMI(idxxk3, clus_ind_set122{uuu}{3})];pmik3=[pmik3,purity(CCC, idxxk3, clus_ind_set122{uuu}{3})];
rmik3=[rmik3,RandIndex(idxxk3, clus_ind_set122{uuu}{3})];
nmik123=[nmik123,Cal_NMI(idxxk123, clus_ind_set122{uuu}{4})];pmik123=[pmik123,purity(CCC, idxxk123, clus_ind_set122{uuu}{4})];
rmik123=[rmik123,RandIndex(idxxk123, clus_ind_set122{uuu}{4})];



%% this is for multiple cancer
K=length(data_set3);  gg=ones(1,K);
Wfc0s_euc_reg=cell(1,K); Wfc0s_euc_near=cell(1,K);  %Wfg_euc_reg_n=cell(1,K); 

sigma_set=1:0.25:2;   %sigma_set=sigma_set(1:7);
k_set=10:2:30;

[Wfc0s_euc_near_n]=generate_sim_matrices(K,data_set3,gg, idxxk1,sigma_set,k_set);

Wfc0s_euc_near_n_average=cell(1,K);
for iii=1:K
    ini_average=0;
    for iiaverage=1:55
    Wfc0s_euc_near_n_average{iii}{1}{1}=ini_average+Wfc0s_euc_near_n{iii}{1}{iiaverage}/55;
    end
end




%% this is the spectral clustering using the first omic data
[V_tot1, temp, evs]=eig1(double(Wfc0s_euc_near_n{1}{1}{22}), CCC); 
Clus_ind_spec1=litekmeans(V_tot1,CCC,'Replicates',50);  %% run k-means on embeddings to get cell populations

[V_tot2, temp, evs]=eig1(double(Wfc0s_euc_near_n{2}{1}{22}), CCC); 
Clus_ind_spec2=litekmeans(V_tot2,CCC,'Replicates',50);  %% run k-means on embeddings to get cell populations

[V_tot3, temp, evs]=eig1(double(Wfc0s_euc_near_n{3}{1}{22}), CCC); 
Clus_ind_spec3=litekmeans(V_tot3,CCC,'Replicates',50);  %% run k-means on embeddings to get cell populations

Clus_ind_spec123=litekmeans([V_tot1,V_tot2,V_tot3],CCC,'Replicates',50);  %% run k-means on embeddings to get cell populations

nmis1=[nmis1,Cal_NMI(clus_ind_set122{uuu}{5}, Clus_ind_spec1)]; pmis1=[pmis1,purity(CCC, Clus_ind_spec1, clus_ind_set122{uuu}{5})];
rmis1=[rmis1,RandIndex(clus_ind_set122{uuu}{5}, Clus_ind_spec1)];
nmis2=[nmis2,Cal_NMI(clus_ind_set122{uuu}{6}, Clus_ind_spec2)]; pmis2=[pmis2,purity(CCC, Clus_ind_spec2, clus_ind_set122{uuu}{6})];
rmis2=[rmis2,RandIndex(clus_ind_set122{uuu}{6}, Clus_ind_spec2)];
nmis3=[nmis3,Cal_NMI(clus_ind_set122{uuu}{7}, Clus_ind_spec3)]; pmis3=[pmis3,purity(CCC, Clus_ind_spec3, clus_ind_set122{uuu}{7})];
rmis3=[rmis3,RandIndex(clus_ind_set122{uuu}{7}, Clus_ind_spec3)];
nmis123=[nmis123,Cal_NMI(clus_ind_set122{uuu}{8}, Clus_ind_spec123)]; pmis123=[pmis123,purity(CCC, Clus_ind_spec123, clus_ind_set122{uuu}{8})];
rmis123=[rmis123,RandIndex(clus_ind_set122{uuu}{8}, Clus_ind_spec123)];



%% this is simlr1 using all the omic data
[S_simlr00, F1] = SIMLR_LARGE(double(data_set3{1}),CCC,30); %Y is already decreased matrix, %%S is the learned similarity, F is the latent embedding 
Clus_simlr1=litekmeans(F1,CCC,'Replicates',50); %% run k-means on embeddings to get cell populations

[S_simlr00, F2] = SIMLR_LARGE(double(data_set3{2}),CCC,30); %Y is already decreased matrix, %%S is the learned similarity, F is the latent embedding 
Clus_simlr2=litekmeans(F2,CCC,'Replicates',50); %% run k-means on embeddings to get cell populations

[S_simlr00, F3] = SIMLR_LARGE(double(data_set3{3}),CCC,30); %Y is already decreased matrix, %%S is the learned similarity, F is the latent embedding 
Clus_simlr3=litekmeans(F3,CCC,'Replicates',50); %% run k-means on embeddings to get cell populations

Clus_simlr123=litekmeans([F1,F2,F3],CCC,'Replicates',50); %% run k-means on embeddings to get cell populations

nmi_sml1=[nmi_sml1,Cal_NMI(clus_ind_set122{uuu}{13}, Clus_simlr1)]; pmi_sml1=[pmi_sml1,purity(CCC, Clus_simlr1, clus_ind_set122{uuu}{13})];
rmi_sml1=[rmi_sml1,RandIndex(clus_ind_set122{uuu}{13}, Clus_simlr1)];
nmi_sml2=[nmi_sml2,Cal_NMI(clus_ind_set122{uuu}{14}, Clus_simlr2)]; pmi_sml2=[pmi_sml2,purity(CCC, Clus_simlr2, clus_ind_set122{uuu}{14})];
rmi_sml2=[rmi_sml2,RandIndex(clus_ind_set122{uuu}{14}, Clus_simlr2)];
nmi_sml3=[nmi_sml3,Cal_NMI(clus_ind_set122{uuu}{15}, Clus_simlr3)]; pmi_sml3=[pmi_sml3,purity(CCC, Clus_simlr3, clus_ind_set122{uuu}{15})];
rmi_sml3=[rmi_sml3,RandIndex(clus_ind_set122{uuu}{15}, Clus_simlr3)];
nmi_sml123=[nmi_sml123,Cal_NMI(clus_ind_set122{uuu}{16}, Clus_simlr123)]; pmi_sml123=[pmi_sml123,purity(CCC, Clus_simlr123, clus_ind_set122{uuu}{16})];
rmi_sml123=[rmi_sml123,RandIndex(clus_ind_set122{uuu}{16}, Clus_simlr123)];

%% consensus 
U = {'U_H','std',[]};   
r = 100;
w = ones(r,1); % the weight of each partitioning
rep = 10; % the number of ECC runs
maxIter = 40;
minThres = 1e-5;
utilFlag = 0;
 
 
IDX1 = BasicCluster_RPS(data_set33{1},r,CCC,'sqEuclidean',1);%Generate basic partitions
[pi_sumbest,pi_index1,pi_converge,pi_utility,cons1] = RunECC(IDX1,CCC,U,w,rep,maxIter,minThres,utilFlag); % run KCC for consensus clustering
 
IDX2 = BasicCluster_RPS(data_set33{2},r,CCC,'sqEuclidean',1);%Generate basic partitions
[pi_sumbest,pi_index2,pi_converge,pi_utility,cons2] = RunECC(IDX2,CCC,U,w,rep,maxIter,minThres,utilFlag); % run KCC for consensus clustering
 
IDX3 = BasicCluster_RPS(data_set33{3},r,CCC,'sqEuclidean',1);%Generate basic partitions
[pi_sumbest,pi_index3,pi_converge,pi_utility,cons2] = RunECC(IDX3,CCC,U,w,rep,maxIter,minThres,utilFlag); % run KCC for consensus clustering
 
IDXX123=[IDX1,IDX2,IDX3];
[pi_sumbest,pi_index123,pi_converge,pi_utility,cons3] = RunECC(IDXX123,CCC,U,ones(3*r,1),rep,maxIter,minThres,utilFlag); 
 
nmi_cen1=[nmi_cen1,Cal_NMI(pi_index1, clus_ind_set122{uuu}{17})];pmi_cen1=[pmi_cen1,purity(CCC, pi_index1, clus_ind_set122{uuu}{17})];
rmi_cen1=[rmi_cen1,RandIndex(clus_ind_set122{uuu}{17}, pi_index1)];
nmi_cen2=[nmi_cen2,Cal_NMI(pi_index2, clus_ind_set122{uuu}{18})];pmi_cen2=[pmi_cen2,purity(CCC, pi_index2, clus_ind_set122{uuu}{18})];
rmi_cen2=[rmi_cen2,RandIndex(clus_ind_set122{uuu}{18}, pi_index2)];
nmi_cen3=[nmi_cen3,Cal_NMI(pi_index3, clus_ind_set122{uuu}{19})];pmi_cen3=[pmi_cen3,purity(CCC, pi_index3, clus_ind_set122{uuu}{19})];
rmi_cen3=[rmi_cen3,RandIndex(clus_ind_set122{uuu}{19}, pi_index3)];
 
nmi_cen123=[nmi_cen123,Cal_NMI(pi_index123, clus_ind_set122{uuu}{20})];pmi_cen123=[pmi_cen123,purity(CCC, pi_index123, clus_ind_set122{uuu}{20})];
rmi_cen123=[rmi_cen123,RandIndex(clus_ind_set122{uuu}{20}, pi_index123)];
 
 
%% spectral_centroid_multiview
num_views=length(data_set33); sigma_c=10*ones(1,num_views); %true_labs=[ones(1,round(3/n)),1*ones(1,round(3/n))
[Fc Pc Rc nmi_cm2 avgent_cm AR_cm  idx_cm123] = spectral_centroid_multiview(data_set33,num_views,CCC,sigma_c, 0.01*ones(1,num_views),idxxk123,30);
nmi_cm123=[nmi_cm123,Cal_NMI(idx_cm123, clus_ind_set122{uuu}{21})];pmi_cm123=[pmi_cm123,purity(CCC, idx_cm123, clus_ind_set122{uuu}{21})];
rmi_cm123=[rmi_cm123,RandIndex(clus_ind_set122{uuu}{21}, idx_cm123)];
 
 
%% spectral_pairwise_multview
num_views=length(data_set33); sigma_c=10*ones(1,num_views); %true_labs=[ones(1,round(3/n)),1*ones(1,round(3/n))
[Fc Pc Rc nmi_pm2 avgent_cm AR_cm  idx_pm123] = spectral_pairwise_multview(data_set33,num_views,CCC,sigma_c, 0.01,idxxk123,30);
nmi_pm123=[nmi_pm123,Cal_NMI(idx_pm123, clus_ind_set122{uuu}{22})];pmi_pm123=[pmi_pm123,purity(CCC, idx_pm123, clus_ind_set122{uuu}{22})];
rmi_pm123=[rmi_pm123,RandIndex(clus_ind_set122{uuu}{22}, idx_pm123)];
 
 
 
%% this is our algorithm without kernel learning to each omic data
K=length(data_set3); gg=ones(1,K);  c=0.1; rho=2;  lam=0.001; mu=0.1; eta=1;     %K=1; gg=[1];
[P_set,V_set,V_tot,ck,W_set,Wg_set]=clus_sim_update(CCC, c,rho, n, K, 1,1, gg, lam, mu, eta, Wfc0s_euc_near_n_average);   %Wfc0_euc_reg); % Wfc0_euc_near_n) ;
tresult=[P_set,V_set,V_tot,ck,W_set,Wg_set]; 
V_tot=[]; for dd=1:K;  V_tot=[V_tot, tresult{K+1}(dd)*tresult{K+2}(:,(dd*CCC-CCC+1):(dd*CCC))]; end
V_tot=V_tot./ repmat(sqrt(sum(V_tot.^2,2)),1,size(V_tot,2));
Clus_ind_wok123=litekmeans(V_tot,CCC,'Replicates',50);  %% run k-means on embeddings to get cell populations
 
nmi_keradd123=[nmi_keradd123,Cal_NMI(clus_ind_set122{uuu}{23}, Clus_ind_wok123)]; pmi_keradd123=[pmi_keradd123,purity(CCC, Clus_ind_wok123, clus_ind_set122{uuu}{23})];
rmi_keradd123=[rmi_keradd123,RandIndex(clus_ind_set122{uuu}{23}, Clus_ind_wok123)];
 
 
 
%% this is our algorithm using equal weight to each omic data
 K=length(data_set3);gg=ones(1,K);  c=0.1; rho=2;  lam=0.001; lam=0.001;  mu=1; eta=1;     
[P_set,V_set,V_tot,ck,W_set,Wg_set]=clus_sim_update2(CCC, c,rho, n, K, 5,11, gg, lam, mu, eta, Wfc0s_euc_near_n);   %Wfc0_euc_reg); % Wfc0_euc_near_n) ;
 
%this use all the learned target matrices for clustering analysis
tresult=[P_set,V_set,V_tot,ck,W_set,Wg_set]; 
%V_tot=[tresult{K+3}(1)*tresult{K+2}(:,1:CCC),tresult{K+3}(2)*tresult{K+2}(:,(CCC+1):(2*CCC)),tresult{K+3}(3)*tresult{K+2}(:,(2*CCC+1):(3*CCC))];
V_tot=[]; for dd=1:K;  V_tot=[V_tot, tresult{K+1}(dd)*tresult{K+2}(:,(dd*CCC-CCC+1):(dd*CCC))]; end
V_tot=V_tot./ repmat(sqrt(sum(V_tot.^2,2)),1,size(V_tot,2));
Clus_ind_ed123=litekmeans(V_tot,CCC,'Replicates',50);  %% run k-means on embeddings to get cell populations
 
%this only use the first leared target matrix for clustering analysis
V_tot=tresult{2}; 
V_tot=V_tot./ repmat(sqrt(sum(V_tot.^2,2)),1,size(V_tot,2));
Clus_ind_edf123=litekmeans(V_tot,CCC,'Replicates',50);  %% run k-means on embeddings to get cell populations
 
nmi_ed123=[nmi_ed123,Cal_NMI(clus_ind_set122{uuu}{24}, Clus_ind_ed123)]; pmi_ed123=[pmi_ed123,purity(CCC, Clus_ind_ed123, clus_ind_set122{uuu}{24})];
rmi_ed123=[rmi_ed123,RandIndex(clus_ind_set122{uuu}{24}, Clus_ind_ed123)];
nmi_edf123=[nmi_edf123,Cal_NMI(clus_ind_set122{uuu}{25}, Clus_ind_edf123)]; pmi_edf123=[pmi_edf123,purity(CCC, Clus_ind_edf123, clus_ind_set122{uuu}{25})];
rmi_edf123=[rmi_edf123,RandIndex(clus_ind_set122{uuu}{25}, Clus_ind_edf123)];
 
 
%% this is our algorithm with learned weight to each omic data
K=length(data_set3); gg=ones(1,K); c=0.1; rho=2;  lam=0.001; mu=0.1; eta=1;     %K=1; gg=[1];
[P_set,V_set,V_tot,ck,W_set,Wg_set]=clus_sim_update(CCC, c,rho, n, K, 5,11, gg, lam, mu, eta, Wfc0s_euc_near_n);   %Wfc0_euc_reg); % Wfc0_euc_near_n) ;
ck123=ck;
%this incorportates learned weight in the three target matrices for clustering analysis
tresult=[P_set,V_set,V_tot,ck,W_set,Wg_set];  tresult_final=tresult;
V_tot=[]; for dd=1:K;  V_tot=[V_tot, tresult{K+1}(dd)*tresult{K+2}(:,(dd*CCC-CCC+1):(dd*CCC))]; end
V_tot=V_tot./ repmat(sqrt(sum(V_tot.^2,2)),1,size(V_tot,2));
Clus_ind_wd123=litekmeans(V_tot,CCC,'Replicates',50);  %% run k-means on embeddings to get cell populations
 
V_tot=[]; for dd=1:K;  V_tot=[V_tot, 1*tresult{K+2}(:,(dd*CCC-CCC+1):(dd*CCC))]; end
V_tot=V_tot./ repmat(sqrt(sum(V_tot.^2,2)),1,size(V_tot,2));
Clus_ind_wde123=litekmeans(V_tot,CCC,'Replicates',50);  %% run k-means on embeddings to get cell populations
 
%this uses the first leared target matrix for clustering analysis
V_tot=tresult{2}; 
V_tot=V_tot./ repmat(sqrt(sum(V_tot.^2,2)),1,size(V_tot,2));
Clus_ind_wdf123=litekmeans(V_tot,CCC,'Replicates',50);  %% run k-means on embeddings to get cell populations
 
nmi_wd123=[nmi_wd123,Cal_NMI(clus_ind_set122{uuu}{26}, Clus_ind_wd123)]; pmi_wd123=[pmi_wd123,purity(CCC, Clus_ind_wd123, clus_ind_set122{uuu}{26})];
rmi_wd123=[rmi_wd123,RandIndex(clus_ind_set122{uuu}{26}, Clus_ind_wd123)];
nmi_wde123=[nmi_wde123,Cal_NMI(clus_ind_set122{uuu}{27}, Clus_ind_wde123)]; pmi_wde123=[pmi_wde123,purity(CCC, Clus_ind_wde123, clus_ind_set122{uuu}{27})];
rmi_wde123=[rmi_wde123,RandIndex(clus_ind_set122{uuu}{27}, Clus_ind_wde123)];
nmi_wdf123=[nmi_wdf123,Cal_NMI(clus_ind_set122{uuu}{28}, Clus_ind_wdf123)]; pmi_wdf123=[pmi_wdf123,purity(CCC, Clus_ind_wdf123, clus_ind_set122{uuu}{28})];
rmi_wdf123=[rmi_wdf123,RandIndex(clus_ind_set122{uuu}{28}, Clus_ind_wdf123)];


%% sparse spect cluster
[Ps,objs,errs,iters] = sparsesc(eye(n)-Wfc0s_euc_near_n{1}{1}{22},0.00001,CCC);
[V_tot1, temp, evs]=eig1(Ps, CCC); 
Clus_ind_sparsc1=litekmeans(double(V_tot1),CCC,'Replicates',50);  %% run k-means on embeddings to get cell populations

[Ps,objs,errs,iters] = sparsesc(eye(n)-Wfc0s_euc_near_n{2}{1}{22},0.00001,CCC);
[V_tot2, temp, evs]=eig1(Ps, CCC); 
Clus_ind_sparsc2=litekmeans(double(V_tot2),CCC,'Replicates',50); 

[Ps,objs,errs,iters] = sparsesc(eye(n)-Wfc0s_euc_near_n{3}{1}{22},0.00001,CCC);
[V_tot3, temp, evs]=eig1(Ps, CCC); 
Clus_ind_sparsc3=litekmeans(double(V_tot3),CCC,'Replicates',50); 

Clus_ind_sparsc123=litekmeans(double([V_tot1,V_tot2,V_tot3]),CCC,'Replicates',50); 

nmi_ssc1=[nmi_ssc1,Cal_NMI(clus_ind_set122{uuu}{9}, Clus_ind_sparsc1)]; pmi_ssc1=[pmi_ssc1,purity(CCC, Clus_ind_sparsc1, clus_ind_set122{uuu}{9})];
rmi_ssc1=[rmi_ssc1,RandIndex(clus_ind_set122{uuu}{9}, Clus_ind_sparsc1)];
nmi_ssc2=[nmi_ssc2,Cal_NMI(clus_ind_set122{uuu}{10}, Clus_ind_sparsc2)]; pmi_ssc2=[pmi_ssc2,purity(CCC, Clus_ind_sparsc2, clus_ind_set122{uuu}{10})];
rmi_ssc2=[rmi_ssc2,RandIndex(clus_ind_set122{uuu}{10}, Clus_ind_sparsc2)];
nmi_ssc3=[nmi_ssc3,Cal_NMI(clus_ind_set122{uuu}{11}, Clus_ind_sparsc3)]; pmi_ssc3=[pmi_ssc3,purity(CCC, Clus_ind_sparsc3, clus_ind_set122{uuu}{11})];
rmi_ssc3=[rmi_ssc3,RandIndex(clus_ind_set122{uuu}{11}, Clus_ind_sparsc3)];
nmi_ssc123=[nmi_ssc123,Cal_NMI(clus_ind_set122{uuu}{12}, Clus_ind_sparsc123)]; pmi_ssc123=[pmi_ssc123,purity(CCC, Clus_ind_sparsc123, clus_ind_set122{uuu}{12})];
rmi_ssc123=[rmi_ssc123,RandIndex(clus_ind_set122{uuu}{12}, Clus_ind_sparsc123)];

end

nnmi_cen1=[nnmi_cen1;nmi_cen1]; nnmi_cen2=[nnmi_cen2;nmi_cen2]; nnmi_cen3=[nnmi_cen3;nmi_cen3]; nnmi_cen123=[nnmi_cen123;nmi_cen123];
nnmi_cm123=[nnmi_cm123;nmi_cm123]; nnmi_pm123=[nnmi_pm123;nmi_pm123];
nnmik1=[nnmik1;nmik1]; nnmik2=[nnmik2;nmik2]; nnmik3=[nnmik3;nmik3]; nnmik123=[nnmik123;nmik123];
nnmis1=[nnmis1;nmis1]; nnmis2=[nnmis2;nmis2]; nnmis3=[nnmis3;nmis3]; nnmis123=[nnmis123;nmis123];
nnmi_keradd123=[nnmi_keradd123;nmi_keradd123];
nnmi_wd123=[nnmi_wd123;nmi_wd123]; nnmi_wde123=[nnmi_wde123;nmi_wde123]; nnmi_wdf123=[nnmi_wdf123;nmi_wdf123];
nnmi_ed123=[nnmi_ed123;nmi_ed123]; nnmi_edf123=[nnmi_edf123;nmi_edf123];
nnmi_sml1=[nnmi_sml1;nmi_sml1]; nnmi_sml2=[nnmi_sml2;nmi_sml2]; nnmi_sml3=[nnmi_sml3;nmi_sml3]; nnmi_sml123=[nnmi_sml123;nmi_sml123];
nnmi_ssc1=[nnmi_ssc1;nmi_ssc1]; nnmi_ssc2=[nnmi_ssc2;nmi_ssc2]; nnmi_ssc3=[nnmi_ssc3;nmi_ssc3]; nnmi_ssc123=[nnmi_ssc123;nmi_ssc123];


ppmi_cen1=[ppmi_cen1;pmi_cen1]; ppmi_cen2=[ppmi_cen2;pmi_cen2]; ppmi_cen3=[ppmi_cen3;pmi_cen3]; ppmi_cen123=[ppmi_cen123;pmi_cen123];
ppmi_cm123=[ppmi_cm123;pmi_cm123]; ppmi_pm123=[ppmi_pm123;pmi_pm123];
ppmik1=[ppmik1;pmik1]; ppmik2=[ppmik2;pmik2]; ppmik3=[ppmik3;pmik3]; ppmik123=[ppmik123;pmik123];
ppmis1=[ppmis1;pmis1]; ppmis2=[ppmis2;pmis2]; ppmis3=[ppmis3;pmis3]; ppmis123=[ppmis123;pmis123];
ppmi_keradd123=[ppmi_keradd123;pmi_keradd123];
ppmi_wd123=[ppmi_wd123;pmi_wd123]; ppmi_wde123=[ppmi_wde123;pmi_wde123]; ppmi_wdf123=[ppmi_wdf123;pmi_wdf123];
ppmi_ed123=[ppmi_ed123;pmi_ed123]; ppmi_edf123=[ppmi_edf123;pmi_edf123];
ppmi_sml1=[ppmi_sml1;pmi_sml1]; ppmi_sml2=[ppmi_sml2;pmi_sml2]; ppmi_sml3=[ppmi_sml3;pmi_sml3]; ppmi_sml123=[ppmi_sml123;pmi_sml123];
ppmi_ssc1=[ppmi_ssc1;pmi_ssc1]; ppmi_ssc2=[ppmi_ssc2;pmi_ssc2]; ppmi_ssc3=[ppmi_ssc3;pmi_ssc3]; ppmi_ssc123=[ppmi_ssc123;pmi_ssc123];

rrmi_cen1=[rrmi_cen1;rmi_cen1]; rrmi_cen2=[rrmi_cen2;rmi_cen2]; rrmi_cen3=[rrmi_cen3;rmi_cen3]; rrmi_cen123=[rrmi_cen123;rmi_cen123];
rrmi_cm123=[rrmi_cm123;rmi_cm123]; rrmi_pm123=[rrmi_pm123;rmi_pm123];
rrmik1=[rrmik1;rmik1]; rrmik2=[rrmik2;rmik2]; rrmik3=[rrmik3;rmik3]; rrmik123=[rrmik123;rmik123];
rrmis1=[rrmis1;rmis1]; rrmis2=[rrmis2;rmis2]; rrmis3=[rrmis3;rmis3]; rrmis123=[rrmis123;rmis123];
rrmi_keradd123=[rrmi_keradd123;rmi_keradd123];
rrmi_wd123=[rrmi_wd123;rmi_wd123]; rrmi_wde123=[rrmi_wde123;rmi_wde123]; rrmi_wdf123=[rrmi_wdf123;rmi_wdf123];
rrmi_ed123=[rrmi_ed123;rmi_ed123]; rrmi_edf123=[rrmi_edf123;rmi_edf123];
rrmi_sml1=[rrmi_sml1;rmi_sml1]; rrmi_sml2=[rrmi_sml2;rmi_sml2]; rrmi_sml3=[rrmi_sml3;rmi_sml3]; rrmi_sml123=[rrmi_sml123;rmi_sml123];
rrmi_ssc1=[rrmi_ssc1;rmi_ssc1]; rrmi_ssc2=[rrmi_ssc2;rmi_ssc2]; rrmi_ssc3=[rrmi_ssc3;rmi_ssc3]; rrmi_ssc123=[rrmi_ssc123;rmi_ssc123];
 
end


nnmi_set{1}=nnmi_cen1;nnmi_set{2}=nnmi_cen2;nnmi_set{3}=nnmi_cen3;nnmi_set{4}=nnmi_cen123; nnmi_set{5}=nnmi_cm123;
nnmi_set{6}=nnmi_pm123;nnmi_set{7}=nnmik1;nnmi_set{8}=nnmik2;nnmi_set{9}=nnmik3;nnmi_set{10}=nnmik123;
nnmi_set{11}=nnmis1;nnmi_set{12}=nnmis2;nnmi_set{13}=nnmis3;nnmi_set{14}=nnmis123;
nnmi_set{15}=nnmi_keradd123; nnmi_set{16}=nnmi_wd123;nnmi_set{17}=nnmi_wde123;nnmi_set{18}=nnmi_wdf123;
nnmi_set{19}=nnmi_ed123;nnmi_set{20}=nnmi_edf123;nnmi_set{21}=nnmi_sml1;nnmi_set{22}=nnmi_sml2;nnmi_set{23}=nnmi_sml3;
nnmi_set{24}=nnmi_sml123; nnmi_set{25}=nnmi_ssc1;nnmi_set{26}=nnmi_ssc2;nnmi_set{27}=nnmi_ssc3;
nnmi_set{28}=nnmi_ssc123;


ppmi_set{1}=ppmi_cen1;ppmi_set{2}=ppmi_cen2;ppmi_set{3}=ppmi_cen3;ppmi_set{4}=ppmi_cen123; ppmi_set{5}=ppmi_cm123;
ppmi_set{6}=ppmi_pm123;ppmi_set{7}=ppmik1;ppmi_set{8}=ppmik2;ppmi_set{9}=ppmik3;ppmi_set{10}=ppmik123;
ppmi_set{11}=ppmis1;ppmi_set{12}=ppmis2;ppmi_set{13}=ppmis3;ppmi_set{14}=ppmis123;
ppmi_set{15}=ppmi_keradd123; ppmi_set{16}=ppmi_wd123;ppmi_set{17}=ppmi_wde123;ppmi_set{18}=ppmi_wdf123;
ppmi_set{19}=ppmi_ed123;ppmi_set{20}=ppmi_edf123;ppmi_set{21}=ppmi_sml1;ppmi_set{22}=ppmi_sml2;ppmi_set{23}=ppmi_sml3;
ppmi_set{24}=ppmi_sml123;ppmi_set{25}=ppmi_ssc1;ppmi_set{26}=ppmi_ssc2;ppmi_set{27}=ppmi_ssc3;
ppmi_set{28}=ppmi_ssc123;


rrmi_set{1}=rrmi_cen1;rrmi_set{2}=rrmi_cen2;rrmi_set{3}=rrmi_cen3;rrmi_set{4}=rrmi_cen123; rrmi_set{5}=rrmi_cm123;
rrmi_set{6}=rrmi_pm123;rrmi_set{7}=rrmik1;rrmi_set{8}=rrmik2;rrmi_set{9}=rrmik3;rrmi_set{10}=rrmik123;
rrmi_set{11}=rrmis1;rrmi_set{12}=rrmis2;rrmi_set{13}=rrmis3;rrmi_set{14}=rrmis123;
rrmi_set{15}=rrmi_keradd123; rrmi_set{16}=rrmi_wd123;rrmi_set{17}=rrmi_wde123;rrmi_set{18}=rrmi_wdf123;
rrmi_set{19}=rrmi_ed123;rrmi_set{20}=rrmi_edf123;rrmi_set{21}=rrmi_sml1;rrmi_set{22}=rrmi_sml2;rrmi_set{23}=rrmi_sml3;
rrmi_set{24}=rrmi_sml123;rrmi_set{25}=rrmi_ssc1;rrmi_set{26}=rrmi_ssc2;rrmi_set{27}=rrmi_ssc3;
rrmi_set{28}=rrmi_ssc123;

save('simul_threedata_22_stability_mean.mat', 'rrmi_set','nnmi_set','ppmi_set'); 
