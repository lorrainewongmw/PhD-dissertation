# PhD dissertation do files
This is a collection of code files for my PhD dissertation. The dataset is not part of this repository due to third party restrictions. I present 3 papers covering topics on the economics of migration and labour economics. 

## Code file description
### [p1_asymig](https://github.com/lorrainewongmw/PhD-dissertation/tree/master/p1_asymig)
Title: The labour market differences between the asylum population and economic migrants\
I estimate the bounds on employment and wage gaps between the asylum population and economic migrants. The code files are structured as:
1. asymig_fullcode
1. asymig_des
1. asymig_sim

`asymig_fullcode` is linked to all other code files for this paper. It contains codes for my main analysis and sensitivity checks. I use two non-experimental methods: selection on observables versus unobservables, and matching techniques (propensity score matching, coarsened exact matching). I also run quantile regression as a robustness check. `asymig_des` contains codes for generating descriptive tables and figures. `asymig_sim` records some additional simulation exercise.


### [p2_lang](https://github.com/lorrainewongmw/PhD-dissertation/tree/master/p2_lang)
Title: The effect of lingusitic proximity on the labour-market outcomes of the asylum population\
I study the role of linguistic proximity (from mother tongue to the learned language) on economic integration of the asylum population. I combine my analysis with several open-source database:
1. a linguistic proximity index from the Automated Similarity Judgement Program (ASJP)
1. publicaly available country of origin characteristics (e.g. World Bank, Freedom House, and Swiss National Statistics)
1. an additional linguistic proximity index from Adserà and Pytliková (2015).

The code files are structured as :
1. lang_fullcode
1. lang_des
1. lang_id

`lang_fullcode` is the main code file. It includes my main analysis and robustness tests. `lang_des` contains codes for descriptive statistics and figures. `lang_id` contains codes for testing the identification assumptions. 


### [p3_wait](https://github.com/lorrainewongmw/PhD-dissertation/tree/master/p3_wait)
Title: From asylum seekers to refugees: Do waiting times affect labour-market integration?\
I examine the impact of waiting time to permit decisions on labour-market outcomes of the asylum population. The code files are ordered as follows:

1. wait_fullcode
1. wait_des
1. wait_id

`wait_fullcode` is the main code file with my main analysis and sensitivity checks. `wait_des` contains codes for descriptive statistics and figures. `wait_id` contains codes for testing the identification assumptions. I run some multiple hypothesis tests adjusting for the family-wise error rate.


## Dataset desciption
I use one common dataset for all three analysis. The main data source is the Swiss Longitudinal Demographic Database. It is a linked dataset with administrative records and survey responses. The data is restricted to the research team with NCCR - On the move. The following is a list of variables I used:

Dependent variables:
- `emp`: employment 
- `lrevenu`: natural log of annual wage 
- `emp_b`: living wage 

Variables of interest:
- `asypop`: indicator for the asylum population or economic migrant 
- `std_LDND`: linguistic proximity - i.e. 100%-LDND standardized by its standard deviation 
- `std_INDEX`: linguistic proximity from Adserà and Pytliková (2015) 
- `waitB`: years waiting for refugee permit (permit B) 
- `waitF`: years waiting for temporary accepted refugee/person (permit F) 
- `stay_waitB` or `stay_waitF`: The ratio of waiting time divided by length of stay 

Common covariates:
- `sexst`: gender 
- `age`: age 
- `highestcompleduaggi`: education 
- `mainlang` or `lang_2`: reported main language 
- `hhsize`: household size 
- `rural`: geography (rural/urban) 
- `chduration` or `CHduration`: duration of stay 
- `charrivalyear`: arrival year 
- `arrival_cohort`: arrival cohort 
- `year`: outcome year 
- `Canton`: administrative region 
- `nationalityid`: nationality 

Covariates specific to papers:
- `birthplace`: country of birth 
- `free`: indicator for EU-born 
- `free_nat`: indicator for EU-nationals 
- `asylumseeker`: asylum seeker 
- `ldist`: natural log of distance between capital cities in km 
- `lpopratio`: natural log of population ratio (population ratio is population in Swizterland divided by population in origin country) 
- `lstock`: natural log of stock of permanent residents of the same nationality 
- `FST_dom_std`: standardized genetic distance 
- `PR`: political rights in origin country 
- `CL`: civil liberties in origin country 
- `colcomb`: ever in colonial relationship (with either Switzerland, Germany, France, or Italy) 
- `traject`: permit trajectories (permit N->F; N->B; F->B; N->F->B) 

## Requirement 
I use Stata 14.2, with the following user written commands:
- psacalc
- psmatch2
- pstest
- cem
- sqreg
- wyoung
- outreg2
- putexcel






